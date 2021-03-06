{ stdenv, fetchFromGitHub, python3Packages, openssl }:

with python3Packages;

buildPythonApplication rec {
  version = "unstable-2017-09-19";
  name = "keeper";

  src = fetchFromGitHub {
    rev = "a316db1dc13288e417a6582eeb10b714863af8d5";
    owner = "makerdao";
    repo = "keeper";
    sha256 = "069q85a3icsnmzhy9ifh9f0x996sagbgwzgam4wnh7avh6z10qmj";
  };

  propagatedBuildInputs = [
    pytest web3 eth-testrpc sortedcontainers networkx tinydb
  ];

  doCheck = false;

  installPhase = ''
    mkdir -p $out/bin
    mkdir -p $out/${python.sitePackages}
    cp -r keeper $out/${python.sitePackages}
    cp bin/* $out/bin
  '';

  fixupPhase = ''
    for x in $out/bin/*; do wrapProgram "$x" \
      --set PYTHONPATH "$PYTHONPATH:$out/${python.sitePackages}" \
      --set PATH ${python}/bin:$PATH
    done
  '';

  meta = with stdenv.lib; {
    description = "Maker Keeper framework";
    homepage = https://github.com/makerdao/keeper;
    license = licenses.agpl3;
    platforms = platforms.unix;
    maintainers = with maintainers; [ dbrock ];
  };
}
