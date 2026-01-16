;;; flymake-jsonlint.el --- Flymake backend for JSON using jsonlint -*- lexical-binding: t; -*-
;;
;; Copyright (C) 2026 Andreas Jonsson
;;
;; Author: Andreas Jonsson <ajdev8@gmail.com>
;; Maintainer: Andreas Jonsson <ajdev8@gmail.com>
;; URL: https://github.com/sonofjon/flymake-jsonlint.el
;; Version: 0.1
;; Package-Requires: ((emacs "29.1"))
;; Keywords: languages, json
;; SPDX-License-Identifier: GPL-3.0-or-later

;;; Commentary:

;; This package provides a Flymake backend for JSON files using jsonlint.
;;
;; The jsonlint program can be installed via npm:
;;
;;    npm install jsonlint -g
;;
;; Usage:
;;
;;   (use-package flymake-jsonlint
;;     :load-path "/path/to/flymake-jsonlint.el"
;;     :hook ((json-ts-mode js-json-mode) . flymake-jsonlint-load))
;;
;; To use flymake-jsonlint together with eglot, add flymake-jsonlint-load
;; to eglot-managed-mode-hook instead:
;;
;;   (use-package flymake-jsonlint
;;     :load-path "/path/to/flymake-jsonlint.el"
;;     :hook (eglot-managed-mode . flymake-jsonlint-load))

;;; Code:

(require 'flymake)

(defgroup flymake-jsonlint nil
  "Flymake backend for JSON using jsonlint."
  :group 'flymake
  :prefix "flymake-jsonlint-")

(defcustom flymake-jsonlint-program "jsonlint"
  "Path to jsonlint executable."
  :group 'flymake-jsonlint
  :type 'string)

(defconst flymake-jsonlint--output-regex
  "line \\([0-9]+\\), col \\([0-9]+\\), \\(.*\\)$"
  "Regex to parse jsonlint output.")

(defun flymake-jsonlint--check-buffer ()
  "Generate a list of diagnostics for the current buffer."
  (let ((code-buffer (current-buffer))
        (code-filename (buffer-file-name))
        (start-line (line-number-at-pos (point-min) t))
        (code-content (without-restriction
                        (buffer-substring-no-properties (point-min) (point-max))))
        (dxs '())
        (program flymake-jsonlint-program))
    (with-temp-buffer
      (insert code-content)
      (let ((args (if code-filename
                      `("--compact" "--stdin-filename" ,code-filename "-")
                    '("--compact" "-"))))
        (apply #'call-process-region (point-min) (point-max)
               program t t nil args))
      (goto-char (point-min))
      (while (search-forward-regexp flymake-jsonlint--output-regex (point-max) t)
        (when (match-string 1)
          (let* ((line (string-to-number (match-string 1)))
                 (col (string-to-number (match-string 2)))
                 (msg (match-string 3))
                 (region (flymake-diag-region code-buffer (1+ (- line start-line)) col))
                 (dx (flymake-make-diagnostic code-buffer (car region) (cdr region)
                                              :error msg)))
            (push dx dxs)))))
    (nreverse dxs)))

(defun flymake-jsonlint--run-checker (report-fn &rest _args)
  "Run checker using REPORT-FN."
  (unless (executable-find flymake-jsonlint-program)
    (error "Cannot find jsonlint executable"))
  (funcall report-fn (flymake-jsonlint--check-buffer)))

;;;###autoload
(defun flymake-jsonlint-load ()
  "Load hook for the current buffer to tell flymake to run checker."
  (interactive)
  (when (derived-mode-p 'js-json-mode 'json-ts-mode)
    (add-hook 'flymake-diagnostic-functions #'flymake-jsonlint--run-checker nil t)))


(provide 'flymake-jsonlint)
;;; flymake-jsonlint.el ends here
