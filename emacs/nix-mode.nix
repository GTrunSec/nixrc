{ config, lib, usr, pkgs, ... }:

{
  emacs-loader.nix-mode = {
    demand = true;
    config = ''
      (setq nix-repl-executable-args '("repl" "${pkgs.path}"))
    '' + ''
      (setq nix-indent-function 'nix-indent-line)

      (defmacro defcmd (name body &rest cdr)
        `(defun ,name () (interactive) ,body ,@cdr))

      (defun unwords (ss)
        (s-join " " ss))

      (setq nixos-running-p nil)
      (defun nixos-sentinel (process signal)
        (when (memq (process-status process) '(exit signal))
          (message "NixOS job finished!")
          (setq check-nixos t)
          (setq nixos-running-p nil)
          (shell-command-sentinel process signal)))

      (defun nixos (cmd)
        (let* ((output-buffer "*nixos*")
               (proc (progn
                       (setq nixos-running-p t)
                       (message (s-lex-format "Starting NixOS job: ''${cmd}"))
                       (async-shell-command cmd output-buffer)
                       (get-buffer-process output-buffer))))
          (if (process-live-p proc)
              (set-process-sentinel proc #'nixos-sentinel)
            (message "No NixOS process running."))))

      (defun nixos-with-args (cmd)
        (nixos (unwords (cons cmd (transient-args 'nixos-dispatch)))))

      (defcmd nixos-garbage-collect
        (nixos-with-args "sudo nix-collect-garbage"))

      (defcmd nixos-rebuild
        (nixos-with-args "sudo nix-channel --update nixpkgs; sudo nixos-rebuild switch"))

      (defcmd nixos-check-vulnerabilities
        (nixos "sudo vulnix --system"))

      (define-infix-argument nixos:--delete-older-than ()
        :description "delete older than"
        :class 'transient-option
        :shortarg "-d"
        :argument "--delete-older-than ")

      (define-infix-argument nixos:--tarball-ttl ()
        :description "tarball cache lifetime (seconds)"
        :class 'transient-option
        :shortarg "-t"
        :argument "--option tarball-ttl ")

      (defcmd nix-store-verify
        (nixos "sudo nix-store --verify --check-contents"))

      (defcmd nix-store-repair
        (nixos "sudo nix-store --verify --check-contents --repair"))

      (defcmd nix-store-optimize
        (nixos "sudo nix-store --optimise -vv"))

      (defun nix-store-query-dependents (path)
        (interactive "sPath: ")
        (nixos (s-lex-format "sudo nix-store --query --roots ''${path}")))

      (defun nix-store-delete (path)
        (interactive "sPath: ")
        (nixos (s-lex-format "sudo nix-store --delete ''${path}")))

      (defun nixos-search-options (option)
        (interactive "sOption: ")
        (browse-url (s-lex-format "https://nixos.org/nixos/options.html#''${option}")))

      (defun nixos-search-packages (query)
        (interactive "sPackage: ")
        (browse-url (s-lex-format "https://nixos.org/nixos/packages.html?query=''${query}")))

      (defun nixos-howoldis ()
        (interactive)
        (browse-url "https://howoldis.herokuapp.com/"))

      (defun nixos-index ()
        (interactive)
        (nixos "sudo nix-index"))

      (define-transient-command nixos-dispatch ()
        ["Arguments"
         ("-t" "show trace" "--show-trace")
         (nixos:--tarball-ttl)]
        ["NixOS"
         ("r" "rebuild" nixos-rebuild)
         ("o" "search options" nixos-search-options)
         ("p" "search packages" nixos-search-packages)
         ("h" "check channels" nixos-howoldis)
         ("i" "index" nixos-index)]
        ["Garbage collection"
         ("g" "collect garbage" nixos-garbage-collect-dispatch)]
        ["Nix Store"
         ("s v" "verify" nix-store-verify)
         ("s r" "repair" nix-store-repair)
         ("s d" "query dependents" nix-store-query-dependents)
         ("s k" "delete" nix-store-delete)
         ("s o" "optimize" nix-store-optimize)])

      (define-transient-command nixos-garbage-collect-dispatch ()
        ["Garbage collection"
         (nixos:--delete-older-than)
         ("g" "collect garbage" nixos-garbage-collect)])

      (define-infix-argument nixos-flake:host ()
        :description "Host to build"
        :class 'transient-option
        :shortarg "H"
        :argument "--host ")
      (defun nixos-flake:withsudo ()
        (interactive)
        (nixos (unwords (cons "sudo nixos" (transient-args 'nixos-flake)))))
      (defun nixos-flake:asuser ()
        (interactive)
        (nixos (unwords (cons "nixos" (transient-args 'nixos-flake)))))
      (define-transient-command nixos-flake ()
        "Execute nixos flake operations"
        ["Arguments"
         (nixos-flake:host)
         ("T" "Show verbose traces" "--showtrace")
         ("v" "Show verbose logs" "--verbose")
         ("V" "Show noisy logs" "--verynoisy")
         ("L" "Force only local building" "--local")
         ("R" "Force disable local building" "--remote")
         ("K" "Ignore errors" "--keepgoing")]
        ["Operations"
         ("c" "Run flake checks only" "--check")
         ("b" "Attempt to build the system" "--build")
         ("a" "Activate the system now" "--activate")
         ("s" "Set default boot configuration" "--setdefault")
         ("t" "Force tag current configuration only" "--tagactive")]
        ["Execution"
         ("$" "Run privileged" nixos-flake:withsudo)
         ("#" "Run unprivileged" nixos-flake:asuser)]
      )
    '';
  };
}
