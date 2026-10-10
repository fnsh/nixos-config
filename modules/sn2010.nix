{ ... }:
{
  # Use console
  boot.kernelParams = [ "console=ttyS0,115200n8" ];

  # Retain interface names from driver
  services.udev.extraRules = ''
    SUBSYSTEM=="net", ACTION=="add", DRIVERS=="mlxsw_spectrum*", NAME="sw$attr{phys_port_name}"
  '';
}
