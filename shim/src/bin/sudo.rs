//! Shim for sudo which asks for the password via sudo-askpass instead of the terminal.

use std::convert::Infallible;
use std::env;
use std::ffi::OsString;
use std::os::unix::process::CommandExt;
use std::path::PathBuf;
use std::process::ExitCode;

use shim::{Result, real_command};

/// Options which are followed by a value that must not be mistaken for the command
const OPTIONS_WITH_VALUE: [&str; 17] = [
    "-u", "-g", "-p", "-C", "-D", "-R", "-T", "-U", "-r", "-t", "-c", "--user", "--group", "--prompt", "--chdir",
    "--chroot", "--command-timeout",
];

fn main() -> ExitCode {
    let Err(err) = run();
    eprintln!("sudo: {err}");
    ExitCode::FAILURE
}

fn run() -> Result<Infallible> {
    let args: Vec<OsString> = env::args_os().skip(1).collect();
    let askpass = PathBuf::from(env::var_os("HOME").ok_or("HOME is not set")?).join(".local/libexec/sudo-askpass");

    let mut command = real_command()?;
    command.env("SUDO_ASKPASS", askpass).arg("-E");
    if wants_askpass(&args) {
        command.arg("-A");
    }
    Err(command.args(args).exec().into())
}

/// Whether to ask for the password via askpass, unless the caller already chose how to read it, e.g. `sudo -S` in a script
fn wants_askpass(args: &[OsString]) -> bool {
    let mut skip_value = false;
    for arg in args {
        let Some(arg) = arg.to_str() else { break };
        if skip_value {
            skip_value = false;
            continue;
        }
        match arg {
            "--" => break,
            "-S" | "-n" | "-A" | "--stdin" | "--non-interactive" | "--askpass" => return false,
            _ if OPTIONS_WITH_VALUE.contains(&arg) => skip_value = true,
            _ if arg.starts_with("--") => {}
            // Combined short options, e.g. `-nE`
            _ if arg.starts_with('-') => {
                if arg.contains(['S', 'n', 'A']) {
                    return false;
                }
            }
            _ => break,
        }
    }
    true
}
