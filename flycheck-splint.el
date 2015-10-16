;;; flycheck-splint.el --- Integrate splint with flycheck

;; Copyright (c) 2015 Alex Murray
;;
;; Author: Alex Murray <murray.alex@gmail.com>
;; Maintainer: Alex Murray <murray.alex@gmail.com>
;; URL: https://github.com/alexmurray/flycheck-splint
;; Version: 0.1
;; Package-Requires: ((flycheck "0.24") (emacs "24.4"))

;; This file is not part of GNU Emacs.

;; This program is free software: you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or
;; (at your option) any later version.

;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with this program.  If not, see <http://www.gnu.org/licenses/>.

;;; Commentary:

;; Integrate splint with flycheck

;;; Code:
(require 'flycheck)

(defcustom flycheck-splint-arguments
  '("-showfunc" "-hints" "+quiet")
  "Argument to pass to splint.")

(defvar flycheck-splint--irony-relative-include-regex
  "^-I ?\\."
  "Regular expression to detect include path options using a relative path from `irony'.")

(flycheck-define-checker splint
  "A checker using splint.

See `http://www.splint.org/'."
  :command ("splint"
            (eval flycheck-splint-arguments)
            ;; try get compile options from irony if it is enabled
            (eval (when irony-mode
                    (mapcar #'(lambda (s) (if (string-match-p flycheck-splint--irony-relative-include-regex s)
                                         (replace-regexp-in-string
                                          flycheck-splint--irony-relative-include-regex
                                          (concat "-I" irony--working-directory ".")
                                          s)
                                       s))
                            irony--compile-options)))
            source)
  :error-patterns ((warning line-start (file-name) ":" line ":" column ":"
                            (message (minimal-match (one-or-more anything)))
                            line-end)
                   (warning line-start (file-name) "(" line "," column "):"
                            (message (minimal-match (one-or-more anything)))
                            line-end)
                   (warning line-start (file-name) ":" line ":"
                            (message (minimal-match (one-or-more anything)))
                            line-end)
                   (warning line-start (file-name) "(" line "):"
                            (message (minimal-match (one-or-more anything)))
                            line-end))
  :modes c-mode)

(provide 'flycheck-split)

;;; flycheck-splint.el ends here
