(import (scheme base))
(import (only (gauche base)
              add-load-path use current-load-path string-scan
              keyword? print class-of
              ))
(add-load-path "." :relative)

;; for gcbench
(use srfi-9-mod :prefix srfi-9:)
;(import (prefix (srfi-9-lib) srfi-9:)) ; *** ERROR: syntax-error: the form can appear only in the toplevel

;; get a script file path
(define fpath (current-load-path))

;; for dynamic
(define symbol?-orig symbol?)
(define symbol?      symbol?)

;; for dynamic and gcbench
(cond
 ((string-scan fpath "dynamic")
  (set! symbol? (lambda (s) (or (keyword? s) (symbol?-orig s)))))
 ((string-scan fpath "gcbench")
  (set! define-record-type srfi-9:define-record-type))
 )

