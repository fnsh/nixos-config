#!/usr/bin/env bash
set -euf

if [ "$#" -ne 2 ]; then
  echo "Usage: $0 <nixos configuration name> <host>"
  exit 1
fi

machine_name=$1
target_host=$2

echo "Going to install ${machine_name} on ${target_host}"

disko_script=$(nix build --no-link --print-out-paths .#colmenaHive.nodes."${machine_name}".config.system.build.diskoScript)

system_closure=$(nix build --no-link --print-out-paths .#colmenaHive.nodes."${machine_name}".config.system.build.toplevel)

nixos-anywhere --store-paths "${disko_script}" "${system_closure}" --phases disko,install,reboot --target-host "root@${target_host}"
