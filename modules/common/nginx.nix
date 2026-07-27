{ ... }:
{
  security.acme.acceptTerms = true;
  security.acme.defaults.email = "acme@as62028.de";

  services.nginx = {
    enable = true;
    enableReload = true;
    recommendedOptimisation = true;
    recommendedProxySettings = true;
    recommendedTlsSettings = true;
    recommendedGzipSettings = true;
  };

  # Disable logs
  services.nginx.appendHttpConfig = ''
    access_log off;
    error_log /dev/null emerg;
  '';
  services.logrotate.settings.nginx.enable = false;
}
