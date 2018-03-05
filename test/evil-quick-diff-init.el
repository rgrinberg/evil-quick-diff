(require 'undercover)
(undercover "evil-quick-diff")

(require 'ert)
(require 'f)
(require 'el-mock)

(defmacro csetq (variable value)
  `(funcall (or (get ',variable 'custom-set)
                'set-default)
            ',variable ,value))

(defvar evil-quick-diff-test/test-path
  (f-dirname (f-this-file)))

(defvar evil-quick-diff-test/root-path
  (f-parent evil-quick-diff-test/test-path))

(defvar evil-quick-diff-test/vendor-path
  (f-expand "vendor" evil-quick-diff-test/root-path))

;; (unload-feature 'evil-quick-diff 'force)

(load (f-expand "evil-quick-diff" evil-quick-diff-test/root-path))
