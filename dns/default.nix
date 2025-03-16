#
# SPDX-FileCopyrightText: 2019 Kirill Elagin <https://kir.elagin.me/>
#
# SPDX-License-Identifier: MPL-2.0 or MIT
#

{ lib }:

let
  dnslib = {
    util = import ./util { inherit lib; };
    inherit types combinators;
  };
  types = import ./types { lib = lib'; };
  lib' = lib // { dns = dnslib; };

  combinators = import ./combinators.nix { lib = lib'; };

  evalZones = zones:
    (lib.evalModules {
      modules = [
        { options = {
            zones = lib.mkOption {
              type = lib.types.attrsOf types.zone;
              description = "DNS zones";
            };
          };
          config = {
            inherit zones;
          };
        }
      ];
    }).config.zones;

  evalZone = name: zone: (evalZones { ${name} = zone; }).${name};

in

{
  inherit evalZones evalZone;

  inherit types;

  inherit combinators;

  inherit (dnslib.util) mkReverseRecord;
}
