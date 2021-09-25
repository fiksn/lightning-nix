{ config, pkgs, lib, ... }:
{
  hardware.enableRedistributableFirmware = true;
  hardware.raspberry-pi."4".fkms-3d.enable = true;
  powerManagement.cpuFreqGovernor = "ondemand";

  boot = {
    kernelPackages = pkgs.linuxPackages_rpi4;
    tmpOnTmpfs = true;
    initrd.availableKernelModules = [ "usbhid" "usb_storage" ];
    # ttyAMA0 is the serial console broken out to the GPIO
    kernelParams = [
      "8250.nr_uarts=1"
      "console=ttyAMA0,115200"
      "console=tty1"
      # Some gui programs need this
      "cma=128M"
    ];

    loader = {
      grub.enable = false;
      # Silence the error
      grub.device = "nodev";
      raspberryPi = {
        enable = true;
        version = 4;
      };
    };
  };

}
