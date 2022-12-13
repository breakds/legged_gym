{
  description = "Issac Gym Environments for Legged Robots";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs?rev=ac455609648554cf2fb40d9d1ce030202b0921b7";

    utils.url = "github:numtide/flake-utils";

    ml-pkgs.url = "github:nixvital/ml-pkgs/compatible/nvidia-isaac";
    ml-pkgs.inputs.nixpkgs.follows = "nixpkgs";
    ml-pkgs.inputs.utils.follows = "utils";
  };

  outputs = { self, nixpkgs, ... }@inputs: {
    overlays = {
      default = nixpkgs.lib.composeManyExtensions [
        inputs.ml-pkgs.overlays.torch-family
        inputs.ml-pkgs.overlays.simulators
        (final: prev: {
          pythonPackagesExtensions = prev.pythonPackagesExtensions ++ [
            (python-final: python-prev: {
              rsl-rl = python-final.callPackage ./nix/pkgs/rsl_rl {
                pytorch = python-final.pytorchWithCuda11;
                torchvision = python-final.torchvisionWithCuda11;
              };
            })
          ];
        })
      ];
    };
  } // inputs.utils.lib.eachSystem [
    "x86_64-linux"
  ] (system:
    let pkgs = import nixpkgs {
          inherit system;
          config.allowUnfree = true;
          overlays = [ self.overlays.default ];
        };
    in {
      devShells.default = let
        legged-gym-pyenv = pkgs.python38.withPackages (pyPkgs: with pyPkgs; [
          pytorchWithCuda11
          isaac-gym
          rsl-rl
          matplotlib
        ]);
        pythonIcon = "f3e2";
      in pkgs.mkShell rec {
        name = "legged-gym";
        
        packages = [
          legged-gym-pyenv
          pkgs.ninja  # issac_gym.gymtorch
        ];

        shellHook = ''
          export PS1="$(echo -e '\u${pythonIcon}') {\[$(tput sgr0)\]\[\033[38;5;228m\]\w\[$(tput sgr0)\]\[\033[38;5;15m\]} (${name}) \\$ \[$(tput sgr0)\]"
        '';
      };
    });
}
