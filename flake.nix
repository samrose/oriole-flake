{
  description = "PostgreSQL 16 with Oriole patches";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    oriole-src =  {
      url = "https://github.com/orioledb/postgres/archive/refs/tags/patches16_23.tar.gz";
      flake = false;
    };
    flake-utils.url = "github:numtide/flake-utils";
    
  };

  outputs = { self, nixpkgs, flake-utils, oriole-src }: let
     ourSystems = with flake-utils.lib; [
      system.x86_64-linux
      system.aarch64-linux
    ];
    in
    flake-utils.lib.eachSystem ourSystems (system:

      let
        psql_16 = final: prev: { 
            postgresql_16 = prev.postgresql_16.overrideAttrs (old: {
              version = "16.2";
              src = oriole-src;
              buildInputs = old.buildInputs ++ [ 
                nixpkgs.legacyPackages.${system}.bison
                nixpkgs.legacyPackages.${system}.docbook5
                nixpkgs.legacyPackages.${system}.docbook_xsl
                nixpkgs.legacyPackages.${system}.docbook_xsl_ns
                nixpkgs.legacyPackages.${system}.docbook_xml_dtd_45
                nixpkgs.legacyPackages.${system}.flex
                nixpkgs.legacyPackages.${system}.libxslt
                nixpkgs.legacyPackages.${system}.perl 
              ];
              doCheck = true;
            });
          };

        pkgs = nixpkgs.legacyPackages.${system}.extend psql_16;
       in rec
      {
        packages = {
          default = pkgs.postgresql_16;
        };
      });

}
