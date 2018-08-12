
;; Indenting module body code at column 0
(defun scheme-module-indent (state indent-point normal-indent) 0)
(put 'module 'scheme-indent-function 'scheme-module-indent)

(put 'and-let* 'scheme-indent-function 1)
(put 'parameterize 'scheme-indent-function 1)
(put 'handle-exceptions 'scheme-indent-function 1)
(put 'when 'scheme-indent-function 1)
(put 'unless 'scheme-indent-function 1)
(put 'match 'scheme-indent-function 1)
(put 'select 'scheme-indent-function 1)
(put 'dotimes 'scheme-indent-function 1)
(put '-> 'scheme-indent-function 1)

(put 'alist-let 'scheme-indent-function 1)

(put 'receive 'scheme-indent-function 2)
(put 'let-location 'scheme-indent-function 1)

(get 'parameterize 'scheme-indent-function)
