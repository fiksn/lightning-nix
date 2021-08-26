{ config, pkgs, lib, ... }:
{
  imports =
    [
      <nixpkgs/nixos/modules/profiles/hardened.nix>
    ];

  # Hardened scudo allocator does not work
  environment.memoryAllocator.provider = lib.mkForce "libc";
  environment.systemPackages = with pkgs; [ dhcp tcpdump nmap git go curl bash bc coreutils curl dos2unix fuse_exfat gnupg htop jq mosh netcat ngrep ntp openssl pssh pv pwgen s3fs screen strace sshfs tig tmux tshark unzip vim wget telnet rsync ncdu ];

  nix = {
    package = pkgs.nixUnstable;
    extraOptions = ''
      experimental-features = nix-command flakes
      keep-outputs = true
    '';
  };

  security.sudo = {
    enable = true;
    wheelNeedsPassword = false;
  };

  services.openssh = {
    enable = true;
    permitRootLogin = "prohibit-password";
    passwordAuthentication = false;
    allowSFTP = true;
    forwardX11 = true;
    openFirewall = true;
  };

  programs.vim.defaultEditor = true;
  environment.interactiveShellInit = ''
    alias vi='vim'
  '';
}
