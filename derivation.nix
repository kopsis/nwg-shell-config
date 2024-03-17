{ lib
, fetchFromGitHub
, atk
, gdk-pixbuf
, gobject-introspection
, gtk-layer-shell
, gtk3
, pango
, python310Packages
, wrapGAppsHook
, hyprlandSupport ? true
}:

let
  fs = lib.fileset;
  sourceFiles =
    fs.difference
      ./.
      (fs.unions [
        (fs.maybeMissing ./result)
        (fs.fileFilter (file: file.hasExt "nix") ./.)
      ]);
in

python310Packages.buildPythonApplication rec {
  pname = "nwg-shell-config";
  version = "0.5.35";

  src = fs.toSource {
    root = ./.;
    fileset = sourceFiles;
  };

  nativeBuildInputs = [
    gobject-introspection
    wrapGAppsHook
  ];

  buildInputs = [
    gtk3
  ];

  propagatedBuildInputs = [
    atk
    gdk-pixbuf
    gtk-layer-shell
    pango
    python310Packages.gst-python
    python310Packages.i3ipc
    python310Packages.pygobject3
    python310Packages.geopy
    python310Packages.psutil
  ] ++ lib.optionals hyprlandSupport [
  ];

  dontWrapGApps = true;

  postPatch = ''
    substituteInPlace nwg_shell_config/locker.py --replace '/usr/share' $out/share
    substituteInPlace nwg_shell_config/main_hyprland.py --replace '/usr/share' $out/share
    substituteInPlace nwg_shell_config/main_sway.py --replace '/usr/share' $out/share
    substituteInPlace nwg_shell_config/translate.py --replace '/usr/share' $out/share
    substituteInPlace nwg_shell_config/tools.py --replace '/usr/share/backgrounds' $out/share/backgrounds
    substituteInPlace nwg_shell_config/tools.py --replace '/usr/share/pixmaps' $out/share/pixmaps
  '';

  postInstall = ''
    install -Dm444 nwg-shell-config.svg -t $out/share/icons/hicolor/scalable/apps
    install -Dm444 nwg-shell-config.desktop -t $out/share/applications
  '';

  preFixup = ''
    makeWrapperArgs+=("''${gappsWrapperArgs[@]}");
  '';

  # Upstream has no tests
  doCheck = false;

  meta = {
    homepage = "https://github.com/nwg-piotr/nwg-shell-config";
    description = "nwg-shell configuration utility";
    license = lib.licenses.mit;
    platforms = lib.platforms.linux;
    maintainers = [ ];
    mainProgram = "nwg-shell-config";
  };
}
