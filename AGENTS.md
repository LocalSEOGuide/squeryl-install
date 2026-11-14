# AGENTS.md — squeryl-install

**This repository is public, and so is this file.** Keep anything internal out of it: no secrets, tokens, server names,
customer names or plans.

**Helping someone install Squeryl?** You don't need to change anything here. Follow [AI-INSTALL.md](AI-INSTALL.md).

## Changing this repository
It holds one small starter, kept short so that anyone can read it before running it. `install.sh` checks Docker, makes
the folder, downloads the image, copies the real installer out of that image and runs it. The real installer travels
inside each image, so it always matches the version it installs: fixes to the installer belong there, not here.

- **Plain `sh` only.** It runs on customers' machines, usually piped from `curl`.
- **Nothing it runs may read from stdin**, because when piped, stdin is the script itself. That is why each command that
  could read has `</dev/null`.
- **Each release changes one line:** `RELEASE` in `install.sh`. While it is empty, the starter says Squeryl isn't ready yet
  and stops before asking for anything; `SQUERYL_VERSION` overrides it for testing.
- **No token or secret, ever, even disguised.** GitHub revokes a token pushed to a public repository. The image's read token
  comes from the license service, for whoever holds a license key.
- **`AI-INSTALL.md` is followed by other people's assistants.** Keep it to installing, and list an assistant under "Tested with" only
  after a real test.
- **Stay readable:** the README invites people to read the script, so a clever line costs more here than a long one.
- **Show the whole of every command.** GitHub doesn't wrap a code block: a long line scrolls sideways, and macOS hides the
  scrollbar, so the page can show less than the copy button copies. Keep each line of a command in a document short, and
  give the part that runs something (`| sh`) and anything a reader must fill in (`SQUERYL_VERSION=…`) a line of their own,
  ending the line before it with `\` or `|`. Then only an address can ever be cut short, which a reader can see.
- **Prove a change** by piping the script into `sh`, using a folder of your own (`SQUERYL_DIR`), an image already on the machine
  (`SQUERYL_VERSION`), a key in a file (`SQUERYL_LICENSE_KEY_FILE`) and a stand-in service (`SQUERYL_LICENSE_SERVICE`), then read what it
  printed as a customer would.
- **Changes go through a pull request.** People run this script straight from `main`, so a person reviews each change.
