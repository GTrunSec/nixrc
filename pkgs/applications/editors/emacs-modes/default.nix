{ stdenv, fetchFromGitHub, ... }:

let
  buildEmacsMode = import ./buildEmacsMode.nix { inherit stdenv; };
in {

  bitwarden = buildEmacsMode rec {
    name = "emacs-bitwarden";
    src = fetchFromGitHub {
      owner = "seanfarley"; repo = name;
      rev = "e03919ca68c32a8053ddea2ed05ecc5e454d8a43";
      sha256 = "1bbxh01856vg8acwrjbq3hyxa81zcvfby7k1j5hdfps918xy10m2";
    };
  };

  ivy-exwm = buildEmacsMode rec {
    name = "ivy-exwm";
    src = fetchFromGitHub {
      owner = "pjones"; repo = name;
      rev = "32f107374aef01b9ae00f1647233d50b4ea659e0";
      sha256 = "1shs1zh8nr2lwxlvrhnhxxjn5g0p21vkjxnjgha1sn07pg7v3iqq";
    };
  };

  flycheck-purescript = buildEmacsMode rec {
    name = "flycheck-purescript";
    src = fetchFromGitHub {
      owner = "bsermons"; repo = name;
      rev = "a3f5e64fe56aedf9703540b4755a2e6e044cbe72";
      sha256 = "0qm048ypfzbrqd4a9ffn1ay3rhh58nacd9z78lph8mmj4ri1v2cc";
    };
  };

  eterm-256color = buildEmacsMode rec {
    name = "eterm-256color";
    src = fetchFromGitHub {
      owner = "dieggsy"; repo = name;
      rev = "0f0dab497239ebedbc9c4a48b3ec8cce4a47e980";
      sha256 = "00ins8n92p5aspr6bjrvn5y5w0ximakk22yklsfmkav4h10al4as";
    };
  };

}