(module hash-store mzscheme
  (require (lib "contract.ss")
           (lib "file.ss")
           (lib "etc.ss")
           (lib "base64.ss" "net")
           (planet "digest.ss" ("soegaard" "digest.plt" 1 2)))
  
  ;; SHA1
  (base64-filename-safe)
  (define SHA1
    (compose (lambda (i) (regexp-replace #"\r\n" i #""))
             base64-encode
             sha1))
  
  ;; Interface
  ; exn:fail:hash-store:exists
  (define-struct (exn:fail:hash-store:exists exn:fail) ())
  
  ; hash-store : path?
  (define-struct hash-store (path))
  
  ; create : path? -> hash-store?
  (define (create p)
    (make-directory* p)
    (make-hash-store p))
  
  ; store! : hash-store? bytes? -> bytes?
  (define (store! ht bs)
    (define _hash (SHA1 bs))
    (define hash (if (bytes=? #"" _hash)
                     #"$empty$" _hash))
    (define new-path (build-path (hash-store-path ht) (bytes->path hash)))
    (unless (file-exists? new-path)
      (with-output-to-file
          new-path
        (lambda ()
          (write bs))))
    hash)
  
  ; lookup : hash-store? bytes? -> bytes?
  (define (lookup ht hash)
    (define new-path (build-path (hash-store-path ht) (bytes->path hash)))
    (with-handlers ([exn:fail:filesystem? 
                     (lambda (e)
                       (raise (make-exn:fail:hash-store:exists "Key not in store" (current-continuation-marks))))])
      (with-input-from-file
          new-path
        read)))
  
  (provide/contract 
   [SHA1 (bytes? . -> . bytes?)]
   [exn:fail:hash-store:exists? (any/c . -> . boolean?)]
   [hash-store? (any/c . -> . boolean?)]
   [create (path? . -> . hash-store?)]
   [store! (hash-store? bytes? . -> . bytes?)]
   [lookup (hash-store? bytes? . -> . bytes?)]))