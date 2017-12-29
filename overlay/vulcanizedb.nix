{ stdenv, buildGoPackage, fetchFromGitHub, dep, postgresql100 }:

buildGoPackage rec {
  name = "vulcanizedb-${version}";
  version = "0.1";

  goPackagePath = "github.com/vulcanize/vulcanizedb";

  src = fetchFromGitHub {
    owner = "vulcanize";
    repo = "vulcanizedb";
    rev = "2a597fb43dd658dd017406ee47c52b2646045947";
    sha256 = "0bvmbzj13msnz1ni8kc1ilaj4lbyibmp5y5vnsk92ilrc7zf5rxn";
  };

  preBuild = ''
    cd $NIX_BUILD_TOP/go/src/github.com/vulcanize/vulcanizedb
    ${dep}/bin/dep ensure
  '';

  extraSrcs = [
    {
      goPackagePath = "gopkg.in/godo.v2/cmd/godo";
      src = fetchFromGitHub {
        owner = "go-godo";
        repo = "godo";
        rev = "v1.4.5";
        sha256 = "0mj9k33jksrh4smralwshrjmc0iiqw4nm2rh16qs92n2q9r79s0c";
      };
    }
    {
     goPackagePath = "github.com/ethereum/go-ethereum";
     src = fetchFromGitHub {
       owner = "ethereum";
       repo = "go-ethereum";
       rev = "v1.7.3";
       sha256 = "1w6rbq2qpjyf2v9mr18yiv2af1h2sgyvgrdk4bd8ixgl3qcd5b11";
     };
    }
  ];

  meta = with stdenv.lib; {
    homepage = http://github.com/vulcanize/VulcanizeDB;
    description = "Vulcanize DB";
    license = [licenses.asl20];
  };
}
