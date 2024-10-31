(define (problem sorting-three)

(:domain sorting)


(:objects
    ; possible numbers
zero one two three 
    ; possible registers
reg1 reg2 reg3 
    swap1
    ; possible permutations
    perm1 perm2 perm3 perm4 perm5 perm6 endperm

    move cmovl cmp
    ; cmovg
)

(:init
    ; numbers
    (number zero)
    (number one)
    (number two)
    (number three)
    (register reg1)
    (register reg2)
    (register reg3)
    (register swap1)
    (command move)
    (command cmovl)
    (command cmp)


    ; universal facts (additionally to the object facts)
    (less-than-or-equal zero zero)
    (less-than zero one)
    (less-than-or-equal zero one)
    (less-than zero two)
    (less-than-or-equal zero two)
    (less-than zero three)
    (less-than-or-equal zero three)
    (less-than-or-equal one one)
    (less-than one two)
    (less-than-or-equal one two)
    (less-than one three)
    (less-than-or-equal one three)
    (less-than-or-equal two two)
    (less-than two three)
    (less-than-or-equal two three)
    (less-than-or-equal three three)

    ; at end/start of an instruction cycle
    (active endperm)
    ; dummy command
    (chosen cmp reg1 reg1)
    (not-less-flag_perm1)
    (not-less-flag_perm2)
    (not-less-flag_perm3)
    (not-less-flag_perm4)
    (not-less-flag_perm5)
    (not-less-flag_perm6)


    ; perm1 123
    (contains_perm1 reg1 one)
    (contains_perm1 reg2 two)
    (contains_perm1 reg3 three)
    (contains_perm1 swap1 zero)

    ; perm2 132
    (contains_perm2 reg1 one)
    (contains_perm2 reg2 three)
    (contains_perm2 reg3 two)
    (contains_perm2 swap1 zero)

    ; perm3 213
    (contains_perm3 reg1 two)
    (contains_perm3 reg2 one)
    (contains_perm3 reg3 three)
    (contains_perm3 swap1 zero)

    ; perm4 231
    (contains_perm4 reg1 two)
    (contains_perm4 reg2 three)
    (contains_perm4 reg3 one)
    (contains_perm4 swap1 zero)

    ; perm5 312
    (contains_perm5 reg1 three)
    (contains_perm5 reg2 one)
    (contains_perm5 reg3 two)
    (contains_perm5 swap1 zero)

    ; perm6 321
    (contains_perm6 reg1 three)
    (contains_perm6 reg2 two)
    (contains_perm6 reg3 one)
    (contains_perm6 swap1 zero)

    )

(:goal
    (and
        ; all to 123
        (active endperm)

        (contains_perm1 reg1 one)
        (contains_perm1 reg2 two)
        (contains_perm1 reg3 three)

        (contains_perm2 reg1 one)
        (contains_perm2 reg2 two)
        (contains_perm2 reg3 three)

        (contains_perm3 reg1 one)
        (contains_perm3 reg2 two)
        (contains_perm3 reg3 three)

        (contains_perm4 reg1 one)
        (contains_perm4 reg2 two)
        (contains_perm4 reg3 three)

        (contains_perm5 reg1 one)
        (contains_perm5 reg2 two)
        (contains_perm5 reg3 three)

        (contains_perm6 reg1 one)
        (contains_perm6 reg2 two)
        (contains_perm6 reg3 three)

    )
)
)