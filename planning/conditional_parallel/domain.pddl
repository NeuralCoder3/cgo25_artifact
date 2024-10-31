; Sorting Domain

(define (domain sorting)

(:requirements :strips :typing :negative-preconditions :conditional-effects)

; :universal-preconditions
; allows forall but only in goals and precondition
; we need k distinct variables in parameters 

(:types
    register number permutation
)

(:predicates
    (less-than ?n1 - number ?n2 - number)
    ; no explicit greater than as a>b iff b<a
    (contains ?p - permutation ?r - register ?n - number)
    (less-flag ?p - permutation)
    (greater-flag ?p - permutation)
)


(:action move
    :parameters (
        ?r1 - register ; to
        ?r2 - register ; from

?n1_p1 - number
?n2_p1 - number
?n1_p2 - number
?n2_p2 - number
?n1_p3 - number
?n2_p3 - number
?n1_p4 - number
?n2_p4 - number
?n1_p5 - number
?n2_p5 - number
?n1_p6 - number
?n2_p6 - number
    )
    :precondition (and
(contains perm1 ?r1 ?n1_p1)
(contains perm1 ?r2 ?n2_p1)
(contains perm2 ?r1 ?n1_p2)
(contains perm2 ?r2 ?n2_p2)
(contains perm3 ?r1 ?n1_p3)
(contains perm3 ?r2 ?n2_p3)
(contains perm4 ?r1 ?n1_p4)
(contains perm4 ?r2 ?n2_p4)
(contains perm5 ?r1 ?n1_p5)
(contains perm5 ?r2 ?n2_p5)
(contains perm6 ?r1 ?n1_p6)
(contains perm6 ?r2 ?n2_p6)
    )
    :effect (and
(contains perm1 ?r1 ?n2_p1)
(not (contains perm1 ?r1 ?n1_p1))
(contains perm2 ?r1 ?n2_p2)
(not (contains perm2 ?r1 ?n1_p2))
(contains perm3 ?r1 ?n2_p3)
(not (contains perm3 ?r1 ?n1_p3))
(contains perm4 ?r1 ?n2_p4)
(not (contains perm4 ?r1 ?n1_p4))
(contains perm5 ?r1 ?n2_p5)
(not (contains perm5 ?r1 ?n1_p5))
(contains perm6 ?r1 ?n2_p6)
(not (contains perm6 ?r1 ?n1_p6))
    )
)

; we could have a compare_true and compare_false or a single compare with a conditional effect
(:action compare
    :parameters (
        ?r1 - register
        ?r2 - register

?n1_p1 - number
?n2_p1 - number
?n1_p2 - number
?n2_p2 - number
?n1_p3 - number
?n2_p3 - number
?n1_p4 - number
?n2_p4 - number
?n1_p5 - number
?n2_p5 - number
?n1_p6 - number
?n2_p6 - number
    )
    :precondition (and
(contains perm1 ?r1 ?n1_p1)
(contains perm1 ?r2 ?n2_p1)
(contains perm2 ?r1 ?n1_p2)
(contains perm2 ?r2 ?n2_p2)
(contains perm3 ?r1 ?n1_p3)
(contains perm3 ?r2 ?n2_p3)
(contains perm4 ?r1 ?n1_p4)
(contains perm4 ?r2 ?n2_p4)
(contains perm5 ?r1 ?n1_p5)
(contains perm5 ?r2 ?n2_p5)
(contains perm6 ?r1 ?n1_p6)
(contains perm6 ?r2 ?n2_p6)
    )
    :effect (and
(when (     less-than ?n1_p1 ?n2_p1 ) (     less-flag    perm1 ))
(when (not (less-than ?n1_p1 ?n2_p1)) (not (less-flag    perm1 )))
(when (     less-than ?n2_p1 ?n1_p1 ) (     greater-flag perm1 ))
(when (not (less-than ?n2_p1 ?n1_p1)) (not (greater-flag perm1 )))
(when (     less-than ?n1_p2 ?n2_p2 ) (     less-flag    perm2 ))
(when (not (less-than ?n1_p2 ?n2_p2)) (not (less-flag    perm2 )))
(when (     less-than ?n2_p2 ?n1_p2 ) (     greater-flag perm2 ))
(when (not (less-than ?n2_p2 ?n1_p2)) (not (greater-flag perm2 )))
(when (     less-than ?n1_p3 ?n2_p3 ) (     less-flag    perm3 ))
(when (not (less-than ?n1_p3 ?n2_p3)) (not (less-flag    perm3 )))
(when (     less-than ?n2_p3 ?n1_p3 ) (     greater-flag perm3 ))
(when (not (less-than ?n2_p3 ?n1_p3)) (not (greater-flag perm3 )))
(when (     less-than ?n1_p4 ?n2_p4 ) (     less-flag    perm4 ))
(when (not (less-than ?n1_p4 ?n2_p4)) (not (less-flag    perm4 )))
(when (     less-than ?n2_p4 ?n1_p4 ) (     greater-flag perm4 ))
(when (not (less-than ?n2_p4 ?n1_p4)) (not (greater-flag perm4 )))
(when (     less-than ?n1_p5 ?n2_p5 ) (     less-flag    perm5 ))
(when (not (less-than ?n1_p5 ?n2_p5)) (not (less-flag    perm5 )))
(when (     less-than ?n2_p5 ?n1_p5 ) (     greater-flag perm5 ))
(when (not (less-than ?n2_p5 ?n1_p5)) (not (greater-flag perm5 )))
(when (     less-than ?n1_p6 ?n2_p6 ) (     less-flag    perm6 ))
(when (not (less-than ?n1_p6 ?n2_p6)) (not (less-flag    perm6 )))
(when (     less-than ?n2_p6 ?n1_p6 ) (     greater-flag perm6 ))
(when (not (less-than ?n2_p6 ?n1_p6)) (not (greater-flag perm6 )))
    )
)

; we could have a working cmovl and noop cmovl
; that are the same as move with less-flag as additional precondition
; or a single cmovl with conditional effect
; importantly: cmovl should also be applicable when less-flag is false
; => intuitively every instruction is always possible 
; => all same precondition that to not restrict but just establish the values
(:action cmovl
    :parameters (
        ?r1 - register
        ?r2 - register

?n1_p1 - number
?n2_p1 - number
?n1_p2 - number
?n2_p2 - number
?n1_p3 - number
?n2_p3 - number
?n1_p4 - number
?n2_p4 - number
?n1_p5 - number
?n2_p5 - number
?n1_p6 - number
?n2_p6 - number
    )
    :precondition (and
(contains perm1 ?r1 ?n1_p1)
(contains perm1 ?r2 ?n2_p1)
(contains perm2 ?r1 ?n1_p2)
(contains perm2 ?r2 ?n2_p2)
(contains perm3 ?r1 ?n1_p3)
(contains perm3 ?r2 ?n2_p3)
(contains perm4 ?r1 ?n1_p4)
(contains perm4 ?r2 ?n2_p4)
(contains perm5 ?r1 ?n1_p5)
(contains perm5 ?r2 ?n2_p5)
(contains perm6 ?r1 ?n1_p6)
(contains perm6 ?r2 ?n2_p6)
    )
    :effect (and
(when (less-flag perm1 ) (and 
      (contains perm1 ?r1 ?n2_p1)
      (not (contains perm1 ?r1 ?n1_p1))))
(when (less-flag perm2 ) (and 
      (contains perm2 ?r1 ?n2_p2)
      (not (contains perm2 ?r1 ?n1_p2))))
(when (less-flag perm3 ) (and 
      (contains perm3 ?r1 ?n2_p3)
      (not (contains perm3 ?r1 ?n1_p3))))
(when (less-flag perm4 ) (and 
      (contains perm4 ?r1 ?n2_p4)
      (not (contains perm4 ?r1 ?n1_p4))))
(when (less-flag perm5 ) (and 
      (contains perm5 ?r1 ?n2_p5)
      (not (contains perm5 ?r1 ?n1_p5))))
(when (less-flag perm6 ) (and 
      (contains perm6 ?r1 ?n2_p6)
      (not (contains perm6 ?r1 ?n1_p6))))
    )
)

(:action cmovg
    :parameters (
        ?r1 - register
        ?r2 - register

?n1_p1 - number
?n2_p1 - number
?n1_p2 - number
?n2_p2 - number
?n1_p3 - number
?n2_p3 - number
?n1_p4 - number
?n2_p4 - number
?n1_p5 - number
?n2_p5 - number
?n1_p6 - number
?n2_p6 - number
    )
    :precondition (and
(contains perm1 ?r1 ?n1_p1)
(contains perm1 ?r2 ?n2_p1)
(contains perm2 ?r1 ?n1_p2)
(contains perm2 ?r2 ?n2_p2)
(contains perm3 ?r1 ?n1_p3)
(contains perm3 ?r2 ?n2_p3)
(contains perm4 ?r1 ?n1_p4)
(contains perm4 ?r2 ?n2_p4)
(contains perm5 ?r1 ?n1_p5)
(contains perm5 ?r2 ?n2_p5)
(contains perm6 ?r1 ?n1_p6)
(contains perm6 ?r2 ?n2_p6)
    )
    :effect (and
(when (greater-flag perm1 ) (and 
      (contains perm1 ?r1 ?n2_p1)
      (not (contains perm1 ?r1 ?n1_p1))))
(when (greater-flag perm2 ) (and 
      (contains perm2 ?r1 ?n2_p2)
      (not (contains perm2 ?r1 ?n1_p2))))
(when (greater-flag perm3 ) (and 
      (contains perm3 ?r1 ?n2_p3)
      (not (contains perm3 ?r1 ?n1_p3))))
(when (greater-flag perm4 ) (and 
      (contains perm4 ?r1 ?n2_p4)
      (not (contains perm4 ?r1 ?n1_p4))))
(when (greater-flag perm5 ) (and 
      (contains perm5 ?r1 ?n2_p5)
      (not (contains perm5 ?r1 ?n1_p5))))
(when (greater-flag perm6 ) (and 
      (contains perm6 ?r1 ?n2_p6)
      (not (contains perm6 ?r1 ?n1_p6))))
    )
)




)