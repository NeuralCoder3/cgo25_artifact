; Sorting Domain

(define (domain sorting)

(:requirements :strips)
; :negative-preconditions

; :universal-preconditions
; allows forall but only in goals and precondition
; we need k distinct variables in parameters 


(:predicates
    (register ?r)
    (number ?n)
    (command ?c)

    (less-than ?n1 ?n2 )
    ; avoid negative preconditions
    (less-than-or-equal ?n1 ?n2 )

    ; no explicit greater than as a>b iff b<a
    (contains_perm1 ?r ?n )
    (less-flag_perm1 )
    (not-less-flag_perm1 )
    (contains_perm2 ?r ?n )
    (less-flag_perm2 )
    (not-less-flag_perm2 )
    (contains_perm3 ?r ?n )
    (less-flag_perm3 )
    (not-less-flag_perm3 )
    (contains_perm4 ?r ?n )
    (less-flag_perm4 )
    (not-less-flag_perm4 )
    (contains_perm5 ?r ?n )
    (less-flag_perm5 )
    (not-less-flag_perm5 )
    (contains_perm6 ?r ?n )
    (less-flag_perm6 )
    (not-less-flag_perm6 )

    ; (greater-flag ?p )
    (active ?p )
    (chosen ?c ?r1 ?r2 )
)

(:action choose_command
    :parameters (
        ?c
        ?r1
        ?r2

        ?c_old
        ?r1_old
        ?r2_old
    )
    :precondition (and 
        (command ?c)
        (register ?r1)
        (register ?r2)
        (command ?c_old)
        (register ?r1_old)
        (register ?r2_old)

        (active endperm)
        (chosen ?c_old ?r1_old ?r2_old)
    )
    :effect (and 
        (chosen ?c ?r1 ?r2)
        (active perm1)
        (not (active endperm))
        (not (chosen ?c_old ?r1_old ?r2_old))
    )
)




(:action apply_move_1
    :parameters (
        ?r1 ; to
        ?r2 ; from

        ?p
        ?n1
        ?n2
        ?pn
    )
    :precondition (and
        (register ?r1)
        (register ?r2)
        (active perm1)
        (number ?n1)
        (number ?n2)

        (contains_perm1 ?r1 ?n1)
        (contains_perm1 ?r2 ?n2)

        (chosen move ?r1 ?r2)
    )
    :effect (and
        (active perm2)
        (not (active perm1))

        (contains_perm1 ?r1 ?n2)
        (not (contains_perm1 ?r1 ?n1))
    )
)



(:action apply_cmp_true_1
    :parameters (
        ?r1
        ?r2

        ?n1
        ?n2
    )
    :precondition (and
        (register ?r1)
        (register ?r2)
        (number ?n1)
        (number ?n2)

        (active perm1)

        (contains_perm1 ?r1 ?n1)
        (contains_perm1 ?r2 ?n2)

        (chosen cmp ?r1 ?r2)
        (less-than ?n1 ?n2)
    )
    :effect (and
        (active perm2)
        (not (active perm1))

        (less-flag_perm1)
        (not (not-less-flag_perm1))
    )
)
(:action apply_cmp_false_1
    :parameters (
        ?r1
        ?r2

        ?n1
        ?n2
    )
    :precondition (and
        (register ?r1)
        (register ?r2)
        (number ?n1)
        (number ?n2)

        (active perm1)

        (contains_perm1 ?r1 ?n1)
        (contains_perm1 ?r2 ?n2)

        (chosen cmp ?r1 ?r2)
        (less-than-or-equal ?n2 ?n1)
    )
    :effect (and
        (active perm2)
        (not (active perm1))

        (not (less-flag_perm1))
        (not-less-flag_perm1)
    )
)


(:action apply_cmovl_true_1
    :parameters (
        ?r1
        ?r2

        ?n1
        ?n2
    )
    :precondition (and
        (register ?r1)
        (register ?r2)
        (number ?n1)
        (number ?n2)

        (active perm1)

        (contains_perm1 ?r1 ?n1)
        (contains_perm1 ?r2 ?n2)

        (chosen cmovl ?r1 ?r2)
        (less-flag_perm1)
    )
    :effect (and
        (active perm2)
        (not (active perm1))

        (contains_perm1 ?r1 ?n2)
        (not (contains_perm1 ?r1 ?n1))
    )
)

(:action apply_cmovl_false_1
    :parameters (
        ?r1
        ?r2

        ?n1
        ?n2
    )
    :precondition (and
        (register ?r1)
        (register ?r2)
        (number ?n1)
        (number ?n2)

        (active perm1)

        (contains_perm1 ?r1 ?n1)
        (contains_perm1 ?r2 ?n2)

        (chosen cmovl ?r1 ?r2)
        (not-less-flag_perm1)
    )
    :effect (and
        (active perm2)
        (not (active perm1))
        ; nop
    )
)
(:action apply_move_2
    :parameters (
        ?r1 ; to
        ?r2 ; from

        ?p
        ?n1
        ?n2
        ?pn
    )
    :precondition (and
        (register ?r1)
        (register ?r2)
        (active perm2)
        (number ?n1)
        (number ?n2)

        (contains_perm2 ?r1 ?n1)
        (contains_perm2 ?r2 ?n2)

        (chosen move ?r1 ?r2)
    )
    :effect (and
        (active perm3)
        (not (active perm2))

        (contains_perm2 ?r1 ?n2)
        (not (contains_perm2 ?r1 ?n1))
    )
)



(:action apply_cmp_true_2
    :parameters (
        ?r1
        ?r2

        ?n1
        ?n2
    )
    :precondition (and
        (register ?r1)
        (register ?r2)
        (number ?n1)
        (number ?n2)

        (active perm2)

        (contains_perm2 ?r1 ?n1)
        (contains_perm2 ?r2 ?n2)

        (chosen cmp ?r1 ?r2)
        (less-than ?n1 ?n2)
    )
    :effect (and
        (active perm3)
        (not (active perm2))

        (less-flag_perm2)
        (not (not-less-flag_perm2))
    )
)
(:action apply_cmp_false_2
    :parameters (
        ?r1
        ?r2

        ?n1
        ?n2
    )
    :precondition (and
        (register ?r1)
        (register ?r2)
        (number ?n1)
        (number ?n2)

        (active perm2)

        (contains_perm2 ?r1 ?n1)
        (contains_perm2 ?r2 ?n2)

        (chosen cmp ?r1 ?r2)
        (less-than-or-equal ?n2 ?n1)
    )
    :effect (and
        (active perm3)
        (not (active perm2))

        (not (less-flag_perm2))
        (not-less-flag_perm2)
    )
)


(:action apply_cmovl_true_2
    :parameters (
        ?r1
        ?r2

        ?n1
        ?n2
    )
    :precondition (and
        (register ?r1)
        (register ?r2)
        (number ?n1)
        (number ?n2)

        (active perm2)

        (contains_perm2 ?r1 ?n1)
        (contains_perm2 ?r2 ?n2)

        (chosen cmovl ?r1 ?r2)
        (less-flag_perm2)
    )
    :effect (and
        (active perm3)
        (not (active perm2))

        (contains_perm2 ?r1 ?n2)
        (not (contains_perm2 ?r1 ?n1))
    )
)

(:action apply_cmovl_false_2
    :parameters (
        ?r1
        ?r2

        ?n1
        ?n2
    )
    :precondition (and
        (register ?r1)
        (register ?r2)
        (number ?n1)
        (number ?n2)

        (active perm2)

        (contains_perm2 ?r1 ?n1)
        (contains_perm2 ?r2 ?n2)

        (chosen cmovl ?r1 ?r2)
        (not-less-flag_perm2)
    )
    :effect (and
        (active perm3)
        (not (active perm2))
        ; nop
    )
)
(:action apply_move_3
    :parameters (
        ?r1 ; to
        ?r2 ; from

        ?p
        ?n1
        ?n2
        ?pn
    )
    :precondition (and
        (register ?r1)
        (register ?r2)
        (active perm3)
        (number ?n1)
        (number ?n2)

        (contains_perm3 ?r1 ?n1)
        (contains_perm3 ?r2 ?n2)

        (chosen move ?r1 ?r2)
    )
    :effect (and
        (active perm4)
        (not (active perm3))

        (contains_perm3 ?r1 ?n2)
        (not (contains_perm3 ?r1 ?n1))
    )
)



(:action apply_cmp_true_3
    :parameters (
        ?r1
        ?r2

        ?n1
        ?n2
    )
    :precondition (and
        (register ?r1)
        (register ?r2)
        (number ?n1)
        (number ?n2)

        (active perm3)

        (contains_perm3 ?r1 ?n1)
        (contains_perm3 ?r2 ?n2)

        (chosen cmp ?r1 ?r2)
        (less-than ?n1 ?n2)
    )
    :effect (and
        (active perm4)
        (not (active perm3))

        (less-flag_perm3)
        (not (not-less-flag_perm3))
    )
)
(:action apply_cmp_false_3
    :parameters (
        ?r1
        ?r2

        ?n1
        ?n2
    )
    :precondition (and
        (register ?r1)
        (register ?r2)
        (number ?n1)
        (number ?n2)

        (active perm3)

        (contains_perm3 ?r1 ?n1)
        (contains_perm3 ?r2 ?n2)

        (chosen cmp ?r1 ?r2)
        (less-than-or-equal ?n2 ?n1)
    )
    :effect (and
        (active perm4)
        (not (active perm3))

        (not (less-flag_perm3))
        (not-less-flag_perm3)
    )
)


(:action apply_cmovl_true_3
    :parameters (
        ?r1
        ?r2

        ?n1
        ?n2
    )
    :precondition (and
        (register ?r1)
        (register ?r2)
        (number ?n1)
        (number ?n2)

        (active perm3)

        (contains_perm3 ?r1 ?n1)
        (contains_perm3 ?r2 ?n2)

        (chosen cmovl ?r1 ?r2)
        (less-flag_perm3)
    )
    :effect (and
        (active perm4)
        (not (active perm3))

        (contains_perm3 ?r1 ?n2)
        (not (contains_perm3 ?r1 ?n1))
    )
)

(:action apply_cmovl_false_3
    :parameters (
        ?r1
        ?r2

        ?n1
        ?n2
    )
    :precondition (and
        (register ?r1)
        (register ?r2)
        (number ?n1)
        (number ?n2)

        (active perm3)

        (contains_perm3 ?r1 ?n1)
        (contains_perm3 ?r2 ?n2)

        (chosen cmovl ?r1 ?r2)
        (not-less-flag_perm3)
    )
    :effect (and
        (active perm4)
        (not (active perm3))
        ; nop
    )
)
(:action apply_move_4
    :parameters (
        ?r1 ; to
        ?r2 ; from

        ?p
        ?n1
        ?n2
        ?pn
    )
    :precondition (and
        (register ?r1)
        (register ?r2)
        (active perm4)
        (number ?n1)
        (number ?n2)

        (contains_perm4 ?r1 ?n1)
        (contains_perm4 ?r2 ?n2)

        (chosen move ?r1 ?r2)
    )
    :effect (and
        (active perm5)
        (not (active perm4))

        (contains_perm4 ?r1 ?n2)
        (not (contains_perm4 ?r1 ?n1))
    )
)



(:action apply_cmp_true_4
    :parameters (
        ?r1
        ?r2

        ?n1
        ?n2
    )
    :precondition (and
        (register ?r1)
        (register ?r2)
        (number ?n1)
        (number ?n2)

        (active perm4)

        (contains_perm4 ?r1 ?n1)
        (contains_perm4 ?r2 ?n2)

        (chosen cmp ?r1 ?r2)
        (less-than ?n1 ?n2)
    )
    :effect (and
        (active perm5)
        (not (active perm4))

        (less-flag_perm4)
        (not (not-less-flag_perm4))
    )
)
(:action apply_cmp_false_4
    :parameters (
        ?r1
        ?r2

        ?n1
        ?n2
    )
    :precondition (and
        (register ?r1)
        (register ?r2)
        (number ?n1)
        (number ?n2)

        (active perm4)

        (contains_perm4 ?r1 ?n1)
        (contains_perm4 ?r2 ?n2)

        (chosen cmp ?r1 ?r2)
        (less-than-or-equal ?n2 ?n1)
    )
    :effect (and
        (active perm5)
        (not (active perm4))

        (not (less-flag_perm4))
        (not-less-flag_perm4)
    )
)


(:action apply_cmovl_true_4
    :parameters (
        ?r1
        ?r2

        ?n1
        ?n2
    )
    :precondition (and
        (register ?r1)
        (register ?r2)
        (number ?n1)
        (number ?n2)

        (active perm4)

        (contains_perm4 ?r1 ?n1)
        (contains_perm4 ?r2 ?n2)

        (chosen cmovl ?r1 ?r2)
        (less-flag_perm4)
    )
    :effect (and
        (active perm5)
        (not (active perm4))

        (contains_perm4 ?r1 ?n2)
        (not (contains_perm4 ?r1 ?n1))
    )
)

(:action apply_cmovl_false_4
    :parameters (
        ?r1
        ?r2

        ?n1
        ?n2
    )
    :precondition (and
        (register ?r1)
        (register ?r2)
        (number ?n1)
        (number ?n2)

        (active perm4)

        (contains_perm4 ?r1 ?n1)
        (contains_perm4 ?r2 ?n2)

        (chosen cmovl ?r1 ?r2)
        (not-less-flag_perm4)
    )
    :effect (and
        (active perm5)
        (not (active perm4))
        ; nop
    )
)
(:action apply_move_5
    :parameters (
        ?r1 ; to
        ?r2 ; from

        ?p
        ?n1
        ?n2
        ?pn
    )
    :precondition (and
        (register ?r1)
        (register ?r2)
        (active perm5)
        (number ?n1)
        (number ?n2)

        (contains_perm5 ?r1 ?n1)
        (contains_perm5 ?r2 ?n2)

        (chosen move ?r1 ?r2)
    )
    :effect (and
        (active perm6)
        (not (active perm5))

        (contains_perm5 ?r1 ?n2)
        (not (contains_perm5 ?r1 ?n1))
    )
)



(:action apply_cmp_true_5
    :parameters (
        ?r1
        ?r2

        ?n1
        ?n2
    )
    :precondition (and
        (register ?r1)
        (register ?r2)
        (number ?n1)
        (number ?n2)

        (active perm5)

        (contains_perm5 ?r1 ?n1)
        (contains_perm5 ?r2 ?n2)

        (chosen cmp ?r1 ?r2)
        (less-than ?n1 ?n2)
    )
    :effect (and
        (active perm6)
        (not (active perm5))

        (less-flag_perm5)
        (not (not-less-flag_perm5))
    )
)
(:action apply_cmp_false_5
    :parameters (
        ?r1
        ?r2

        ?n1
        ?n2
    )
    :precondition (and
        (register ?r1)
        (register ?r2)
        (number ?n1)
        (number ?n2)

        (active perm5)

        (contains_perm5 ?r1 ?n1)
        (contains_perm5 ?r2 ?n2)

        (chosen cmp ?r1 ?r2)
        (less-than-or-equal ?n2 ?n1)
    )
    :effect (and
        (active perm6)
        (not (active perm5))

        (not (less-flag_perm5))
        (not-less-flag_perm5)
    )
)


(:action apply_cmovl_true_5
    :parameters (
        ?r1
        ?r2

        ?n1
        ?n2
    )
    :precondition (and
        (register ?r1)
        (register ?r2)
        (number ?n1)
        (number ?n2)

        (active perm5)

        (contains_perm5 ?r1 ?n1)
        (contains_perm5 ?r2 ?n2)

        (chosen cmovl ?r1 ?r2)
        (less-flag_perm5)
    )
    :effect (and
        (active perm6)
        (not (active perm5))

        (contains_perm5 ?r1 ?n2)
        (not (contains_perm5 ?r1 ?n1))
    )
)

(:action apply_cmovl_false_5
    :parameters (
        ?r1
        ?r2

        ?n1
        ?n2
    )
    :precondition (and
        (register ?r1)
        (register ?r2)
        (number ?n1)
        (number ?n2)

        (active perm5)

        (contains_perm5 ?r1 ?n1)
        (contains_perm5 ?r2 ?n2)

        (chosen cmovl ?r1 ?r2)
        (not-less-flag_perm5)
    )
    :effect (and
        (active perm6)
        (not (active perm5))
        ; nop
    )
)
(:action apply_move_6
    :parameters (
        ?r1 ; to
        ?r2 ; from

        ?p
        ?n1
        ?n2
        ?pn
    )
    :precondition (and
        (register ?r1)
        (register ?r2)
        (active perm6)
        (number ?n1)
        (number ?n2)

        (contains_perm6 ?r1 ?n1)
        (contains_perm6 ?r2 ?n2)

        (chosen move ?r1 ?r2)
    )
    :effect (and
        (active endperm)
        (not (active perm6))

        (contains_perm6 ?r1 ?n2)
        (not (contains_perm6 ?r1 ?n1))
    )
)



(:action apply_cmp_true_6
    :parameters (
        ?r1
        ?r2

        ?n1
        ?n2
    )
    :precondition (and
        (register ?r1)
        (register ?r2)
        (number ?n1)
        (number ?n2)

        (active perm6)

        (contains_perm6 ?r1 ?n1)
        (contains_perm6 ?r2 ?n2)

        (chosen cmp ?r1 ?r2)
        (less-than ?n1 ?n2)
    )
    :effect (and
        (active endperm)
        (not (active perm6))

        (less-flag_perm6)
        (not (not-less-flag_perm6))
    )
)
(:action apply_cmp_false_6
    :parameters (
        ?r1
        ?r2

        ?n1
        ?n2
    )
    :precondition (and
        (register ?r1)
        (register ?r2)
        (number ?n1)
        (number ?n2)

        (active perm6)

        (contains_perm6 ?r1 ?n1)
        (contains_perm6 ?r2 ?n2)

        (chosen cmp ?r1 ?r2)
        (less-than-or-equal ?n2 ?n1)
    )
    :effect (and
        (active endperm)
        (not (active perm6))

        (not (less-flag_perm6))
        (not-less-flag_perm6)
    )
)


(:action apply_cmovl_true_6
    :parameters (
        ?r1
        ?r2

        ?n1
        ?n2
    )
    :precondition (and
        (register ?r1)
        (register ?r2)
        (number ?n1)
        (number ?n2)

        (active perm6)

        (contains_perm6 ?r1 ?n1)
        (contains_perm6 ?r2 ?n2)

        (chosen cmovl ?r1 ?r2)
        (less-flag_perm6)
    )
    :effect (and
        (active endperm)
        (not (active perm6))

        (contains_perm6 ?r1 ?n2)
        (not (contains_perm6 ?r1 ?n1))
    )
)

(:action apply_cmovl_false_6
    :parameters (
        ?r1
        ?r2

        ?n1
        ?n2
    )
    :precondition (and
        (register ?r1)
        (register ?r2)
        (number ?n1)
        (number ?n2)

        (active perm6)

        (contains_perm6 ?r1 ?n1)
        (contains_perm6 ?r2 ?n2)

        (chosen cmovl ?r1 ?r2)
        (not-less-flag_perm6)
    )
    :effect (and
        (active endperm)
        (not (active perm6))
        ; nop
    )
)



)