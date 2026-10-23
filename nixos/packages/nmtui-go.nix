{ lib, buildGoModule, fetchFromGitHub }:

buildGoModule rec {
  pname = "nmtui-go";
  version = "0.2.7";

  src = fetchFromGitHub {
    owner = "doeixd";
    repo = "nmtui-go";
    rev = "v${version}";
    hash = "sha256-2X1npAiE4OvlLQgdDKLCAWdjG3yZcVst7Q+ZyI2IYys=";
  };

  vendorHash = "sha256-FYrLLZHd7C98LzmIUuEpJxLEqT2j/7GWHTcjNRRV4xY=";

  # The test suite talks to NetworkManager/D-Bus, which is not available
  # in the build sandbox.
  doCheck = false;

  ldflags = [
    "-s"
    "-w"
    "-X main.Version=${version}"
  ];

  # main is ./cmd, so go builds a binary named "cmd".
  postInstall = ''
    mv $out/bin/cmd $out/bin/nmtui-go
  '';

  meta = {
    description = "TUI for managing NetworkManager Wi-Fi connections";
    homepage = "https://github.com/doeixd/nmtui-go";
    license = lib.licenses.mit;
    mainProgram = "nmtui-go";
    platforms = lib.platforms.linux;
  };
}
