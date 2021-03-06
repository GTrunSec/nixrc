{ config, lib, usr, pkgs, ... }:

{
  emacs-loader.auctex = {
    demand = true;
    defer = true;
    after = [ "tex" "latex" ];
    config = ''
      (TeX-global-PDF-mode t)
    '';
  };
}
