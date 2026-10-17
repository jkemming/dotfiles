pub mod git;
pub mod sudo;

use std::env;
use std::error::Error as StdError;
use std::ffi::OsStr;
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
    let path = env::var_os("PATH").unwrap_or_default();
    Ok(Command::new(find_real(name, &this, &path)?))
}

fn find_real(name: &OsStr, this: &Path, path: &OsStr) -> Result<PathBuf> {
    let this_id = file_id(this)?;

    for dir in env::split_paths(path) {
        // An empty `PATH` entry stands for the current directory
        let dir = if dir.as_os_str().is_empty() {
            PathBuf::from(".")
        } else {
            dir
        };
        let candidate = dir.join(name);
        if is_executable(&candidate) && file_id(&candidate).is_ok_and(|id| id != this_id) {
            return Ok(candidate);
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

#[cfg(test)]
mod tests {
    use super::*;
    use std::os::unix::fs::{PermissionsExt, symlink};

    fn write_executable(dir: &Path, name: &str, mode: u32) -> PathBuf {
        let path = dir.join(name);
        fs::write(&path, "#!/bin/sh\n").unwrap();
        fs::set_permissions(&path, fs::Permissions::from_mode(mode)).unwrap();
        path
    }

    fn join_paths(dirs: &[&Path]) -> std::ffi::OsString {
        env::join_paths(dirs).unwrap()
    }

    #[test]
    fn find_real_skips_the_shim_itself() {
        let shim_dir = tempfile::tempdir().unwrap();
        let real_dir = tempfile::tempdir().unwrap();
        let shim = write_executable(shim_dir.path(), "tool", 0o755);
        let real = write_executable(real_dir.path(), "tool", 0o755);

        let path = join_paths(&[shim_dir.path(), real_dir.path()]);
        assert_eq!(find_real("tool".as_ref(), &shim, &path).unwrap(), real);
    }

    #[test]
    fn find_real_skips_symlinks_to_the_shim() {
        let shim_dir = tempfile::tempdir().unwrap();
        let link_dir = tempfile::tempdir().unwrap();
        let real_dir = tempfile::tempdir().unwrap();
        let shim = write_executable(shim_dir.path(), "tool", 0o755);
        symlink(&shim, link_dir.path().join("tool")).unwrap();
        let real = write_executable(real_dir.path(), "tool", 0o755);

        let path = join_paths(&[link_dir.path(), real_dir.path()]);
        assert_eq!(find_real("tool".as_ref(), &shim, &path).unwrap(), real);
    }

    #[test]
    fn find_real_skips_files_which_are_not_executable() {
        let shim_dir = tempfile::tempdir().unwrap();
        let plain_dir = tempfile::tempdir().unwrap();
        let real_dir = tempfile::tempdir().unwrap();
        let shim = write_executable(shim_dir.path(), "tool", 0o755);
        write_executable(plain_dir.path(), "tool", 0o644);
        let real = write_executable(real_dir.path(), "tool", 0o755);

        let path = join_paths(&[plain_dir.path(), real_dir.path()]);
        assert_eq!(find_real("tool".as_ref(), &shim, &path).unwrap(), real);
    }

    #[test]
    fn find_real_fails_if_there_is_only_the_shim() {
        let shim_dir = tempfile::tempdir().unwrap();
        let shim = write_executable(shim_dir.path(), "tool", 0o755);

        let err = find_real("tool".as_ref(), &shim, shim_dir.path().as_os_str()).unwrap_err();
        assert_eq!(err.to_string(), "real tool not found on PATH");
    }
}
