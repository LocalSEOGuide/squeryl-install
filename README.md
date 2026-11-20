# Squeryl

Squeryl tracks how AI answers talk about your brands. It runs on your own computer or server, and you need a license
to use it. Your license key came by email, and installing sends a code to that same address.

- [Install](#install): [on a Mac](#on-a-mac) · [with an AI assistant](#with-an-ai-assistant) ·
  [on Linux](#on-linux) · [on Windows 11](#on-windows-11)
- [Update](#update)
- [Uninstall](#uninstall)
- [Need help?](#need-help)

## Install

### On a Mac
1. Install [Docker Desktop](https://www.docker.com/products/docker-desktop/) and open it once.
2. Open **Terminal** (press Command + Space and type Terminal), then run:

   ```sh
   curl -fsSL \
     https://raw.githubusercontent.com/LocalSEOGuide/squeryl-install/main/install.sh |
     sh
   ```

   If you were given a private version of Squeryl to install, run this instead, with the version you were given in place
   of `<private-image-tag>`:

   ```sh
   curl -fsSL \
     https://raw.githubusercontent.com/LocalSEOGuide/squeryl-install/main/install.sh |
     SQUERYL_VERSION=<private-image-tag> sh
   ```

3. Paste your license key when it asks.
4. Open the link it prints. It walks you through the terms, your email code and the rest of setup.

This puts everything in a `Squeryl` folder in your home folder, and the guide is in there as `README.md`. Prefer to read
a script before running it? [install.sh](install.sh) is short.

### With an AI assistant
If you use an AI assistant that can run commands on your computer, you can give it this prompt instead:

> Install Squeryl on this computer by following
> https://raw.githubusercontent.com/LocalSEOGuide/squeryl-install/main/AI-INSTALL.md

Your assistant works from [AI-INSTALL.md](AI-INSTALL.md), and you still finish setup yourself in your browser, so your passwords
never go through it. Assistants we have tested are listed there.

### On Linux
1. Install [Docker Engine](https://docs.docker.com/engine/install/) with its Compose plugin, or
   [Docker Desktop](https://docs.docker.com/desktop/setup/install/linux/), and start it. To use Docker without `sudo`,
   your account needs to be in the `docker` group: the installer tells you if it isn't, and how to add it.
2. In a terminal, run the same command as on a Mac (step 2 above), as yourself rather than with `sudo`.
3. Paste your license key when it asks, and open the link it prints.

Squeryl answers only on the computer it is installed on, at `http://localhost`. On a server you reach over SSH, the
installer prints one more command to run on your own computer, which opens a private tunnel to it, so the link works
in your own browser. Squeryl keeps collecting while the server and Docker run; it does not need the tunnel for that.

Already run a reverse proxy and want Squeryl at an address of your own? Once it is installed, the `README.md` in your
`Squeryl` folder says what to set, under "Reaching it from other computers".

### On Windows 11
1. Install [Docker Desktop](https://www.docker.com/products/docker-desktop/) and open it once.
2. Open **PowerShell** (press the Windows key, type PowerShell and press Enter), as yourself rather than as an
   administrator, then run:

   ```powershell
   irm https://raw.githubusercontent.com/LocalSEOGuide/squeryl-install/main/install.ps1 |
     iex
   ```

   If you were given a private version of Squeryl to install, run this instead, with the version you were given in place
   of `<private-image-tag>`:

   ```powershell
   $env:SQUERYL_VERSION = '<private-image-tag>'
   irm https://raw.githubusercontent.com/LocalSEOGuide/squeryl-install/main/install.ps1 |
     iex
   ```

3. Paste your license key when it asks, and open the link it prints.

This puts everything in a `Squeryl` folder in your user folder, with the guide in it as `README.md`. Prefer to read the
script first? [install.ps1](install.ps1) is short.

### For a whole team on a server
Not ready yet. A server install with its own web address and HTTPS, for everyone in a team, is coming.

## Update
Squeryl does not update by itself. When there is a new version, open **Terminal** (on Windows, **PowerShell**; on
Linux, a terminal) and run this, with the new version's number in place of `<version>`:

```sh
cd ~/Squeryl
./squeryl update <version>
```

If you were given a private version of Squeryl, run this instead, with the version you were given in place of
`<private-image-tag>`:

```sh
cd ~/Squeryl
./squeryl update <private-image-tag>
```

Squeryl needs to be running (`./squeryl start` if it isn't). It backs up first, then moves to the new version, and your
data, settings and license carry over. `./squeryl status` shows which version you are on.

### Going back
If the new version does not start, or you would rather stay on the one before, run:

```sh
cd ~/Squeryl
./squeryl rollback
```

This returns to the version you had before the last update. If that update changed how your data is stored, the data
goes back to the backup taken just before it, and anything added since is set aside.

## Uninstall
Open **Terminal** (on Windows, **PowerShell**; on Linux, a terminal) and run:

```sh
cd ~/Squeryl
./squeryl uninstall
```

This stops Squeryl and removes it, but keeps all of its data, so `./squeryl start` brings it back just as it was.

### Deleting your data too
To delete Squeryl's data from this computer as well, run this instead, and type `delete` when it asks:

```sh
cd ~/Squeryl
./squeryl uninstall --delete-data
```

Your Brands, Campaigns, prompts, answers and sign-ins are deleted. The `backups` folder in `Squeryl` stays, and your settings are
saved into it, so you can restore a backup on a new installation later; the uninstall prints the two commands for that.
Your license key keeps working: installing again sends a new code to your email.

To remove every last trace, after `--delete-data`:

1. Move the `Squeryl` folder in your home folder to the Trash (on Windows, delete it in File Explorer), or on Linux run
   `rm -rf ~/Squeryl`. This deletes your backups too, so copy any you want to keep somewhere else first.
2. Delete Squeryl's image: in Docker Desktop, open **Images** and delete `ghcr.io/localseoguide/squeryl-tracker`. Or,
   on a Mac or Linux, run:

   ```sh
   docker images --format '{{.Repository}}:{{.Tag}}' \
     ghcr.io/localseoguide/squeryl-tracker |
     xargs docker image rm
   ```

Delete the folder only after `--delete-data`. Without it, Squeryl's data stays inside Docker, and the folder holds the
command that removes it.

## Need help?
Write to support@localseoguide.com.
