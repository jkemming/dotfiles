mod common;

use std::process::Command;
use std::thread::sleep;
use std::time::{Duration, Instant};

use common::Sandbox;

const GIT: &str = env!("CARGO_BIN_EXE_git");

const CONFIG: &str = "secrets.entry GitHub\nsecrets.privatekeyfield Private\nsecrets.publickeyfield Public\n";

/// Stubs git (with the secrets configured unless `config` is empty), kgrant and ssh-add. ssh-agent is the real one
/// since the shim depends on how it behaves.
fn sandbox(config: &str) -> Sandbox {
    let sandbox = Sandbox::new();
    sandbox.stub(
        "git",
        &format!(
            r#"
            if [ "$1" = config ]; then printf '%s' '{config}'; exit; fi
            printf '%s\n' "$@" >"$SANDBOX/args"
            env >"$SANDBOX/env"
            exit "${{STUB_GIT_EXIT:-0}}"
            "#
        ),
    );
    sandbox.stub(
        "kgrant",
        r#"
        echo "$@" >>"$SANDBOX/kgrant"
        printf '{"Private":"PRIVATE","Public":"ssh-ed25519 PUBLIC"}'
        "#,
    );
    sandbox.stub("ssh-add", r#"cat >"$SANDBOX/ssh-add""#);
    sandbox
}

fn env_var(sandbox: &Sandbox, name: &str) -> Option<String> {
    sandbox
        .read("env")
        .lines()
        .find_map(|line| line.strip_prefix(&format!("{name}=")))
        .map(str::to_owned)
}

#[test]
fn passes_through_without_secrets_configured() {
    let sandbox = sandbox("");
    let status = sandbox.command(GIT).args(["status", "--short"]).status().unwrap();

    assert!(status.success());
    assert_eq!(sandbox.read("args"), "status\n--short\n");
    assert_eq!(sandbox.read("kgrant"), "", "must not fetch secrets");
    assert_eq!(env_var(&sandbox, "GIT_SHIM_ACTIVE"), None);
}

#[test]
fn signs_with_the_public_key() {
    let sandbox = sandbox(CONFIG);
    let status = sandbox.command(GIT).args(["commit", "-m", "a b"]).status().unwrap();

    assert!(status.success());
    assert_eq!(
        sandbox.read("args"),
        "-c\nuser.signingkey=key::ssh-ed25519 PUBLIC\ncommit\n-m\na b\n"
    );
    assert_eq!(sandbox.read("kgrant"), "get --json GitHub Private Public\n");
}

#[test]
fn loads_the_private_key_into_an_agent_but_not_into_the_environment() {
    let sandbox = sandbox(CONFIG);
    sandbox.command(GIT).arg("push").status().unwrap();

    assert_eq!(sandbox.read("ssh-add"), "PRIVATE\n");
    assert!(env_var(&sandbox, "SSH_AUTH_SOCK").is_some());
    assert_eq!(env_var(&sandbox, "SSH_PRIVATE_KEY"), None);
    assert_eq!(env_var(&sandbox, "GIT_SHIM_ACTIVE"), Some("true".into()));
}

#[test]
fn stops_the_agent_afterwards() {
    let sandbox = sandbox(CONFIG);
    sandbox.command(GIT).arg("push").status().unwrap();

    let pid = env_var(&sandbox, "SSH_AGENT_PID").unwrap();
    let process = std::path::PathBuf::from("/proc").join(pid);
    // Stopping the agent takes a moment
    for _ in 0..50 {
        if !process.exists() {
            return;
        }
        sleep(Duration::from_millis(20));
    }
    panic!("agent {} is still running", process.display());
}

/// Waits until the condition holds, and fails if it doesn't within a few seconds
fn wait_for(what: &str, mut condition: impl FnMut() -> bool) {
    let start = Instant::now();
    while !condition() {
        assert!(start.elapsed() < Duration::from_secs(5), "timed out waiting for {what}");
        sleep(Duration::from_millis(10));
    }
}

#[test]
fn forwards_sigterm_to_git_and_stops_the_agent() {
    let sandbox = sandbox(CONFIG);
    sandbox.stub(
        "git",
        &format!(
            r#"
            if [ "$1" = config ]; then printf '%s' '{CONFIG}'; exit; fi
            env >"$SANDBOX/env"
            trap 'echo terminated >"$SANDBOX/terminated"; exit 7' TERM
            echo started >"$SANDBOX/started"
            sleep 30 &
            wait
            "#
        ),
    );

    let mut shim = sandbox.command(GIT).arg("fetch").spawn().unwrap();
    wait_for("git to start", || !sandbox.read("started").is_empty());
    assert!(
        Command::new("kill")
            .args(["-TERM", &shim.id().to_string()])
            .status()
            .unwrap()
            .success()
    );

    // The shim only exits after git has, with its exit code
    let status = shim.wait().unwrap();
    assert_eq!(sandbox.read("terminated"), "terminated\n");
    assert_eq!(status.code(), Some(7));

    let process = std::path::PathBuf::from("/proc").join(env_var(&sandbox, "SSH_AGENT_PID").unwrap());
    wait_for("the agent to stop", || !process.exists());
}

#[test]
fn passes_on_the_exit_code() {
    let sandbox = sandbox(CONFIG);
    let status = sandbox
        .command(GIT)
        .arg("push")
        .env("STUB_GIT_EXIT", "3")
        .status()
        .unwrap();

    assert_eq!(status.code(), Some(3));
}

#[test]
fn nested_calls_use_what_the_outer_call_set_up() {
    let sandbox = sandbox(CONFIG);
    let status = sandbox
        .command(GIT)
        .arg("log")
        .env("GIT_SHIM_ACTIVE", "true")
        .status()
        .unwrap();

    assert!(status.success());
    assert_eq!(sandbox.read("args"), "log\n");
    assert_eq!(sandbox.read("kgrant"), "", "must not fetch secrets");
}

#[test]
fn fails_if_secrets_cant_be_fetched() {
    let sandbox = sandbox(CONFIG);
    sandbox.stub("kgrant", "echo denied >&2; exit 1");
    let output = sandbox.command(GIT).arg("push").output().unwrap();

    assert!(!output.status.success());
    assert!(String::from_utf8_lossy(&output.stderr).contains("git: kgrant failed"));
    assert_eq!(sandbox.read("args"), "", "must not run git");
}

#[test]
fn fails_without_real_git() {
    let sandbox = Sandbox::new();
    let output = sandbox.command(GIT).env("PATH", "").output().unwrap();

    assert!(!output.status.success());
    assert_eq!(
        String::from_utf8_lossy(&output.stderr),
        "git: real git not found on PATH\n"
    );
}
