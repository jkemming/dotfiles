//! Shim for git which signs and authenticates with the SSH key from the secret store configured under `secrets.*` in
//! the git config.

use std::collections::HashMap;
use std::env;
use std::ffi::OsString;
use std::io::Write;
use std::os::unix::process::{CommandExt, ExitStatusExt};
use std::process::{Command, ExitCode, ExitStatus, Stdio};
use std::sync::Arc;
use std::sync::atomic::{AtomicBool, Ordering};
use std::thread;

use crate::{Result, real_command};
use signal_hook::consts::{SIGHUP, SIGINT, SIGTERM};
use signal_hook::iterator::Signals;

struct SecretsConfig {
    entry: String,
    private_key_field: String,
    public_key_field: String,
}

struct Keys {
    private: String,
    public: String,
}

/// A running ssh-agent which is stopped again when dropped
struct Agent {
    socket: String,
    pid: String,
}

pub fn main() -> ExitCode {
    match run() {
        Ok(code) => code,
        Err(err) => {
            eprintln!("git: {err}");
            ExitCode::FAILURE
        }
    }
}

fn run() -> Result<ExitCode> {
    let args: Vec<OsString> = env::args_os().skip(1).collect();

    // Nested calls (hooks, aliases) inherit the agent and signing key from the outer call
    if env::var_os("GIT_SHIM_ACTIVE").is_some() {
        return Err(real_command()?.args(&args).exec().into());
    }
    let Some(config) = read_config()? else {
        return Err(real_command()?.args(&args).exec().into());
    };

    let keys = fetch_keys(&config)?;

    // Interrupting the shim must not leave the agent behind, so the shim survives signals until git has exited
    let signalled = Arc::new(AtomicBool::new(false));
    for signal in [SIGHUP, SIGINT, SIGTERM] {
        signal_hook::flag::register(signal, signalled.clone())?;
    }

    let agent = Agent::start()?;
    agent.add_key(&keys.private)?;

    if signalled.load(Ordering::Relaxed) {
        return Err("interrupted".into());
    }

    let mut git = real_command()?;
    git.args(["-c", &format!("user.signingkey=key::{}", keys.public)])
        .args(&args)
        .env("SSH_AUTH_SOCK", &agent.socket)
        .env("SSH_AGENT_PID", &agent.pid)
        .env("GIT_SHIM_ACTIVE", "true");
    Ok(exit_code(run_forwarding_signals(&mut git)?))
}

/// Runs the command as a child and waits for it. SIGTERM and SIGHUP are forwarded to it since they may have been sent
/// to the shim alone. SIGINT isn't, as it comes from the terminal, which delivers it to git as well.
fn run_forwarding_signals(command: &mut Command) -> Result<ExitStatus> {
    // Registered before spawning so that no signal is missed
    let mut signals = Signals::new([SIGHUP, SIGTERM])?;
    let handle = signals.handle();
    let mut child = command.spawn()?;

    let pid = child.id() as libc::pid_t;
    let forwarder = thread::spawn(move || {
        for signal in signals.forever() {
            // SAFETY: Sending a signal has no memory safety requirements
            unsafe { libc::kill(pid, signal) };
        }
    });

    let status = child.wait();
    handle.close();
    let _ = forwarder.join();
    Ok(status?)
}

fn read_config() -> Result<Option<SecretsConfig>> {
    // Fails if there are no matches, which is the same as not being configured
    let output = real_command()?
        .args(["config", "--get-regexp", r"^secrets\."])
        .stderr(Stdio::inherit())
        .output()?;
    Ok(parse_config(&String::from_utf8(output.stdout)?))
}

/// Parses the output of `git config --get-regexp`, e.g. `secrets.entry GitHub`
fn parse_config(stdout: &str) -> Option<SecretsConfig> {
    let (mut entry, mut private_key_field, mut public_key_field) = (None, None, None);
    for (name, value) in stdout.lines().filter_map(|line| line.split_once(' ')) {
        let value = Some(value.to_owned());
        match name {
            "secrets.entry" => entry = value,
            "secrets.privatekeyfield" => private_key_field = value,
            "secrets.publickeyfield" => public_key_field = value,
            _ => {}
        }
    }

    match (entry, private_key_field, public_key_field) {
        (Some(entry), Some(private_key_field), Some(public_key_field)) => Some(SecretsConfig {
            entry,
            private_key_field,
            public_key_field,
        }),
        _ => None,
    }
}

fn fetch_keys(config: &SecretsConfig) -> Result<Keys> {
    let output = Command::new("kgrant")
        .args([
            "get",
            "--json",
            &config.entry,
            &config.private_key_field,
            &config.public_key_field,
        ])
        .stderr(Stdio::inherit())
        .output()?;
    if !output.status.success() {
        return Err(format!("kgrant failed ({})", output.status).into());
    }

    parse_keys(&output.stdout, config)
}

/// Parses the JSON object from field name to value printed by `kgrant get --json`
fn parse_keys(json: &[u8], config: &SecretsConfig) -> Result<Keys> {
    let mut fields: HashMap<String, String> = serde_json::from_slice(json)?;
    let mut take = |field: &str| {
        fields
            .remove(field)
            .ok_or(format!("kgrant returned no field {field:?}"))
    };
    Ok(Keys {
        private: take(&config.private_key_field)?,
        public: take(&config.public_key_field)?,
    })
}

impl Agent {
    fn start() -> Result<Self> {
        let output = Command::new("ssh-agent").arg("-s").stderr(Stdio::inherit()).output()?;
        if !output.status.success() {
            return Err(format!("ssh-agent failed ({})", output.status).into());
        }

        Self::parse(&String::from_utf8(output.stdout)?)
    }

    /// Parses the shell commands printed by `ssh-agent -s`, e.g. `SSH_AUTH_SOCK=/tmp/ssh-XXX/agent.1; export SSH_AUTH_SOCK;`
    fn parse(stdout: &str) -> Result<Self> {
        let variable = |name: &str| {
            stdout
                .split(';')
                .find_map(|command| command.trim().strip_prefix(name)?.strip_prefix('='))
                .map(str::to_owned)
                .ok_or(format!("ssh-agent did not print {name}"))
        };
        Ok(Self {
            socket: variable("SSH_AUTH_SOCK")?,
            pid: variable("SSH_AGENT_PID")?,
        })
    }

    fn add_key(&self, private_key: &str) -> Result<()> {
        let mut ssh_add = Command::new("ssh-add")
            .arg("-")
            .env("SSH_AUTH_SOCK", &self.socket)
            .stdin(Stdio::piped())
            .stdout(Stdio::null())
            .spawn()?;
        let mut stdin = ssh_add.stdin.take().ok_or("ssh-add has no stdin")?;
        writeln!(stdin, "{private_key}")?;
        drop(stdin);

        let status = ssh_add.wait()?;
        if !status.success() {
            return Err(format!("ssh-add failed ({status})").into());
        }
        Ok(())
    }
}

impl Drop for Agent {
    fn drop(&mut self) {
        let _ = Command::new("ssh-agent")
            .arg("-k")
            .env("SSH_AGENT_PID", &self.pid)
            .env("SSH_AUTH_SOCK", &self.socket)
            .stdout(Stdio::null())
            .status();
    }
}

/// Mirrors how a shell reports the exit status of a command that was killed by a signal
fn exit_code(status: ExitStatus) -> ExitCode {
    match status.code() {
        Some(code) => ExitCode::from(code as u8),
        None => ExitCode::from(128 + status.signal().unwrap_or(0) as u8),
    }
}

#[cfg(test)]
mod tests {
    use super::*;
    use std::os::unix::process::ExitStatusExt;

    fn config() -> SecretsConfig {
        SecretsConfig {
            entry: "GitHub".into(),
            private_key_field: "Private".into(),
            public_key_field: "Public".into(),
        }
    }

    #[test]
    fn parses_config() {
        let parsed = parse_config(
            "secrets.entry GitHub\nsecrets.privatekeyfield SSH Private Key\nsecrets.publickeyfield SSH Public Key\n",
        )
        .unwrap();
        assert_eq!(parsed.entry, "GitHub");
        assert_eq!(parsed.private_key_field, "SSH Private Key");
        assert_eq!(parsed.public_key_field, "SSH Public Key");
    }

    #[test]
    fn config_is_incomplete_without_all_settings() {
        assert!(parse_config("").is_none());
        assert!(parse_config("secrets.entry GitHub\nsecrets.privatekeyfield Private\n").is_none());
        assert!(parse_config("user.name someone\n").is_none());
    }

    #[test]
    fn parses_keys() {
        let keys = parse_keys(
            br#"{"Private":"PRIVATE","Public":"ssh-ed25519 PUBLIC","Other":"x"}"#,
            &config(),
        )
        .unwrap();
        assert_eq!(keys.private, "PRIVATE");
        assert_eq!(keys.public, "ssh-ed25519 PUBLIC");
    }

    #[test]
    fn keys_fail_if_a_field_is_missing() {
        let err = parse_keys(br#"{"Private":"PRIVATE"}"#, &config()).err().unwrap();
        assert_eq!(err.to_string(), r#"kgrant returned no field "Public""#);
    }

    #[test]
    fn keys_fail_on_invalid_json() {
        assert!(parse_keys(b"not json", &config()).is_err());
    }

    #[test]
    fn parses_agent_output() {
        let agent = Agent::parse(
            "SSH_AUTH_SOCK=/tmp/ssh-XXX/agent.1; export SSH_AUTH_SOCK;\nSSH_AGENT_PID=42; export SSH_AGENT_PID;\necho Agent pid 42;\n",
        )
        .unwrap();
        assert_eq!(agent.socket, "/tmp/ssh-XXX/agent.1");
        assert_eq!(agent.pid, "42");
        // Nothing to stop since the agent isn't real
        std::mem::forget(agent);
    }

    #[test]
    fn agent_output_fails_without_variables() {
        let err = Agent::parse("SSH_AUTH_SOCK=/tmp/agent; export SSH_AUTH_SOCK;\n")
            .err()
            .unwrap();
        assert_eq!(err.to_string(), "ssh-agent did not print SSH_AGENT_PID");
    }

    #[test]
    fn exit_code_mirrors_a_shell() {
        assert_eq!(exit_code(ExitStatus::from_raw(3 << 8)), ExitCode::from(3));
        // Killed by SIGTERM
        assert_eq!(exit_code(ExitStatus::from_raw(15)), ExitCode::from(143));
    }
}
