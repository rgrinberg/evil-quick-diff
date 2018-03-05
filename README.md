# evil-quick-diff

This is a replacement for the
[linediff.vim](https://github.com/AndrewRadev/linediff.vim) plugin. It's not a
faithful port, as it uses ediff for diffing, but the spirit is the same.

The implementation itself is heavily based on
[evil-exchange](https://github.com/Dewdrops/evil-exchange/).

The default operator key for diffing is `god`. While `goD` is used for canceling.

## Installation

```lisp
(use-package evil-quick-diff
  :init
  ;; change default key bindings (if you want) HERE
  ;; (setq evil-quick-diff-key (kbd "zx"))
  (evil-quick-diff-install))
```

## Customization

You can change the default bindings by customizing `evil-quick-diff-key` and/or
`evil-quick-diff-cancel-key` before `evil-quick-diff-install` is called.

## Wish List

* Support linewise and wordwise diffing. Ediff doesn't seem to have a convenient
  way to do this easily.
  
* Support diffing post pretty-printing. To diff things such sexpressions easily.
