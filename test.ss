(module test mzscheme
  (require "hash-store.ss")
  
  (define (serialize a)
    (define bp (open-output-bytes))
    (write a bp)
    (get-output-bytes bp))
  (define (deserialize bs)
    (define bp (open-input-bytes bs))
    (read bp))
  (define test (create (build-path "/tmp" (symbol->string (gensym 'ht)))))

  (define X `(123 45 (list shas 12) #"foo" 'bar))
  (define X-id (store! test (serialize X)))
  (define Xp (deserialize (lookup test X-id)))
  
  (printf "~S~n" (list X X-id Xp)))