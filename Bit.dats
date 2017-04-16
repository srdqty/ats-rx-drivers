
(*
**
** A template for single-file ATS programs
**
*)

(* ****** ****** *)
//
#include "share/atspre_define.hats"
#include "share/atspre_staload.hats"


staload UN = "prelude/SATS/unsafe.sats"
staload "Bit.sats"

//
(* ****** ****** *)

//
// please write you program in this section
//

(* ****** ****** *)

implement main0 () = () // a dummy implementation for [main]


#include "Bit.hats"


primplement bits_test1 () = BEQNIL()
primplement bits8_test2 () = 
  BEQCONS0 (BEQCONS0 (BEQCONS0 (BEQCONS0 (BEQCONS0 (BEQCONS0 (BEQCONS0 (BEQCONS0 (BEQNIL))))))))
primplement bits8_test3 () = 
  BEQCONS1 (BEQCONS1 (BEQCONS1 (BEQCONS1 (BEQCONS1 (BEQCONS1 (BEQCONS1 (BEQCONS1 (BEQNIL))))))))
primplement bits8_test4_1 () = BEQCONS1 (BEQCONS0 (BEQCONS0 (BEQCONS0 (BEQCONS0 (BEQCONS0 (BEQCONS0 (BEQCONS0 (BEQNIL))))))))
primplement bits8_test4_2 () = BEQCONS0 (BEQCONS1 (BEQCONS0 (BEQCONS0 (BEQCONS0 (BEQCONS0 (BEQCONS0 (BEQCONS0 (BEQNIL))))))))
primplement bits8_test4_3 () = BEQCONS0 (BEQCONS0 (BEQCONS1 (BEQCONS0 (BEQCONS0 (BEQCONS0 (BEQCONS0 (BEQCONS0 (BEQNIL))))))))
primplement bits8_test4_4 () = BEQCONS0 (BEQCONS0 (BEQCONS0 (BEQCONS1 (BEQCONS0 (BEQCONS0 (BEQCONS0 (BEQCONS0 (BEQNIL))))))))
primplement bits8_test4_5 () = BEQCONS0 (BEQCONS0 (BEQCONS0 (BEQCONS0 (BEQCONS1 (BEQCONS0 (BEQCONS0 (BEQCONS0 (BEQNIL))))))))
primplement bits8_test4_6 () = BEQCONS0 (BEQCONS0 (BEQCONS0 (BEQCONS0 (BEQCONS0 (BEQCONS1 (BEQCONS0 (BEQCONS0 (BEQNIL))))))))
primplement bits8_test4_7 () = BEQCONS0 (BEQCONS0 (BEQCONS0 (BEQCONS0 (BEQCONS0 (BEQCONS0 (BEQCONS1 (BEQCONS0 (BEQNIL))))))))
primplement bits8_test4_8 () = BEQCONS0 (BEQCONS0 (BEQCONS0 (BEQCONS0 (BEQCONS0 (BEQCONS0 (BEQCONS0 (BEQCONS1 (BEQNIL))))))))

primplement bitscons0_eq_double     {bs}{n,v} (bitseq) = BEQCONS0 (bitseq)
primplement bitscons0_eq__cons1_inc {bs}{n,v} (bitseq) = let prval BEQCONS0 (bitseq') = bitseq in BEQCONS1 (bitseq') end


prfn bits_cons_eq {b,c:bit | b == c}{bs,cs:bits | bs == cs} ()
                   :[BitsCons (b,bs) == BitsCons (c,cs)] void
 = let
     prval EQBIT ()  = eqbit_make {b,c} ()
     prval EQBITS () = eqbits_make {bs,cs} ()
   in bits_eq_refl {BitsCons (b,bs)} () end


prfn lor_0_nochange {b,c:bit} (lor_p:BIT_LOR (b,O,c)):[b == c] void
 = case+ lor_p of
   | BIT_LOR_II () =/=> () // I≠O
   | BIT_LOR_IO ()   => bit_eq_refl {I}() // I=I
   | BIT_LOR_OI () =/=> () // I≠O
   | BIT_LOR_OO ()   => bit_eq_refl {O}() // O=O

prfn lor_1_assign   {b,c:bit} (lor_p:BIT_LOR (b,I,c)):[I == c] void
 = case+ lor_p of
   | BIT_LOR_II ()   => bit_eq_refl {I}() // I=I
   | BIT_LOR_IO () =/=> () // O≠I
   | BIT_LOR_OI ()   => bit_eq_refl {I}() // I=I
   | BIT_LOR_OO () =/=> () // O≠I

prfun bitseqint__bitslen {n,v:int}{bs:bits} .<bs>.
      (bseqint:BITSEQINT (n,bs,v)):BITSLEN (bs,n)
 =case+ bseqint of
   | BEQNIL ()           => BITSLENNIL ()
   | BEQCONS0 (bseqint') => BITSLENCONS (bitseqint__bitslen (bseqint'))
   | BEQCONS1 (bseqint') => BITSLENCONS (bitseqint__bitslen (bseqint'))

prfun bitslor_0_nochange {n:int}{bs,cs,ds:bits} .<bs>.
      (lor_p:BITS_LOR (bs,cs,ds),eq0:BITSEQINT (n,cs,0)):[bs == ds] void
 = scase bs of
   | BitsNil ()       => let
       prval BITS_LOR_NIL () = lor_p
     in bits_eq_refl {BitsNil} () end // BitsNil = BitsNil
   | BitsCons (b,bs') => scase ds of
       | BitsCons (d,ds') => let
           prval BITS_LOR_CONS (blor,bslor) = lor_p
           prval BEQCONS0      (eq0')       = eq0
           prval () = lor_0_nochange (blor)
           prval () = bitslor_0_nochange (bslor,eq0')
         in bits_cons_eq {b,d}{bs',ds'}() end
       | BitsNil () => case+ lor_p of
                       | BITS_LOR_NIL  ()    =/=> ()
                       | BITS_LOR_CONS (_,_) =/=> ()

prfun bitslor__eq_bitslen {bs,cs,ds:bits} .<bs>. (bsor:BITS_LOR (bs,cs,ds))
                          :[n:int] (BITSLEN (bs,n),BITSLEN (cs,n),BITSLEN (ds,n))
 = case+ bsor of
   | BITS_LOR_NIL  ()          => (BITSLENNIL,BITSLENNIL,BITSLENNIL)
   | BITS_LOR_CONS (bor,bs'or) => let
       prval (bs'len,cs'len,ds'len) = bitslor__eq_bitslen (bs'or)
     in (BITSLENCONS (bs'len),BITSLENCONS (cs'len),BITSLENCONS (ds'len)) end

prfun bitslen_injective {n,m:int}{bs:bits} .<bs>.
                        (len_n:BITSLEN (bs,n), len_m:BITSLEN (bs,m)):[n == m] void
 = scase bs of
   | BitsNil ()       => let
       prval BITSLENNIL () = len_n
       prval BITSLENNIL () = len_m
     in end
   | BitsCons (b,bs') => let
       prval BITSLENCONS (len_n') = len_n
       prval BITSLENCONS (len_m') = len_m
     in bitslen_injective (len_n',len_m') end

prfn change_bit_bits_eq {n,bn:int}{b,c:bit | b == c}{bs,cs,ds,es:bits | bs == ds; cs == es}
                        (chbits:CHANGE_BIT_BITS (n,bs,bn,b,cs)): CHANGE_BIT_BITS (n,ds,bn,c,es)
 = let
     prval EQBIT ()  = eqbit_make {b,c} ()
     prval EQBITS () = eqbits_make {bs,ds} ()
     prval EQBITS () = eqbits_make {cs,es} ()
   in chbits end

prfn bit_eq_comm {b,c:bit | b == c} ():[c == b] void
 = let prval EQBIT () = eqbit_make {b,c} () in bit_eq_refl {b} () end

prfn bits_eq_comm {bs,cs:bits | bs == cs} ():[cs == bs] void
 = let prval EQBITS () = eqbits_make {bs,cs} () in bits_eq_refl {bs} () end

prfun singlebitslor__changebit1 {n,bn:int}{bs,cs,ds:bits} .<bs>.
      (single:SINGLE_BIT_BITS (n,bn,cs),lor_p:BITS_LOR (bs,cs,ds))
      : CHANGE_BIT_BITS (n,bs,bn,I,ds)
 = case+ single of
   | SINGLE_BIT_BITS_bas {n':int}{bits0:bits} (beqint)  => let
       prval BITS_LOR_CONS {b,c,d:bit}{bs',cs',ds':bits}
                           (bit_lor,bits_lor) = lor_p
       prval (bs'len,cs'len,ds'len)           = bitslor__eq_bitslen (bits_lor)
       prval (cs'len2)                        = bitseqint__bitslen (beqint)
       prval ()                               = bitslen_injective (cs'len, cs'len2)
       prval ()                               = lor_1_assign {b,d} (bit_lor)
       prval ()                               = bit_eq_comm {I,d}()
       prval ()                               = bitslor_0_nochange {n'}{bs',cs',ds'}(bits_lor,beqint)
       prval ()                               = bits_eq_comm {bs',ds'}()
       // CHANGE_BIT_BITS (n'+1,BitsCons (b,bs'),n',d,BitsCons (d,bs'))
       prval chbit                            = CHANGE_BIT_BITS_bas {n'}{b,d}{bs'} (bs'len)
       // I:bs' == d:ds'を証明する
       prval ()                               = bit_eq_refl {d} ()
       prval ()                               = bits_cons_eq {d,d}{bs',ds'} ()
       prval ()                               = bits_eq_refl {bs} ()
     in change_bit_bits_eq {n,n'}{d,I}{bs,BitsCons (d,bs'),bs,BitsCons (d,ds')}(chbit) end
   | SINGLE_BIT_BITS_ind {n',bn}{cs'}(single') => let
       prval BITS_LOR_CONS {b,c,d:bit}{bs',cs',ds':bits}
                           (bit_lor,bits_lor) = lor_p
       prval ()                               = lor_0_nochange (bit_lor)
       // CHANGE_BIT_BITS (n'+1,BitsCons (?,bs'),bn,I,BitsCons (?,ds'))
       prval chbit                            = CHANGE_BIT_BITS_ind (singlebitslor__changebit1 (single',bits_lor))
       prval ()                               = bits_eq_refl {ds'} ()
       prval ()                               = bits_cons_eq {b,d}{ds',ds'} ()
       prval ()                               = bit_eq_refl {I} ()
       prval ()                               = bits_eq_refl {bs} ()
     in change_bit_bits_eq {n,bn}{I,I}{bs,BitsCons (b,ds'),bs,BitsCons (d,ds')}(chbit) end

(*
fn {bs:bits}
  setBitBits {n,bn:nat | bn < n; n < INTBITS} (bits_uint_t (n,bs),int bn)
  : [cs:bits] (CHANGE_BIT_BITS (bs,bn,I,cs) | bits_uint_t (n,cs))
*)
implement {bs:bits} setBitBits {n,bn} (v,bn)
 = let
     prval (biteq | intv) = v
     prval () = beqint_is_nat (biteq)
     val+ (bs_single | sb_v)  = make_single_bit<n,bn> (bn)
     val+ (bs_lor    | lor_v) = bits_uint_lor (v,sb_v)
     //val+ result = g1int2uint (intv) lor g0int2uint (1<<bn)
     prval changebit = singlebitslor__changebit1 (bs_single, bs_lor)
   in (changebit | lor_v) end

prfun bitsland__eq_bitslen {bs,cs,ds:bits} .<bs>. (bsand:BITS_LAND (bs,cs,ds))
                           :[n:int] (BITSLEN (bs,n),BITSLEN (cs,n),BITSLEN (ds,n))
 = case+ bsand of
   | BITS_LAND_NIL  ()          => (BITSLENNIL,BITSLENNIL,BITSLENNIL)
   | BITS_LAND_CONS (band,bs'and) => let
       prval (bs'len,cs'len,ds'len) = bitsland__eq_bitslen (bs'and)
     in (BITSLENCONS (bs'len),BITSLENCONS (cs'len),BITSLENCONS (ds'len)) end

prfun bitsnot__eq_bitslen {bs,cs:bits} .<bs>.(bs_not:BITS_NOT (bs,cs))
                          :[n:int] (BITSLEN (bs,n),BITSLEN (cs,n))
 = case+ bs_not of
   | BITS_NOT_NIL ()             => (BITSLENNIL,BITSLENNIL)
   | BITS_NOT_CONS (bnot,bs'not) => let
       prval (bs'len,cs'len) = bitsnot__eq_bitslen (bs'not)
   in (BITSLENCONS (bs'len),BITSLENCONS (cs'len)) end

prfn land_1_nochange {b,c:bit} (band:BIT_LAND (b,I,c)):[b == c] void
 = case+ band of
   | BIT_LAND_II ()   => bit_eq_refl {I} () // I=I
   | BIT_LAND_IO () =/=> () // O≠I
   | BIT_LAND_OI ()   => bit_eq_refl {O} () // O=O
   | BIT_LAND_OO () =/=> () // O≠I

prfn land_0_assign   {b,c:bit} (band:BIT_LAND (b,O,c)):[O == c] void
 = case+ band of
   | BIT_LAND_II () =/=> () // I≠O
   | BIT_LAND_IO ()   => bit_eq_refl {O} () // O=O
   | BIT_LAND_OI () =/=> () // I≠O
   | BIT_LAND_OO ()   => bit_eq_refl {O} () // O=O

prfun bitsland_not0_nochange {n:int}{bs,cs,ds,es:bits} .<bs>.
      (bs_and_ds:BITS_LAND (bs,ds,es),cs_eq0:BITSEQINT (n,cs,0),cs_not:BITS_NOT (cs,ds))
      :[bs == es] void
 = scase bs of
   | BitsNil ()       => let
       prval BITS_LAND_NIL () = bs_and_ds
     in bits_eq_refl {BitsNil} () end // BitsNil = BitsNil
   | BitsCons (b,bs') => scase es of
       | BitsCons (e,es') => let
           prval BITS_LAND_CONS (b_and_d,bs'_and_ds') = bs_and_ds
           prval BITS_NOT_CONS (c_not,cs'_not)        = cs_not
           prval BEQCONS0 (cs'_eq0)                   = cs_eq0
           prval BIT_NOT0 ()                          = c_not
           prval ()                                   = land_1_nochange (b_and_d)
           prval ()                                   = bitsland_not0_nochange (bs'_and_ds',cs'_eq0,cs'_not)
         in bits_cons_eq {b,e}{bs',es'}() end
       | BitsNil () => case+ bs_and_ds of
                       | BITS_LAND_NIL  ()    =/=> ()
                       | BITS_LAND_CONS (_,_) =/=> ()

prfun notsinglebitsland__changebit0 {n,bn:int}{bs,cs,ds,es:bits} .<bs>.
      (cs_is_single:SINGLE_BIT_BITS (n,bn,cs),cs_not:BITS_NOT (cs,ds),bs_and_ds:BITS_LAND (bs,ds,es))
      :CHANGE_BIT_BITS (n,bs,bn,O,es)
 = case+ cs_is_single of
   | SINGLE_BIT_BITS_bas {n':int}{cs':bits} (cs'_eq_0)  => let
       prval BITS_NOT_CONS {c,d}{cs',ds'} (BIT_NOT1 (),cs'_not)      = cs_not
       prval BITS_LAND_CONS {b,d,e:bit}{bs',ds',es':bits}
                            (b_and_d,bs'_and_ds') = bs_and_ds
       prval [cd'n:int](cs'len,ds'len) = bitsnot__eq_bitslen (cs'_not)
       prval (cs'len') = bitseqint__bitslen (cs'_eq_0)
       prval [bde'n:int](bs'len,ds'len',es'len) = bitsland__eq_bitslen (bs'_and_ds')
//       prval (cs'len2)                        = bitseqint__bitslen (cs'_eq_0)
       prval ()                               = bitslen_injective (ds'len, ds'len')
       prval ()                               = bitslen_injective (cs'len, cs'len')
       prval ()                               = land_0_assign {b,e} (b_and_d)
       prval ()                               = bit_eq_comm {O,e}()
       prval ()                     = bitsland_not0_nochange {n'}{bs',cs',ds',es'}(bs'_and_ds',cs'_eq_0,cs'_not)
//       prval ()                               = bits_eq_comm {bs',ds'}()
       // CHANGE_BIT_BITS (n'+1,BitsCons (b,bs'),n',d,BitsCons (e,bs'))
       prval chbit                  = CHANGE_BIT_BITS_bas {n'}{b,e}{bs'} (bs'len)
       // I:bs' == e:es'を証明する
       prval ()                     = bit_eq_refl {e} ()
       prval ()                     = bits_cons_eq {e,e}{bs',es'} ()
       prval ()                     = bits_eq_refl {bs} ()
     in change_bit_bits_eq {n,n'}{e,O}{bs,BitsCons (e,bs'),bs,BitsCons (e,es')}(chbit) end
//       in chbit end
   | SINGLE_BIT_BITS_ind {n',bn}{cs'}(single') => let
       prval BITS_NOT_CONS (BIT_NOT0 (),cs'_not)       = cs_not
       prval BITS_LAND_CONS {b,d,e:bit}{bs',ds',es':bits}
                           (b_and_d,bs'_and_ds') = bs_and_ds
       prval ()                                  = land_1_nochange (b_and_d)
       // CHANGE_BIT_BITS (n'+1,BitsCons (?,bs'),bn,I,BitsCons (?,ds'))
       prval chbit                               = CHANGE_BIT_BITS_ind (notsinglebitsland__changebit0 (single',cs'_not,bs'_and_ds'))
       prval ()                                  = bits_eq_refl {es'} ()
       prval ()                                  = bits_cons_eq {b,e}{es',es'} ()
       prval ()                                  = bit_eq_refl {O} ()
       prval ()                                  = bits_eq_refl {bs} ()
     in change_bit_bits_eq {n,bn}{O,O}{bs,BitsCons (b,es'),bs,BitsCons (e,es')}(chbit) end

implement {bs} clearBitBits {n,bn} (v,bn)
 = let
     prval (biteq | intv) = v
     prval () = beqint_is_nat (biteq)
     val+ (bs_single | sb_v)    = make_single_bit<n,bn> (bn)
     val+ (bs_not    | notsb_v) = bits_uint_not (sb_v)
     val+ (bs_land   | land_v)  = bits_uint_land (v,notsb_v)
     //val+ result = g1int2uint (intv) lor g0int2uint (1<<bn)
     prval changebit = notsinglebitsland__changebit0 (bs_single,bs_not,bs_land)
   in (changebit | land_v) end
// TODO 宣言の修正に合わせて直す
(*
fn {b:bit}{bs:bits}
  changeBitBits {n,bn:nat | bn < n}{n < INTBITS} (bits_uint_t (n,bs),int bn,bit_uint_t b)
  : [bs':bits] (CHANGE_BIT_BITS (bs,bn,b,bs') | bits_uint_t (n,bs'))
*)
implement {b}{bs} changeBitBits {n,bn} (v,bn,bint)
 = let
     prval (biteq | bint') = bint
     prval () = beqint_nat2<b> (biteq)
   in if (bint' = 0)
      then let prval () = beq0__b_is_O<b> (biteq)
                 val+ (chgbit | bitint) = clearBitBits (v,bn)
             in (chgbit_bit_eq (chgbit) | bitint) end
      else let prval () = beq1__b_is_I<b> (biteq)
                 val+ (chgbit | bitint) = setBitBits (v,bn)
             in (chgbit_bit_eq (chgbit) | bitint) end
   end

prfun bitsland0_assign {n:int}{bs,cs,ds:bits} .<bs>.
                       (bs_and_cs:BITS_LAND (bs,cs,ds), cs_eq_0:BITSEQINT (n,cs,0))
                       :[cs == ds] void
 = case+ bs_and_cs of
   | BITS_LAND_NIL ()                      => bits_eq_refl {BitsNil}()
   | BITS_LAND_CONS {b,c,d}{bs',cs',ds'} (b_and_c, bs'_and_cs') =>
     case+ cs_eq_0 of
     | BEQCONS0 (cs'_eq_0) => let
         prval () = land_0_assign (b_and_c)
         prval () = bitsland0_assign (bs'_and_cs',cs'_eq_0)
       in bits_cons_eq {O,d}{cs',ds'} () end
     | BEQCONS1 (cs'_eq_0) =/=> ()
     | BEQNIL ()           =/=> ()

prfun bitseqint_injective {n,m,v,w:int}{bs:bits} .<bs>.
                          (bs_eq_v:BITSEQINT (n,bs,v), bs_eq_w:BITSEQINT (m,bs,w))
                          :[n == m][v == w] void
 = scase bs of
   | BitsNil ()       => let
       prval BEQNIL () = bs_eq_v
       prval BEQNIL () = bs_eq_w
     in end
   | BitsCons (b,bs') =>
     scase b of
     | O () => let
         prval BEQCONS0 (bs'_eq_v') = bs_eq_v
         prval BEQCONS0 (bs'_eq_w') = bs_eq_w
       in bitseqint_injective (bs'_eq_v',bs'_eq_w') end
     | I () => let
         prval BEQCONS1 (bs'_eq_v') = bs_eq_v
         prval BEQCONS1 (bs'_eq_w') = bs_eq_w
       in bitseqint_injective (bs'_eq_v',bs'_eq_w') end

prfn bitseq_comm {bs,cs:bits | bs == cs} ():[cs == bs] void
 = let prval EQBITS () = eqbits_make {bs,cs} () in bits_eq_refl {bs} () end


//extern prfun bitseq_bitseqint_assign {n,v:int}{bs,cs:bits | bs == cs} (BITSEQINT (n,bs,v))
//                                     : BITSEQINT (n,cs,v)
prfn bitseq_bitseqint_assign {n,v:int}{bs,cs:bits | bs == cs}
                             (bs_eq_v:BITSEQINT (n,bs,v)) : BITSEQINT (n,cs,v)
 = let prval EQBITS () = eqbits_make {bs,cs} () in bs_eq_v end

prfn testbits_eq_assign {n:int}{b,c,d:bit | b == c}{bs:bits}
                        (testbits:TEST_BIT_BITS (bs,n,b == d)): TEST_BIT_BITS (bs,n,c == d)
 = let prval EQBIT () = eqbit_make {b,c} () in testbits end

//extern prfun int_eq_neq {n,m:int | n == m}():[~(n != m)] void

//extern praxi bit_not_eq__neq {} ():[] void

(*
stadef neq_bit_bit (b,c:bit):bool = (b == I  &&  c == O) ||
                                    (b == O  &&  c == I)
*)


prfn bit_not_O_eq_I ():[~(O == I)] void
 = let
     prval () = bit_not_I_eq_O ()
     prval () = bit_not_eq_comm {I,O}()
   in end

prfn bit_I_neq_O ():[I != O] void = bit_not_I_eq_O ()
prfn bit_O_neq_I ():[O != I] void = bit_not_O_eq_I ()

prfn bit_neq__not_eq {b,c:bit | b != c}():[~(b == c)] void = ()
prfn bit_eq__not_neq {b,c:bit | b == c}():[~(b != c)] void = ()

prfun singlebit_bn_lt_n {n,bn:int}{bs:bits} .<bs>. (single:SINGLE_BIT_BITS (n,bn,bs)):[bn < n] void
 = case+ single of
   | SINGLE_BIT_BITS_bas (bs'_eq_0) => ()
   | SINGLE_BIT_BITS_ind (bs'_is_single) => singlebit_bn_lt_n (bs'_is_single)

prfun singlebit_and_bs_neq0__testbit
      {n,bn,v:int | n < INTBITS; bn < n}
      {bs,cs,ds:bits}
      .<bs>.
      (bs_and_cs    :BITS_LAND (bs,cs,ds),
       cs_is_single :SINGLE_BIT_BITS (n,bn,cs),
       ds_eq_v      :BITSEQINT (n,ds,v))
      : TEST_BIT_BITS (bs,bn,0 != v)
 = case+ cs_is_single of
   | SINGLE_BIT_BITS_bas {n':int}{cs':bits} (cs'_eq_0)  => let
       prval BITS_LAND_CONS {b,c,d}{bs',cs',ds'}(b_and_c,bs'_and_cs')
                     = bs_and_cs
       prval ()      = bitsland0_assign (bs'_and_cs',cs'_eq_0)
       prval [bcd'n:int] (bs'_len,cs'_len,ds'_len)
                     = bitsland__eq_bitslen (bs'_and_cs')
       prval cs'_len' = bitseqint__bitslen (cs'_eq_0)
       prval ()      = bitslen_injective (cs'_len, cs'_len')
     in case+ ds_eq_v of
        | BEQNIL   ()          =/=> ()
        | BEQCONS0 {ds'n}{ds''}{v'} (ds'_eq_v')   => let
              prval ()       = bitsland0_assign {n'}{bs',cs',ds'}(bs'_and_cs',cs'_eq_0)
              prval ()       = bitseq_comm {cs',ds'}()
            prval ds'_eq_0 = bitseq_bitseqint_assign {n',0}{cs',ds'}(cs'_eq_0)
            prval ()       = bitseqint_injective {n',n',0,v'} (ds'_eq_0,ds'_eq_v')
              prval eqintv'  = eqint_make {v',0} ()
              prval eqintv'  = eqint_make {0,v'+v'} ()
            prval ()       = land_1_nochange {b,O} (b_and_c)
              prval ()       = bits_eq_refl {bs'} ()
              prval ()       = bits_cons_eq {b,O}{bs',bs'} ()
              prval ()       = bits_eq_comm {BitsCons (b,bs'), BitsCons (O,bs')} ()
              prval ()       = bit_eq_comm {b,O} ()
            //prval eqbool   = eqbool_make {b == O, } ()
              prval EQBIT () = eqbit_make {b,O} ()
              prval ()       = bit_I_neq_O ()
              prval ()       = bit_not_O_eq_I ()
            prval testbits = TEST_BIT_BITS_bas {n'}{b}{bs'} (bs'_len)
          in testbits end
          //in testbits_eq_assign {n'}{O,b,O}{bs}(testbits) end
        | BEQCONS1 {ds'n}{ds''}{v'} (ds'_eq_v')   => let
            prval ds'_eq_0 = bitseq_bitseqint_assign {n',0}{cs',ds'}(cs'_eq_0)
            prval ()       = bitseqint_injective {n',n',0,v'} (ds'_eq_0,ds'_eq_v')
            prval ()       = land_1_nochange {b,I} (b_and_c)
          in TEST_BIT_BITS_bas (bs'_len) end
     end
   | SINGLE_BIT_BITS_ind {n',bn}{cs'} (cs'_is_single) => let
       prval BITS_LAND_CONS {b,c,d}{bs',cs',ds'} (b_and_c,bs'_and_cs') = bs_and_cs
       prval ()                                   = singlebit_bn_lt_n (cs'_is_single)
     in case+ ds_eq_v of
        | BEQCONS0 {ds'n}{ds'}{v'} (ds'_eq_v') => let
            prval testbit' = singlebit_and_bs_neq0__testbit (bs'_and_cs',cs'_is_single,ds'_eq_v')
          in TEST_BIT_BITS_ind (testbit') end
        | BEQCONS1 {ds'n}{ds''}{v'} (ds'_eq_v') =/=> let
            prval ()         = land_0_assign (b_and_c)
            prval ()         = bit_eq_comm {O,d} ()
            prval EQBIT ()   = eqbit_make {d,O} ()
            //prval ()         = bit_eqI_neqO {d} ()
            prval ()         = bit_eq_refl {d} ()
            //prval ()         = bits_cons_eq {d,d}{ds',ds''} ()
          in end
     end
(*
fn {bs:bits}
  testBitBits {n,bn:nat | bn < n}{n < INTBITS}
              (bits_uint_t (n,bs),uint bn)
              :[b:bool] (TEST_BIT_BITS (bs,bn,b) | bool b)
*)
implement {bs} testBitBits {n,bn} (v,bn)
 = let
     val+  (cs_is_single | cs_v)      = make_single_bit<n,bn> (bn)
     val+  (bs_and_cs    | ds_uint_v) = bits_uint_land (v,cs_v)
     val+  (dseqint      | uint_v)    = ds_uint_v
     prval (bstest)                   = singlebit_and_bs_neq0__testbit (bs_and_cs,cs_is_single,dseqint)
   in (bstest | i2u(0) != uint_v) end









