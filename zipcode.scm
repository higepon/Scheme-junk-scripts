;; Convert zipcode data to S-expression for my purpose
;;   www.post.japanpost.jp/zipcode/download.html
(import (rnrs)
        (only (srfi :1) list-ref)
        (mosh control)
        (mosh file)
        (shorten)
        (mosh))

(define (r x)
  (read (open-string-input-port x)))

(let ([line* (file->list "/home/taro/Downloads/ken_all.csv")]
      [ht (make-eqv-hashtable)])
  (for-each
   (^(line)
     (let* ([x (string-split line #\,)]
            [zipcode (r (list-ref x 2))]
            [address (string-append (r (list-ref x 6)) (r (list-ref x 7))  (r (list-ref x 8)))])
       (cond
        [(hashtable-ref ht zipcode) '()]
        [else
         (format #t "(~a ~a)\n" zipcode address)
         (hashtable-set! ht zipcode #t)])))
   line*))
