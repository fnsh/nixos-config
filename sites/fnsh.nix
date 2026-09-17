{ lib, ... }:
let
  firstDomain = 1;
  lastDomain = 20;

  mkDomain =
    id:
    lib.nameValuePair "dom${toString id}" {
      inherit id;
      fastdPort = 10000 + (id * 10);

      vxlan.interface = "vxlan-dom${toString id}";
      vxlan.port = 2000 + id;

      batInterface = "bat-dom${toString id}";
      subnet4 = "10.${toString (id * 10)}";

      subnet6.public = "2a13:fcc0:2ed8:10${lib.fnsh.paddedHexOctet id}";
      subnet6.ula = "fd01:67c:2ed8:10${lib.fnsh.paddedHexOctet id}";

      nextnode = {
        v6 = "fd01:67c:2ed8:10${lib.fnsh.paddedHexOctet id}::1:1";
        v4 = "10.${toString (id * 10)}.0.254";
      };
    };

in
lib.mkMerge [
  {
    fnsh.sites.fnsh = {
      name = "Freie Netze Suedhessen";
      domains = lib.listToAttrs (map mkDomain (lib.range firstDomain lastDomain));
    };
  }
  {
    # Overrides for testing domain
    fnsh.sites.fnsh.domains.dom20 = {
      subnet4 = lib.mkForce null;
      nextnode.v6 = lib.mkForce "2a13:fcc0:2ed8:1014::1:1";
      aliases = [
        {
          code = "fnsh_dom20";
          human_name = "Domain 20";
        }
        {
          code = "fnsh_yolo";
          human_name = "Test-Domain";
        }
      ];
    };

    fnsh.sites.fnsh.domains = {
      dom1.aliases = [
        {
          code = "fnsh_dom1";
          human_name = "Domain 1";
        }
        {
          code = "fnsh_dom1";
          human_name = "Domain 1";
        }
        {
          code = "fnsh_default";
          human_name = "Default";
        }
        {
          code = "fnsh_da_110";
          human_name = "Darmstadt: Stadtzentrum";
        }
        {
          code = "fnsh_da_120";
          human_name = "Darmstadt: Mollerstadt";
        }
        {
          code = "fnsh_da_130";
          human_name = "Darmstadt: Hochschulviertel";
        }
        {
          code = "fnsh_da_210";
          human_name = "Darmstadt: Johannesviertel";
        }
        {
          code = "fnsh_da_220_230";
          human_name = "Darmstadt: Martinsviertel";
        }
        {
          code = "fnsh_da_270";
          human_name = "Darmstadt: Bürgerparkviertel";
        }
        {
          code = "fnsh_da_310";
          human_name = "Darmstadt: Am Oberfeld";
        }
        {
          code = "fnsh_da_320";
          human_name = "Darmstadt: Mathildenhöhe";
        }
      ];
      dom2.aliases = [
        {
          code = "fnsh_dom2";
          human_name = "Domain 2";
        }
        {
          code = "fnsh_da_240";
          human_name = "Darmstadt: Waldkolonie";
        }
        {
          code = "fnsh_da_250";
          human_name = "Darmstadt: Mornewegviertel";
        }
        {
          code = "fnsh_da_260";
          human_name = "Darmstadt: Pallaswiesenviertel";
        }
        {
          code = "fnsh_da_530";
          human_name = "Darmstadt: Verlegerviertel";
        }
        {
          code = "fnsh_da_540";
          human_name = "Darmstadt: Am Kavalleriesand";
        }
      ];
      dom3.aliases = [
        {
          code = "fnsh_dom3";
          human_name = "Domain 3";
        }
        {
          code = "fnsh_da_140";
          human_name = "Darmstadt: Kapellplatzviertel";
        }
        {
          code = "fnsh_da_150";
          human_name = "Darmstadt: St. Ludwig mit Eichbergviertel";
        }
        {
          code = "fnsh_da_330";
          human_name = "Darmstadt: Woogsviertel";
        }
        {
          code = "fnsh_da_340";
          human_name = "Darmstadt: An den Lichtwiesen";
        }
        {
          code = "fnsh_da_410";
          human_name = "Darmstadt: Paulusviertel";
        }
        {
          code = "fnsh_da_420";
          human_name = "Darmstadt: Alt-Bessungen";
        }
      ];
      dom4.aliases = [
        {
          code = "fnsh_dom4";
          human_name = "Domain 4";
        }
        {
          code = "fnsh_da_430";
          human_name = "Darmstadt: An der Ludwigshöhe";
        }
        {
          code = "fnsh_da_440";
          human_name = "Darmstadt: Lincoln-Siedlung";
        }
        {
          code = "fnsh_da_510";
          human_name = "Darmstadt: Am Südbahnhof";
        }
        {
          code = "fnsh_da_520";
          human_name = "Darmstadt: Heimstättensiedlung";
        }
      ];
      dom5.aliases = [
        {
          code = "fnsh_dom5";
          human_name = "Domain 5";
        }
        {
          code = "fnsh_da_610_620_630";
          human_name = "Darmstadt: Arheilgen";
        }
        {
          code = "fnsh_da_910_920";
          human_name = "Darmstadt: Kranichstein";
        }
        {
          code = "fnsh_da_810_820";
          human_name = "Darmstadt: Wixhausen";
        }
        {
          code = "fnsh_64390";
          human_name = "Erzhausen";
        }
      ];
      dom6.aliases = [
        {
          code = "fnsh_dom6";
          human_name = "Domain 6";
        }
        {
          code = "fnsh_64521";
          human_name = "Groß-Gerau";
        }
        {
          code = "fnsh_64546";
          human_name = "Mörfelden-Walldorf";
        }
        {
          code = "fnsh_64572";
          human_name = "Büttelborn";
        }
        {
          code = "fnsh_64569";
          human_name = "Nauheim";
        }
        {
          code = "fnsh_65468";
          human_name = "Trebur";
        }
      ];
      dom7.aliases = [
        {
          code = "fnsh_dom7";
          human_name = "Domain 7";
        }
        {
          code = "fnsh_64579";
          human_name = "Gernsheim";
        }
        {
          code = "fnsh_64560";
          human_name = "Riedstadt";
        }
        {
          code = "fnsh_64589";
          human_name = "Stockstadt am Rhein";
        }
        {
          code = "fnsh_64584";
          human_name = "Biebesheim am Rhein";
        }
      ];
      dom8.aliases = [
        {
          code = "fnsh_dom8";
          human_name = "Domain 8";
        }
        {
          code = "fnsh_64625";
          human_name = "Babenhausen";
        }
      ];
      dom9.aliases = [
        {
          code = "fnsh_dom9";
          human_name = "Domain 9";
        }
        {
          code = "fnsh_64347";
          human_name = "Griesheim";
        }
        {
          code = "fnsh_64331";
          human_name = "Weiterstadt";
        }
      ];
      dom10.aliases = [
        {
          code = "fnsh_dom10";
          human_name = "Domain 10";
        }
        {
          code = "fnsh_64807";
          human_name = "Dieburg";
        }
        {
          code = "fnsh_64409";
          human_name = "Messel";
        }
        {
          code = "fnsh_64839";
          human_name = "Münster (Hessen)";
        }
        {
          code = "fnsh_64859";
          human_name = "Eppertshausen";
        }
      ];
      dom11.aliases = [
        {
          code = "fnsh_dom11";
          human_name = "Domain 11";
        }
        {
          code = "fnsh_64846";
          human_name = "Groß-Zimmern";
        }
        {
          code = "fnsh_64380";
          human_name = "Roßdorf (bei Darmstadt)";
        }
        {
          code = "fnsh_64354";
          human_name = "Reinheim";
        }
        {
          code = "fnsh_64401";
          human_name = "Groß-Bieberau";
        }
      ];
      dom12.aliases = [
        {
          code = "fnsh_dom12";
          human_name = "Domain 12";
        }
        {
          code = "fnsh_64853";
          human_name = "Otzberg";
        }
        {
          code = "fnsh_64823";
          human_name = "Groß-Umstadt";
        }
        {
          code = "fnsh_64850";
          human_name = "Schaafheim";
        }
      ];
      dom13.aliases = [
        {
          code = "fnsh_dom13";
          human_name = "Domain 13";
        }
        {
          code = "fnsh_64297";
          human_name = "Darmstadt-Eberstadt";
        }
        {
          code = "fnsh_64342";
          human_name = "Seeheim-Jugenheim";
        }
        {
          code = "fnsh_64665";
          human_name = "Alsbach-Hähnlein";
        }
        {
          code = "fnsh_64319";
          human_name = "Pfungstadt";
        }
        {
          code = "fnsh_64404";
          human_name = "Bickenbach";
        }
        {
          code = "fnsh_64673";
          human_name = "Zwingenberg";
        }
      ];
      dom14.aliases = [
        {
          code = "fnsh_dom14";
          human_name = "Domain 14";
        }
        {
          code = "fnsh_64372";
          human_name = "Ober-Ramstadt";
        }
        {
          code = "fnsh_64397";
          human_name = "Modautal";
        }
        {
          code = "fnsh_64367";
          human_name = "Mühltal";
        }
        {
          code = "fnsh_64405";
          human_name = "Fischbachtal";
        }
      ];
      dom15.aliases = [
        {
          code = "fnsh_dom15";
          human_name = "Domain 15";
        }
        {
          code = "fnsh_63303";
          human_name = "Dreieich";
        }
        {
          code = "fnsh_63225";
          human_name = "Langen";
        }
        {
          code = "fnsh_63329";
          human_name = "Egelsbach";
        }
      ];
      dom16.aliases = [
        {
          code = "fnsh_dom16";
          human_name = "Domain 16";
        }
        {
          code = "fnsh_63128";
          human_name = "Dietzenbach";
        }
        {
          code = "fnsh_63110";
          human_name = "Rodgau";
        }
        {
          code = "fnsh_63322";
          human_name = "Rödermark";
        }
        {
          code = "fnsh_63500";
          human_name = "Seligenstadt";
        }
        {
          code = "fnsh_63533";
          human_name = "Mainhausen";
        }
      ];
      dom17.aliases = [
        {
          code = "fnsh_dom17";
          human_name = "Domain 17";
        }
        {
          code = "fnsh_64732";
          human_name = "Bad König";
        }
        {
          code = "fnsh_64747";
          human_name = "Breuberg";
        }
        {
          code = "fnsh_64711";
          human_name = "Erbach";
        }
        {
          code = "fnsh_64720";
          human_name = "Michelstadt";
        }
        {
          code = "fnsh_64395";
          human_name = "Brensbach";
        }
        {
          code = "fnsh_64753";
          human_name = "Brombachtal";
        }
        {
          code = "fnsh_64407";
          human_name = "Fränkisch-Crumbach";
        }
        {
          code = "fnsh_64739";
          human_name = "Höchst im Odenwald";
        }
        {
          code = "fnsh_64750";
          human_name = "Lützelbach";
        }
        {
          code = "fnsh_64756";
          human_name = "Mossautal";
        }
        {
          code = "fnsh_64385";
          human_name = "Reichelsheim (Odenwald)";
        }
      ];
      dom18.aliases = [
        {
          code = "fnsh_dom18";
          human_name = "Domain 18";
        }
        {
          code = "fnsh_da_540_kelley";
          human_name = "Darmstadt: Kelley-Barracks";
        }
      ];
      dom19.aliases = [
        {
          code = "fnsh_dom19";
          human_name = "Domain 19";
        }
        {
          code = "fnsh_da_530_hh36";
          human_name = "Darmstadt: Holzhofallee 36";
        }
      ];
    };
  }
]
