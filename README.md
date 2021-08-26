# lightning-nix

This is a collection of [nix](https://nixos.org/) packages and modules for running a Bitcoin Lightning node.

## Intro

My node is running [lnd](https://github.com/lightningnetwork/lnd) and [bitcoind](https://bitcoin.org/en/full-node) on a Raspberry Pi 4. 
More resources regarding operating a lightning node can be found [here](https://github.com/aljazceru/lightning-network-node-operator).
How to install NixOS to Raspberry is documented [here](https://nix.dev/tutorials/installing-nixos-on-a-raspberry-pi).

You might want to check out [nix-bitcoin](https://github.com/fort-nix/nix-bitcoin) too. I've "stolen" quite a bit of stuff from there, but
since then the code diverged a bit. The difference is more philosophical in a sense that this is using [Nix Flakes](https://www.tweag.io/blog/2020-05-25-flakes/)
to be sort of a library of resources that you can use instead of directly being an application. Which means that for using
this you will have to still write some Nix code. Also I am a bit more biased towards [Lightning Labs](https://lightning.engineering) solutions (but that doesn't
mean I am againt including c-lightning or something else - it's just that the current node is running lnd and I support that implementation).

Warning: this is more of DIY experiment with Nix!

Alternatives for running a node using Raspberry Pi are [RaspiBlitz](https://shop.fulmo.org) and [Umbrel](https://getumbrel.com/).

## Usage

First install Nix2.4+ (with flake support)

```bash
# Interactively install the latest version of Nix
if ! type -p nix; then
    sh <(curl -L https://github.com/numtide/nix-flakes-installer/releases/latest/download/install)
fi

# Configure Nix
mkdir -p ~/.config/nix
if ! test -f ~/.config/nix/nix.conf || ! grep -q experimental-features ~/.config/nix/nix.conf; then
    echo 'experimental-features = ca-references flakes nix-command' >>~/.config/nix/nix.conf
fi
```
