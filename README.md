# ChatGPT Desktop Nix flake

This flake packages an official x86_64 Linux ChatGPT Debian release stored as
`chatgpt_amd64.deb` in this repository. Git-backed flakes include only tracked
files, so stage the artifact before building:

```sh
git add chatgpt_amd64.deb
```

Then build or run it:

```sh
nix build .#chatgpt-desktop
nix run .#chatgpt-desktop
```

The package is deliberately limited to `x86_64-linux`, because it consumes the
official x64 Debian artifact.
