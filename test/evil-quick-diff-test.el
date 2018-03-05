(require 'evil-quick-diff)
(require 'ert)

(ert-deftest eeq-test-diff-buffers ()
  (with-temp-buffer
    (insert "left right")
    (evil-quick-diff 1 4)
    (with-mock
     (stub split-window)
     (stub make-frame)
     (evil-quick-diff 6 10))
    (should
     (and
      (get-buffer " *evil-quick-diff-1*")
      (get-buffer " *evil-quick-diff-2*")))))
