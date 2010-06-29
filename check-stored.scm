(import (rnrs)
        (memcached)
        (mosh control)
        (mosh test)
        (mosh file)
        (shorten)
        (mosh))

(define (main args)
  (let ([mc (memcached-connect (cadr args) "11211")]
        [line* (map (^x (read (open-string-input-port x))) (file->list "/home/taro/Desktop/zipcode.sexp"))])
    (for-each
     (^l
      (test-eqv (cadr l) (memcached-get mc (car l))))
     line*)))

(main (command-line))
