(import (scheme base))
(import (only (gauche base)
              add-load-path use current-load-path string-scan
              keyword? gauche-version print class-of
              ))
(import (only (gauche version) version<=?))
(add-load-path "." :relative)

;; for gcbench
(use srfi-9-mod :prefix srfi-9:)
;(import (prefix (srfi-9-lib) srfi-9:)) ; *** ERROR: syntax-error: the form can appear only in the toplevel

;; get a script file path
(define fpath (current-load-path))

;; for dynamic
(define symbol?-orig symbol?)
(define symbol?      symbol?)
(define keyword?     keyword?)

;; for dynamic and gcbench
(cond
 ((string-scan fpath "dynamic")
  (unless (symbol? ':key1)
    (set! symbol? (lambda (s) (or (keyword? s) (symbol?-orig s))))
    (print "'symbol?' was redefined.")))
 ((string-scan fpath "gcbench")
  (when (version<=? (gauche-version) "0.9.4")
    (set! define-record-type srfi-9:define-record-type)
    (print "'define-record-type' was redefined.")))
 )

