let
  liv = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIF3LjfcgNu9tvj6eMtYWiNwRJR4cGALF0590FswEkrlL liv@fw13";
  noxnox = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJfwrD05VmFMorcHkXOnJqsEyougYiYAeg82zH8rw52+ noxnox for ffda";
  dbauer = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILo6qga0Xl+/Epn9NgNNZMWmXGVAa7A34WaG5YLOprqe 🐼@dbauer-t470";

  users = [
    liv
    noxnox
    dbauer
  ];

  router1 = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDAi7LCTZVz0vyELvkd2IAm2fPkchIVI7+HIKx59Yj4N";
  nat64 = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICLqV5V8uPuXgv1lbI7gul9CGRHZnG/QZcf+t6TFXf7/";
  monitoring = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIc8JKu8qi7b+DF4QP7yOoAqwQxmPPP1DhBRettufkpj";
  collector = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBADt66s4wm4IO0n9BrEbQOOojw2Koa/06xMwwoCfF5Z";
  gw1 = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINe5WsN0wnoDSSdzPPjujSOgMNNz3ThNx7qsVfbEFxOF";
  gw2 = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIM6YooIThu21c8o4qe43DHx9hf4qyaK0TnOYb6DKvkl/";
  gw3 = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHfhzFVgtystt1A0wTIh/p89eOb98KSt0lSR7g3l/dZt";
  gw4 = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAenHXkA3FvxYzCOhiHJYPByCr3FmfVy8w9NpxFinQ5T";
  gw5 = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINtztTsBGlcHkPD4gBDhKzNPuKlMs/FOGUAd+M08RZC8";
  gw6 = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFxxgAvQOdjo5JP05BjbG2VYZ5CkeShUQj3LzwEp/7C1";
  gw7 = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKNwbi5D1VIYIyYA8tRGhQlaBTEFdTRYCZFArrNjUSkn";
  gw8 = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPWZBkTomW2MljmOZk3SE18AZPyTg+CRLWIOXWtRlwRi";

  all_systems = [
    router1
    nat64
    monitoring
    collector
    gw1
    gw2
    gw3
    gw4
    gw5
    gw6
    gw7
    gw8
  ];
in
{
  "monitoring_ingress.age".publicKeys = users ++ all_systems;

  "fastd_key_gw1.age".publicKeys = users ++ [ gw1 ];
  "fastd_key_gw2.age".publicKeys = users ++ [ gw2 ];
  "fastd_key_gw3.age".publicKeys = users ++ [ gw3 ];
  "fastd_key_gw4.age".publicKeys = users ++ [ gw4 ];
  "fastd_key_gw5.age".publicKeys = users ++ [ gw5 ];
  "fastd_key_gw6.age".publicKeys = users ++ [ gw6 ];
  "fastd_key_gw7.age".publicKeys = users ++ [ gw7 ];
  "fastd_key_gw8.age".publicKeys = users ++ [ gw8 ];

  "bmc_pass.age".publicKeys = users ++ [ collector ];
  "once_username.age".publicKeys = users ++ [ collector ];
  "once_pass.age".publicKeys = users ++ [ collector ];
  "grafana_smtp_pass.age".publicKeys = users ++ [ monitoring ];
  "ovh_backup_creds.age".publicKeys = users ++ [ monitoring ];
}
