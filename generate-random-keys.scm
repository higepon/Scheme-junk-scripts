(import (rnrs)
        (mosh)
        (mosh control)
        (srfi :27))

(random-source-randomize!  default-random-source)
(do ([i 0 (+ i 1)])
    [(= i 5000000)]
  (let1 n (random-integer 100000000)
    (format #t "(\"~a\" . \"~a\")\n" n n)))
