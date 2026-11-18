# Bootstrapping a new machine

The dotfiles repository is cloned over SSH, so on a fresh machine the SSH key has to be put in place by hand before the repository can be cloned. Once it is cloned, continue with the install steps in the [README](../README.md).

1. Create the SSH directory and paste the private and public key into their files (e.g. from the password manager):

   ```shell
   mkdir ~/.ssh
   nano ~/.ssh/id_ed25519
   nano ~/.ssh/id_ed25519.pub
   ```

2. Restrict the private key's permissions, otherwise SSH refuses to use it:

   ```shell
   chmod 600 ~/.ssh/id_ed25519
   ```

3. Clone the repository into the expected location under `~/Projects/Repositories`:

   ```shell
   mkdir -p ~/Projects/Repositories/github.com/jkemming
   cd ~/Projects/Repositories/github.com/jkemming
   git clone git@github.com:jkemming/dotfiles.git
   ```

After that, follow the [manual setup](manual-setup.md) for the settings that can't be synced.
