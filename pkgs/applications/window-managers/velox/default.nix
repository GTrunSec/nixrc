{ lib, stdenv, fetchFromGitHub, pkgconfig, makeWrapper, newScope
, libxkbcommon, wayland, pixman, fontconfig, libinput
, stConf ? null, stPatches ? []
}:

let
  callPackage = newScope scope;
  scope = {
    swc = (callPackage ./swc.nix {}).overrideAttrs (o: {
      src = fetchFromGitHub {
        owner = "bqv";
        repo = "swc";
        rev = "b26b054b843e5f163da896954850073ec8c91071";
        sha256 = "1gx8z4398z4w0iz110al531vcj5hxmzhxfppdfng9gj2zvyv4lvb";
        # date = 2020-07-07T20:23:08+01:00;
      };
      makeFlags = o.makeFlags + " ENABLE_XWAYLAND=1";
    });
    wld = callPackage ./wld.nix {};
    dmenu-velox = callPackage ./dmenu.nix {};
    st-velox = callPackage ./st.nix {
      conf = stConf;
      patches = stPatches;
    };
  };
in stdenv.mkDerivation rec {
  name = "velox-${version}";
  version = lib.substring 0 7 src.rev;

  src = fetchFromGitHub {
    owner = "michaelforney";
    repo = "velox";
    rev = "f5b0042427d5925ba29437cc25343e8ac7b4d721";
    sha256 = "0zmc3i2an72f6zddsaf0j37q6v3njs6zk7swchrh1dq0ll7jmiav";
    # date = 2019-12-20T23:47:50-08:00;
  };

  nativeBuildInputs = [ pkgconfig makeWrapper ];

  buildInputs = with scope; [ swc libxkbcommon wld wayland pixman fontconfig libinput ];

  propagatedUserEnvPkgs = with scope; [ swc ];

  makeFlags = "PREFIX=$(out)";
  preBuild = ''
    substituteInPlace config.c \
      --replace /etc/velox.conf $out/etc/velox.conf
  '';
  installPhase = ''
    PREFIX=$out make install
    mkdir -p $out/etc
    cp velox.conf.sample $out/etc/velox.conf
  '';
  postFixup = with scope; ''
    wrapProgram $out/bin/velox \
      --prefix PATH : "${stdenv.lib.makeBinPath [ dmenu-velox st-velox ]}"
  '';

  enableParallelBuilding = false; # https://hydra.nixos.org/build/79799608

  passthru = scope;

  meta = {
    description = "velox window manager";
    homepage    = "https://github.com/michaelforney/velox";
    license     = lib.licenses.mit;
    platforms   = lib.platforms.linux;
    maintainers = with lib.maintainers; [ ];
  };
}
