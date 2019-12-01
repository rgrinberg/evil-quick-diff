;;; evil-quick-diff.el --- Diff selections in evil -*- lexical-binding: t; coding: utf-8 -*-

;; Author: Rudi Grinberg <rudi.grinberg@gmail.com>
;; URL: http://github.com/rgrinberg/evil-quick-diff
;; Package-Version: 20170510.1959
;; Version: 0.0.1
;; Keywords: evil, plugin
;; Package-Requires: ((evil "1.2.14") (cl-lib "0.3"))

;;; Commentary:
;;
;; Port of https://github.com/AndrewRadev/linediff.vim

;;; Code:

;; The code to handle evil selections taken from:
;; https://github.com/Dewdrops/evil-exchange/

(require 'evil)

(defgroup evil-quick-diff nil
  "Quick diffing of Evil selections."
  :prefix "evil-quick-diff"
  :group 'evil)

(defcustom evil-quick-diff-key (kbd "god")
  "Operator for evil-quick-diff."
  :type `,(if (get 'key-sequence 'widget-type)
              'key-sequence
            'sexp)
  :group 'evil-quick-diff)

(defcustom evil-quick-diff-cancel-key (kbd "goD")
  "Cancel evil-quick-diff."
  :type `,(if (get 'key-sequence 'widget-type)
              'key-sequence
            'sexp)
  :group 'evil-quick-diff)

(defcustom evil-quick-diff-highlight-face 'highlight
  "Face used to highlight marked area."
  :type 'sexp
  :group 'evil-quick-diff)

(defvar evil-quick-diff--position nil "Text position which will be diffed.")

(defvar evil-quick-diff--overlays nil "Overlays used to highlight marked area.")

(defun evil-quick-diff--highlight (beg end)
  "Highlight the region defined by `BEG' and `END' with the quick diff face."
  (let ((o (make-overlay beg end nil t nil)))
    (overlay-put o 'face evil-quick-diff-highlight-face)
    (add-to-list 'evil-quick-diff--overlays o)))

(defun evil-quick-diff--clean ()
  "Delete overlays created by quick-diff to mark regions that will be diffed."
  (setq evil-quick-diff--position nil)
  (mapc 'delete-overlay evil-quick-diff--overlays)
  (setq evil-quick-diff--overlays nil))

(defun evil-quick-diff--cleanup-buffers ()
  "Remove the temporary buffers created by quick-diff."
  (ignore-errors (kill-buffer " *evil-quick-diff-1*"))
  (ignore-errors (kill-buffer " *evil-quick-diff-2*")))

(defun evil-quick-diff--ediff-setup ()
  "Setup cleaning after ediff is exitted."
  (add-hook 'ediff-quit-hook #'evil-quick-diff--cleanup-buffers))

(defun evil-quick-diff--do-diff (curr-buffer orig-buffer curr-beg curr-end
                                             orig-beg orig-end extract-fn)
  "Create a diff from 2 selections.

First selection is defined in CURR-BUFFER and spanned by CURR-BEG and CURR-END,
second selection is ORIG-BUFFER spanned by ORIG-BEG and ORIG-END. EXTRACT-FN is
the function used for extracting the selection from those ranges."
  (evil-quick-diff--cleanup-buffers)
  (let ((text1
         (with-current-buffer orig-buffer (funcall extract-fn orig-beg orig-end)))
        (text2
         (with-current-buffer curr-buffer (funcall extract-fn curr-beg curr-end)))
        (buf1 (get-buffer-create " *evil-quick-diff-1*"))
        (buf2 (get-buffer-create " *evil-quick-diff-2*")))
    (progn
      (with-current-buffer " *evil-quick-diff-1*"
        (goto-char (point-min))
        (insert text1))
      (with-current-buffer " *evil-quick-diff-2*"
        (goto-char (point-min))
        (insert text2))
      (evil-quick-diff--clean)
      (ediff-buffers buf1 buf2 '(evil-quick-diff--ediff-setup)))))

(evil-define-operator evil-quick-diff (beg end type)
  "Ediff two regions with evil motion."
  :move-point nil
  (interactive "<R>")
  (let ((beg-marker (copy-marker beg t))
        (end-marker (copy-marker end nil)))
    (if (null evil-quick-diff--position)
        ;; call without evil-quick-diff--position set: store region
        (progn
          (setq evil-quick-diff--position (list (current-buffer) beg-marker end-marker type))
          ;; highlight area marked to diff
          (if (eq type 'block)
              (evil-apply-on-block #'evil-quick-diff--highlight beg end nil)
            (evil-quick-diff--highlight beg end)))
      ;; secondary call: do diff
      (cl-destructuring-bind
          (orig-buffer orig-beg orig-end orig-type) evil-quick-diff--position
        (cond
         ;; diff block region
         ((and (eq orig-type 'block) (eq type 'block))
          (evil-quick-diff--do-diff
           (current-buffer) orig-buffer
           beg-marker end-marker
           orig-beg orig-end
           #'buffer-substring))
         ;; signal error if regions incompatible
         ((or (eq orig-type 'block) (eq type 'block))
          (user-error "TODO this is compatible"))
         ;; diff normal region
         (t
          (evil-quick-diff--do-diff
           (current-buffer) orig-buffer
           beg-marker end-marker
           orig-beg orig-end
           #'buffer-substring))))))
  ;; place cursor on beginning of line
  (when (and (called-interactively-p 'any) (eq type 'line))
    (evil-first-non-blank)))

;;;###autoload
(autoload 'evil-quick-diff "evil-quick-diff"
  "Ediff two regions with evil motion." t)
;;;###autoload
(autoload 'evil-quick-diff-cancel "evil-quick-diff-cancel"
  "Cancel evil-quick-diff and remove selections." t)

(evil-define-command evil-quick-diff-cancel ()
  "Cancel current pending diff."
  (interactive)
  (if (null evil-quick-diff--position)
      (message "No pending diff")
    (evil-quick-diff--clean)
    (message "Diff canceled")))

;;;###autoload
(defun evil-quick-diff-install ()
  "Setting evil-quick-diff key bindings."
  (define-key evil-normal-state-map evil-quick-diff-key 'evil-quick-diff)
  (define-key evil-visual-state-map evil-quick-diff-key 'evil-quick-diff)
  (define-key evil-normal-state-map
    evil-quick-diff-cancel-key 'evil-quick-diff-cancel)
  (define-key evil-visual-state-map
    evil-quick-diff-cancel-key 'evil-quick-diff-cancel))

(provide 'evil-quick-diff)
;;; evil-quick-diff.el ends here
