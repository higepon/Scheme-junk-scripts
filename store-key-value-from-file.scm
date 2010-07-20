;; Stores (key, value) pair to memcached.
;; (key, value) pair are in data file as list of (key value)
(import (rnrs)
        (only (srfi :1) list-ref split-at! take drop)
        (mosh control)
        (mosh concurrent)
        (mosh file)
        (memcached)
        (shorten)
        (mosh))

(define *data-file* "/home/taro/Desktop/zipcode.sexp")
(define *number-of-processes* 3)
(define *unit-size* 500)
(define *hosts* '#("10.12.4.40" "10.12.4.41" "10.12.4.42" "10.12.4.43"))
; "10.12.4.42" "10.12.4.43" "10.12.4.44"
;                   "10.12.4.45" "10.12.4.46" "10.12.4.47" "10.12.4.48" "10.12.4.49"))


(define (start-worker host* line*)
  (spawn (^(line*+host*)
           ;; line* is list of (key . value)
           (define (insert! host port line* num-line*-insert)
             (let1 mc (memcached-connect host port)
               (do ([i 0 (+ i 1)]
                    [line* line* (cdr line*)])
                   [(or (= i num-line*-insert) (null? line*))
                    (memcached-close mc)
                    line*]
                 (memcached-set! mc (car (car line*)) 0 "10" (cdr (car line*))))))

           (define (insert-all line* host* unit-size)
             (random-source-randomize! default-random-source)
             (let loop ([i (random-integer 1000)]
                        [j 0]
                        [line* line*])
               (cond
                [(null? line*) '()]
                [else
                 (let1 host (vector-ref host* (mod i (vector-length host*)))
                   (format #t "~a:~d\n" host (* j unit-size))
                   (let1 rest (insert! host "11211" line* unit-size)
                     (loop (+ i 1) (+ j 1) rest)))])))

           (match line*+host*
             [(line* host*)
              (insert-all line* host* 500)
              ]))
         (list line* host*)
         '((srfi :27) (rnrs) (mosh concurrent) (memcached) (mosh control) (shorten) (match) (mosh))))


(define (main args)
  (let* ([lines (map (^x (read (open-string-input-port x))) (file->list (cadr args)))]
         [lines-count-per-process (div (length lines) *number-of-processes*)])
    (let loop ([line* lines]
               [pid* '()])
      (cond
       [(null? line*)
        (for-each join! pid*)
        (display "done")
        (newline)]
       [else
        (let-values (([head tail] (if (< (length line*) lines-count-per-process) (values line* '()) (split-at! line* lines-count-per-process))))
          (let1 pid (start-worker *hosts* head)
            (loop tail (cons pid pid*))))]))))

(main (command-line))
