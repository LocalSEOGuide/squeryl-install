# Installing Squeryl: instructions for an AI assistant

You are helping someone install Squeryl on their own computer. Follow these steps in order, and do nothing beyond them.
Use plain words: they may never have used a terminal. Before each step that changes anything, say in a sentence what you are
about to do.

If you cannot run commands on this computer, give the person one command at a time and wait for what it prints.

**Tested with:** none yet.

## Never ask for these
The verification code, a DataForSEO login or password, and a Squeryl password all go in the browser, by the person. If they
paste one into this conversation, tell them it isn't needed here and that they may want to change it. Don't use it.

You don't complete the browser steps, even if you can control a browser.

## 1. Check the computer
This installer works on a Mac. On anything else, say that isn't ready yet, and stop.

Run `docker info`. If Docker Desktop isn't installed or isn't running:
- Send the person to https://www.docker.com/products/docker-desktop/ to install it. They accept Docker's terms and enter
  their own password, so don't install it for them, by Homebrew or any other way.
- Have them open it once, and wait until they say it is running.
- Run `docker info` again to confirm.

## 2. Get the license key
Ask for their Squeryl license key, which came by email. It looks like `XXXXXX-XXXXXX-XXXXXX-XXXXXX-XXXXXX-V3`. They can paste it
here, or if they would rather not, save it in a text file and tell you its path. If they paste it, save it to a temporary
file yourself and remove that file after step 3.

## 3. Install
Download the installer, read it, and tell the person in a sentence what it does. Then run it, with the key file:

```sh
curl -fsSL https://raw.githubusercontent.com/LocalSEOGuide/squeryl-install/main/install.sh -o squeryl-install.sh
SQUERYL_LICENSE_KEY_FILE=PATH-TO-THE-KEY-FILE sh squeryl-install.sh
```

The first run downloads Squeryl, which can take a few minutes.

If it says Squeryl isn't ready to install yet, tell the person that, and stop. Don't look for another version to install.

## 4. Hand over the link
It prints a link beginning `http://localhost:`. Give that link to the person, and don't open or use it yourself. Tell them
what the browser will ask for:
1. The terms, and their license, already filled in.
2. A code emailed to the address on their license. Setup can't go on without it. If that mailbox is someone else's, they ask
   that person for the code. The link keeps working, so they can close the page and come back to it once they have the code.
3. A sign-in, only if their license is for several people: the email address and password they will sign in to Squeryl with.
4. Their DataForSEO API login and password, from https://app.dataforseo.com/api-access. They pay DataForSEO directly.
5. Which AI engines to use.
6. Their first Project.

## 5. See it through
Everything lives in the `Squeryl` folder in their home folder. When they say they have gone through setup, run:

```sh
cd ~/Squeryl && ./squeryl status
```

It ends with one next step. Explain it in plain words, and repeat until it says nothing needs doing. Then suggest that, in Docker
Desktop's settings, they turn on starting it when they sign in, because Squeryl only collects while this computer is awake
and Docker Desktop is running.

## If something goes wrong
Stop, and don't improvise. In particular:
- Don't delete containers, images, volumes or the `Squeryl` folder, and don't run `./squeryl uninstall` or `./squeryl restore`, unless
  the person asks you to after you have explained what it would lose.
- Don't edit `install.sh`, `squeryl`, `compose.yaml` or `.env` to get past an error.

Show them what `./squeryl status` says, which prints no passwords, and offer to draft an email for them to send to
support@localseoguide.com, with what you tried and what it printed.
