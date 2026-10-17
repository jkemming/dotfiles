mod common;

use common::Sandbox;

const SUDO: &str = env!("CARGO_BIN_EXE_sudo");

fn sandbox() -> Sandbox {
    let sandbox = Sandbox::new();
    sandbox.stub(
        "sudo",
        r#"printf '%s\n' "$@" >"$SANDBOX/args"; echo "$SUDO_ASKPASS" >"$SANDBOX/askpass""#,
    );
    sandbox
}

fn args(sandbox: &Sandbox) -> Vec<String> {
    sandbox.read("args").lines().map(str::to_owned).collect()
}

#[test]
fn asks_via_askpass() {
    let sandbox = sandbox();
    let status = sandbox
        .command(SUDO)
        .env("HOME", "/home/test")
        .args(["whoami"])
        .status()
        .unwrap();

    assert!(status.success());
    assert_eq!(args(&sandbox), ["-E", "-A", "whoami"]);
    assert_eq!(sandbox.read("askpass").trim(), "/home/test/.local/libexec/sudo-askpass");
}

#[test]
fn keeps_the_option_to_read_the_password_chosen_by_the_caller() {
    let sandbox = sandbox();
    sandbox
        .command(SUDO)
        .env("HOME", "/home/test")
        .args(["-S", "whoami"])
        .status()
        .unwrap();

    assert_eq!(args(&sandbox), ["-E", "-S", "whoami"]);
}

#[test]
fn passes_arguments_through_untouched() {
    let sandbox = sandbox();
    sandbox
        .command(SUDO)
        .env("HOME", "/home/test")
        .args(["-u", "alice", "sh", "-c", "echo a b"])
        .status()
        .unwrap();

    assert_eq!(args(&sandbox), ["-E", "-A", "-u", "alice", "sh", "-c", "echo a b"]);
}

#[test]
fn fails_without_real_sudo() {
    let sandbox = Sandbox::new();
    let output = sandbox
        .command(SUDO)
        .env("HOME", "/home/test")
        .env("PATH", "")
        .output()
        .unwrap();

    assert!(!output.status.success());
    assert_eq!(
        String::from_utf8_lossy(&output.stderr),
        "sudo: real sudo not found on PATH\n"
    );
}
