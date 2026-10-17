use std::env;
use std::error::Error as StdError;
use std::fs;
use std::os::unix::fs::MetadataExt;
use std::path::{Path, PathBuf};
use std::process::Command;

pub type Error = Box<dyn StdError>;
pub type Result<T> = std::result::Result<T, Error>;

/// Builds a command for the real counterpart of the running shim, i.e. the first executable with the same name on the
/// `PATH` which isn't the shim itself.
pub fn real_command() -> Result<Command> {
    let this = env::current_exe()?;
    let name = this.file_name().ok_or("shim has no file name")?;
    let this_id = file_id(&this)?;

    for dir in env::split_paths(&env::var_os("PATH").unwrap_or_default()) {
        // An empty `PATH` entry stands for the current directory
        let dir = if dir.as_os_str().is_empty() { PathBuf::from(".") } else { dir };
        let candidate = dir.join(name);
        if is_executable(&candidate) && file_id(&candidate).is_ok_and(|id| id != this_id) {
            return Ok(Command::new(candidate));
        }
    }

    Err(format!("real {} not found on PATH", name.to_string_lossy()).into())
}

/// Identifies a file independent of the path it was reached through (symlinks, relative paths)
fn file_id(path: &Path) -> Result<(u64, u64)> {
    let metadata = fs::metadata(path)?;
    Ok((metadata.dev(), metadata.ino()))
}

fn is_executable(path: &Path) -> bool {
    fs::metadata(path).is_ok_and(|metadata| metadata.is_file() && metadata.mode() & 0o111 != 0)
}
