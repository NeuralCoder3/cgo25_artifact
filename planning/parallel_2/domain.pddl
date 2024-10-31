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
    )
    :precondition (and
        (contains perm1 ?r1 ?n1_p1)
        (contains perm1 ?r2 ?n2_p1)

        (contains perm2 ?r1 ?n1_p2)
        (contains perm2 ?r2 ?n2_p2)
    )
    :effect (and
        (     contains perm1 ?r1 ?n2_p1 )
        (not (contains perm1 ?r1 ?n1_p1))

        (     contains perm2 ?r1 ?n2_p2 )
        (not (contains perm2 ?r1 ?n1_p2))
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
    )
    :precondition (and
        (contains perm1 ?r1 ?n1_p1)
        (contains perm1 ?r2 ?n2_p1)

        (contains perm2 ?r1 ?n1_p2)
        (contains perm2 ?r2 ?n2_p2)
    )
    :effect (and
        (when (     less-than ?n1_p1 ?n2_p1 ) (     less-flag    perm1))
        (when (not (less-than ?n1_p1 ?n2_p1)) (not (less-flag    perm1)))
        (when (     less-than ?n2_p1 ?n1_p1 ) (     greater-flag perm1))
        (when (not (less-than ?n2_p1 ?n1_p1)) (not (greater-flag perm1)))

        (when (     less-than ?n1_p2 ?n2_p2 ) (     less-flag    perm2))
        (when (not (less-than ?n1_p2 ?n2_p2)) (not (less-flag    perm2)))
        (when (     less-than ?n2_p2 ?n1_p2 ) (     greater-flag perm2))
        (when (not (less-than ?n2_p2 ?n1_p2)) (not (greater-flag perm2)))
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
    )
    :precondition (and
        (contains perm1 ?r1 ?n1_p1)
        (contains perm1 ?r2 ?n2_p1)

        (contains perm2 ?r1 ?n1_p2)
        (contains perm2 ?r2 ?n2_p2)
    )
    :effect (and
        (when (less-flag perm1)
            (and
                     (contains perm1 ?r1 ?n2_p1)
                (not (contains perm1 ?r1 ?n1_p1))
            )
        )

        (when (less-flag perm2)
            (and
                     (contains perm2 ?r1 ?n2_p2)
                (not (contains perm2 ?r1 ?n1_p2))
            )
        )
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
    )
    :precondition (and
        (contains perm1 ?r1 ?n1_p1)
        (contains perm1 ?r2 ?n2_p1)

        (contains perm2 ?r1 ?n1_p2)
        (contains perm2 ?r2 ?n2_p2)
    )
    :effect (and
        (when (greater-flag perm1)
            (and
                     (contains perm1 ?r1 ?n2_p1)
                (not (contains perm1 ?r1 ?n1_p1))
            )
        )

        (when (greater-flag perm2)
            (and
                     (contains perm2 ?r1 ?n2_p2)
                (not (contains perm2 ?r1 ?n1_p2))
            )
        )
    )
)




)