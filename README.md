# lightning-nix ![Build](https://github.com/fiksn/lightning-nix/actions/workflows/build/badge.svg)
A collection of [nix](https://nixos.org/) packages and modules for running a Bitcoin Lightning node

## Intro

My node is running [lnd](https://github.com/lightningnetwork/lnd) and [bitcoind](https://bitcoin.org/en/full-node) on a Raspberry Pi 4. 
More resources regarding operating a lightning node can be found [here](https://github.com/aljazceru/lightning-network-node-operator).
How to install NixOS on a Raspberry is documented [here](https://nix.dev/tutorials/installing-nixos-on-a-raspberry-pi).

You might want to check out [nix-bitcoin](https://github.com/fort-nix/nix-bitcoin) too. It's a really great project. I have to admit I've "stolen" quite a bit of stuff from there, but
since then the code diverged a bit. The difference is more philosophical in a sense that this is using [Nix Flakes](https://www.tweag.io/blog/2020-05-25-flakes/)
to be sort of a library of resources that you can use instead of directly being an application. Which means that for using
this you will have to write some Nix code. Also I am a bit more biased towards [Lightning Labs](https://lightning.engineering) solutions (but that doesn't
mean I am againt including c-lightning or something else - it's just that the current node is running lnd and I support that implementation).
Sure the "not invented here syndrome" probably also plays a role here. But at least I've learned a lot about Nix and the lightning network.

!Warning: this is more of DIY experiment with Nix!

Simple alternatives for running a node using Raspberry Pi are [RaspiBlitz](https://shop.fulmo.org) and [Umbrel](https://getumbrel.com/).

## Usage

First install Nix2.4+ (with flake support)

If you don't have Nix yet:

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

if you are already running Nix just make sure to have latest unstable Nix command version (and again enable experimental featues as described above):

```bash
nix-env -f '<nixpkgs>' -iA nixUnstable
```

On NixOS you might want to put this into `configuration.nix`:

```
{ pkgs, ... }: {
  nix = {
    package = pkgs.nixUnstable;
    extraOptions = ''
      experimental-features = ca-references flakes nix-command
    '';
   };
}
```

Then you can do:
```bash
nix flake show
```
to check what is included.

With
```bash
nix profile install 'github:fiksn/lightning-nix#lnd'
nix profile install 'github:fiksn/lightning-nix#bitcoind'
```
you can install relatively new versions of software.

With
```bash
nixos-rebuild switch --flake 'github:fiksn/lightning-nix#node'
```
you can switch to the example machine configuration.

More [flake examples](https://nixos.wiki/wiki/Flakes)

## Support

Feel free to use this in any way you wish. Contributions are also welcome. I am also more than happy to help you or open a channel with you. Note however that I
am not liable for any damages. If you install this on your Raspberry and it explodes or your use this to install latest LND but there is some nasty bug and you lose funds
I am not responsible.

Donations:
[![tippin.me](https://badgen.net/badge/%E2%9A%A1%EF%B8%8Ftippin.me/@fiksn/F0918E)](https://tippin.me/@fiksn)
