//! Helpers shared by the integration tests

use std::env;
use std::fs;
use std::os::unix::fs::PermissionsExt;
use std::path::PathBuf;
use std::process::Command;
use std::sync::{Mutex, MutexGuard};

use tempfile::TempDir;

/// Tests that use a sandbox run one at a time. Executing a script while another thread is forking can fail with "Text
/// file busy" (ETXTBSY) if that thread's child still holds the script open for writing from when it was created.
static SANDBOX_LOCK: Mutex<()> = Mutex::new(());

/// A directory with stand-ins for the commands the shims call. They log what they were called with into the directory,
/// which is available to them as `$SANDBOX`.
pub struct Sandbox {
    dir: TempDir,
    _lock: MutexGuard<'static, ()>,
}

impl Sandbox {
    pub fn new() -> Self {
        // A failed test poisons the lock, which doesn't affect the others
        let lock = SANDBOX_LOCK.lock().unwrap_or_else(|poisoned| poisoned.into_inner());
        let sandbox = Self {
            dir: tempfile::tempdir().unwrap(),
            _lock: lock,
        };
        fs::create_dir(sandbox.bin_dir()).unwrap();
        sandbox
    }

    fn bin_dir(&self) -> PathBuf {
        self.dir.path().join("bin")
    }

    /// Adds a command in front of the real ones
    pub fn stub(&self, name: &str, script: &str) {
        let path = self.bin_dir().join(name);
        fs::write(&path, format!("#!/bin/sh\n{script}\n")).unwrap();
        fs::set_permissions(&path, fs::Permissions::from_mode(0o755)).unwrap();
    }

    /// Contents of a file written by a stub, empty if it wasn't written
    pub fn read(&self, name: &str) -> String {
        fs::read_to_string(self.dir.path().join(name)).unwrap_or_default()
    }

    /// Prepares running a shim (`CARGO_BIN_EXE_<name>`) with the stubs in front of the PATH
    pub fn command(&self, shim: &str) -> Command {
        let path = format!("{}:{}", self.bin_dir().display(), env::var("PATH").unwrap());
        let mut command = Command::new(shim);
        command
            .env("PATH", path)
            .env("SANDBOX", self.dir.path())
            .env_remove("GIT_SHIM_ACTIVE");
        command
    }
}
