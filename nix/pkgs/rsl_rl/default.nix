{ lib
, fetchFromGitHub
, buildPythonPackage
, numpy
, pytorch
, torchvision
}:

buildPythonPackage rec {
  pname = "rsl_rl";
  version = "2022.03.14";

  src = fetchFromGitHub {
    owner = "leggedrobotics";
    repo = pname;
    rev = "c712131a60ee16ee037f46876d781b5335c90c5d";
    hash = "sha256-E0owbudsXduO//dogd611vyH6487ISs7z0JhcE6U1PE=";
  };

  propagatedBuildInputs = [
    numpy
    pytorch
    torchvision
  ];

  meta = with lib; {
    homepage = "https://github.com/leggedrobotics/rsl_rl";
    description = ''
      Fast and simple implementation of RL algorithms, designed to run fully on GPU
    '';
    license = licenses.bsd3;
    maintainers = with maintainers; [ breakds ];
    platforms = with platforms; linux;
  };
}
