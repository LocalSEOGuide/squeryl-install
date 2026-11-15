# Install Squeryl

Squeryl tracks how AI answers talk about your brands. It runs on your own computer or server, and you need a license
to use it. Your license key came by email, and installing sends a code to that same address.

## On a Mac
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

## With an AI assistant
If you use an AI assistant that can run commands on your computer, you can give it this prompt instead:

> Install Squeryl on this computer by following
> https://raw.githubusercontent.com/LocalSEOGuide/squeryl-install/main/AI-INSTALL.md

Your assistant works from [AI-INSTALL.md](AI-INSTALL.md), and you still finish setup yourself in your browser, so your passwords
never go through it. Assistants we have tested are listed there.

## On Linux
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

## On Windows, or for a whole team on a server
Not ready yet. A server install with its own web address and HTTPS, for everyone in a team, is coming.

## Uninstall
Open **Terminal** (or, on Linux, a terminal) and run:

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

Your Projects, prompts, answers and sign-ins are deleted. The `backups` folder in `Squeryl` stays, and your settings are
saved into it, so you can restore a backup on a new installation later; the uninstall prints the two commands for that.
Your license key keeps working: installing again sends a new code to your email.

To remove every last trace, after `--delete-data`:

1. Move the `Squeryl` folder in your home folder to the Trash, or on Linux run `rm -rf ~/Squeryl`. This deletes your
   backups too, so copy any you want to keep somewhere else first.
2. Delete Squeryl's image: in Docker Desktop, open **Images** and delete `ghcr.io/localseoguide/squeryl-tracker`. Or,
   on any computer, run:

   ```sh
   docker images --format '{{.Repository}}:{{.Tag}}' \
     ghcr.io/localseoguide/squeryl-tracker |
     xargs docker image rm
   ```

Delete the folder only after `--delete-data`. Without it, Squeryl's data stays inside Docker, and the folder holds the
command that removes it.

## Need help?
Write to support@localseoguide.com.
