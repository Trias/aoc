#!/usr/bin/racket
#lang racket

(require racket/base)
  (require racket/match)
  (require racket/block)
  (require racket/string)
  (require racket/file)

  (define (safe-hash-ref hash key)
    (if (hash-has-key? hash key)
      (hash-ref hash key)
      0
    )
  )
  (define (run program-state) (if
      (or (hash-ref program-state 'halt) (hash-ref program-state 'wait))
      program-state
      (run(compute program-state))))

  (define (get-op-code code)
      (modulo code 100))

  (define (get-mode instruction parameter)
      (if (< (string-length (number->string instruction)) (+ 2 parameter))
          0
          (string->number (string (list-ref (reverse (string->list (number->string instruction))) (+ 1 parameter))))))

  (define (get-value memory ip parameter relative-base)
      (match (get-mode (safe-hash-ref memory ip) parameter)
        [2 (safe-hash-ref memory (+ relative-base (safe-hash-ref memory (+ ip parameter))))]
        [1 (safe-hash-ref memory (+ ip parameter))]
        [0 (safe-hash-ref memory (safe-hash-ref memory (+ ip parameter)))]))

  (define (get-address memory ip parameter relative-base)
      (match (get-mode (safe-hash-ref memory ip) parameter)
        [2 (+ relative-base (safe-hash-ref memory (+ ip parameter)))]
        [1 (raise "error")]
        [0 (safe-hash-ref memory (+ ip parameter))]))

  (define (add memory ip relative-base)
      (hash-set memory (get-address memory ip 3 relative-base) (+ (get-value memory ip 1 relative-base) (get-value memory ip 2 relative-base))))

  (define (mul memory ip relative-base)
      (hash-set memory (get-address memory ip 3 relative-base) (* (get-value memory ip 1 relative-base) (get-value memory ip 2 relative-base))))

  (define (compute program-state)
    (block
      (define ip (hash-ref program-state 'ip))
      (define memory (hash-ref program-state 'memory))
      (define input (hash-ref program-state 'input))
      (define output (hash-ref program-state 'output))
      (define instruction (safe-hash-ref memory ip))
      (define op-code (get-op-code instruction))
      (define instruction-length (get-instruction-length op-code))
      (define relative-base (hash-ref program-state 'relative-base))

      (match op-code
          [1 (hash-set* program-state 
            'memory (add memory ip relative-base)
            'ip (+ ip instruction-length))]
          [2 (hash-set* program-state 
            'memory (mul memory ip relative-base)
            'ip (+ ip instruction-length))]
          [3 (match input
              ['() (hash-set program-state 'wait #t)]
              [(cons head tail)
                (hash-set* program-state 
                  'ip (+ ip instruction-length)
                  'input tail
                  'memory (hash-set memory (get-address memory ip 1 relative-base) head))])]

          [4 (hash-set* program-state 
              'ip (+ ip instruction-length)
              'output (cons (get-value memory ip 1 relative-base) output))]

          [5 (if (not (eq? 0 (get-value memory ip 1 relative-base)))
            (hash-set program-state 'ip (get-value memory ip 2 relative-base))
            (hash-set program-state 'ip (+ ip instruction-length)))]

          [6 (if (eq? 0 (get-value memory ip 1 relative-base))
            (hash-set program-state 'ip (get-value memory ip 2 relative-base))
            (hash-set program-state 'ip (+ ip instruction-length)))]

          [7 (hash-set* program-state 
              'ip (+ ip instruction-length)
              'memory (hash-set memory (get-address memory ip 3 relative-base) (if (< (get-value memory ip 1 relative-base) (get-value memory ip 2 relative-base)) 1 0)))]

          [8 (hash-set* program-state 
            'ip (+ ip instruction-length)
            'memory (hash-set memory (get-address memory ip 3 relative-base) (if (eq? (get-value memory ip 1 relative-base) (get-value memory ip 2 relative-base)) 1 0)))]

          [9 (hash-set* program-state 
              'relative-base (+ relative-base (get-value memory ip 1 relative-base))
              'ip (+ ip instruction-length))]
        
          [99 (hash-set program-state 
              'halt #t)]
              )))

  (define (get-instruction-length code)
      (match code
          [1 4]
          [2 4]
          [3 2]
          [4 2]
          [5 3]
          [6 3]
          [7 4]
          [8 4]
          [9 2]
          [99 0]))

  (define (list->hash lst)
    (list->hash-helper lst (hash) 0))

  (define (list->hash-helper lst acc key)
    (match lst
      ['() acc]
      [(cons head tail) (list->hash-helper tail (hash-set acc key head) (+ key 1))]))

  (define input (list->hash (map string->number (string-split (car (file->lines "input.txt")) ","))))
  (define program-state (hash 'id 0 'memory input 'ip 0 'halt #f 'input '(2) 'output '() 'wait #f 'relative-base 0))

  (reverse (hash-ref (run program-state) 'output ))
