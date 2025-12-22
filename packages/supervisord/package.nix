{ buildGoModule, fetchFromGitHub, ... }:
buildGoModule (finalAttr: {
  pname = "supervisord";
  version = "0.7.3";
  vendorHash = "sha256-/95gbQEukalpjD+VQbC7elwfga4K2wqfCk7eRx7jhdU=";
  ldflags = [
    "-s"
    "-w"
  ];
  subPackages = [ "." ];
  src = fetchFromGitHub {
    owner = "ochinchina";
    repo = "supervisord";
    rev = "v${finalAttr.version}";
    sha256 = "sha256-TtT8HLRbj+ymZAraMONXobmrVRbl2gKvZFDUHtU0qng=";
  };
})
