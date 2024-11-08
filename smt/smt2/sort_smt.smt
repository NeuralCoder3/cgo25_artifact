; either int -> command or directly vars
(set-logic ALL)
(set-option :produce-models true)

(declare-datatypes ((Triple 3)) 
    ((par (P Q R) ((triple (first P) (second Q) (third R)))))
)
(declare-datatype Instruction ((cmp) (mov) (cmovg) (cmovl)))

; declare the variables
(declare-const inst_1 Instruction)
(declare-const    a_1 Int)
(declare-const    b_1 Int)
(declare-const inst_2 Instruction)
(declare-const    a_2 Int)
(declare-const    b_2 Int)
(declare-const inst_3 Instruction)
(declare-const    a_3 Int)
(declare-const    b_3 Int)
(declare-const inst_4 Instruction)
(declare-const    a_4 Int)
(declare-const    b_4 Int)

(declare-const inst_5 Instruction)
(declare-const    a_5 Int)
(declare-const    b_5 Int)
(declare-const inst_6 Instruction)
(declare-const    a_6 Int)
(declare-const    b_6 Int)
(declare-const inst_7 Instruction)
(declare-const    a_7 Int)
(declare-const    b_7 Int)
(declare-const inst_8 Instruction)
(declare-const    a_8 Int)
(declare-const    b_8 Int)
(declare-const inst_9 Instruction)
(declare-const    a_9 Int)
(declare-const    b_9 Int)
(declare-const inst_10 Instruction)
(declare-const    a_10 Int)
(declare-const    b_10 Int)

; register restrictions
(assert (and (<= 0 a_1) (<= a_1 3)))
(assert (and (<= 0 b_1) (<= b_1 3)))
(assert (and (<= 0 a_2) (<= a_2 3)))
(assert (and (<= 0 b_2) (<= b_2 3)))
(assert (and (<= 0 a_3) (<= a_3 3)))
(assert (and (<= 0 b_3) (<= b_3 3)))
(assert (and (<= 0 a_4) (<= a_4 3)))
(assert (and (<= 0 b_4) (<= b_4 3)))

(assert (and (<= 0 a_5) (<= a_5 3)))
(assert (and (<= 0 b_5) (<= b_5 3)))
(assert (and (<= 0 a_6) (<= a_6 3)))
(assert (and (<= 0 b_6) (<= b_6 3)))
(assert (and (<= 0 a_7) (<= a_7 3)))
(assert (and (<= 0 b_7) (<= b_7 3)))
(assert (and (<= 0 a_8) (<= a_8 3)))
(assert (and (<= 0 b_8) (<= b_8 3)))
(assert (and (<= 0 a_9) (<= a_9 3)))
(assert (and (<= 0 b_9) (<= b_9 3)))
(assert (and (<= 0 a_10) (<= a_10 3)))
(assert (and (<= 0 b_10) (<= b_10 3)))


(define-fun apply 
    (
        (i Instruction) 
        (reg1 Int) ; 0<=reg1<=3
        (reg2 Int) ; 0<=reg2<=3
        (tup (Triple (Array Int Int) Bool Bool))
    ) 
    (Triple (Array Int Int) Bool Bool)
    ; (arr,lt,gt) = tup
    (let (
            (arr (first tup))
            (lt (second tup))
            (gt (third tup))
        )
    (let (
            (a (select arr reg1)) ; dest
            (b (select arr reg2)) ; src
        )
        (ite (= i cmp)
            (triple arr (< a b) (> a b))
            (ite (= i mov)
                (triple (store arr reg1 b) lt gt)
                (ite (= i cmovg)
                    (ite gt (triple (store arr reg1 b) lt gt) (triple arr lt gt))
                    (ite (= i cmovl)
                        (ite lt (triple (store arr reg1 b) lt gt) (triple arr lt gt))
                        ; error
                        (triple arr lt gt)
                    )
                )
            )
        )
    ))
)


(define-fun apply_all
    (
        (state (Triple (Array Int Int) Bool Bool))
    )
    (Triple (Array Int Int) Bool Bool)
    (apply inst_10 a_10 b_10
    (apply inst_9 a_9 b_9
    (apply inst_8 a_8 b_8
    (apply inst_7 a_7 b_7
    (apply inst_6 a_6 b_6
    (apply inst_5 a_5 b_5

    (apply inst_4 a_4 b_4
    (apply inst_3 a_3 b_3
    (apply inst_2 a_2 b_2
    (apply inst_1 a_1 b_1 
    state
    ))))

    ))))))
)

; apply on initial states (all six permutations)
; e.g. 123 => [1,2,3,0],false,false
(define-fun inital_state
    (
        (a Int) (b Int) (c Int)
    )
    (Triple (Array Int Int) Bool Bool)
    (triple 
        (store (store (store (store ((as const (Array Int Int)) 0) 0 a) 1 b) 2 c) 3 0)
        false
        false
    )
)

(define-fun check
    (
        (state (Triple (Array Int Int) Bool Bool))
    )
    Bool
    (
    let (
        (arr (first state))
    ) (and
        ; (= (select arr 0) 0)
        (= (select arr 0) 1)
        (= (select arr 1) 2)
        (= (select arr 2) 3)
    )
    )
)

; 123
(declare-const init123 (Array Int Int))
(assert (= (select init123 0) 1))
(assert (= (select init123 1) 2))
(assert (= (select init123 2) 3))
(assert (= (select init123 3) 0))
; 132
(declare-const init132 (Array Int Int))
(assert (= (select init132 0) 1))
(assert (= (select init132 1) 3))
(assert (= (select init132 2) 2))
(assert (= (select init132 3) 0))
; 213
(declare-const init213 (Array Int Int))
(assert (= (select init213 0) 2))
(assert (= (select init213 1) 1))
(assert (= (select init213 2) 3))
(assert (= (select init213 3) 0))
; 231
(declare-const init231 (Array Int Int))
(assert (= (select init231 0) 2))
(assert (= (select init231 1) 3))
(assert (= (select init231 2) 1))
(assert (= (select init231 3) 0))
; 312
(declare-const init312 (Array Int Int))
(assert (= (select init312 0) 3))
(assert (= (select init312 1) 1))
(assert (= (select init312 2) 2))
(assert (= (select init312 3) 0))
; 321
(declare-const init321 (Array Int Int))
(assert (= (select init321 0) 3))
(assert (= (select init321 1) 2))
(assert (= (select init321 2) 1))
(assert (= (select init321 3) 0))


(assert (check (apply_all (triple init123 false false))))
(assert (check (apply_all (triple init132 false false))))
(assert (check (apply_all (triple init213 false false))))
(assert (check (apply_all (triple init231 false false))))
(assert (check (apply_all (triple init312 false false))))
(assert (check (apply_all (triple init321 false false))))




(check-sat)
; (get-model)
; print the model readably as INSTR A B
(get-value (inst_1 a_1 b_1))
(get-value (inst_2 a_2 b_2))
(get-value (inst_3 a_3 b_3))
(get-value (inst_4 a_4 b_4))
(get-value (inst_5 a_5 b_5))
(get-value (inst_6 a_6 b_6))
(get-value (inst_7 a_7 b_7))
(get-value (inst_8 a_8 b_8))
(get-value (inst_9 a_9 b_9))
(get-value (inst_10 a_10 b_10))

; cvc5 sort_smt.smt --lang smt
