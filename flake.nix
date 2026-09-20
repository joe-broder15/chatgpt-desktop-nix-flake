{
  description = "ChatGPT Desktop packaged from the official x86_64 Linux Debian release";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs = { self, nixpkgs }:
    let
      eachSystem = nixpkgs.lib.genAttrs [ "x86_64-linux" ];
    in
    {
      packages = eachSystem (system:
        let
          pkgs = import nixpkgs {
            inherit system;
            # ChatGPT is proprietary; allow only this package rather than
            # requiring callers to enable all unfree packages globally.
            config.allowUnfreePredicate = pkg:
              nixpkgs.lib.getName pkg == "chatgpt-desktop";
          };
        in
        {
          chatgpt-desktop = pkgs.callPackage ./package.nix { };
          default = self.packages.${system}.chatgpt-desktop;
        });
    };
}
