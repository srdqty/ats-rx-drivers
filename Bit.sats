// bit関連の定義


#define INTBITS				32
#define	INTMAX     		2147483647
#define	INTMAX_HALF		1073741823
#define	UINTMAX_HALF	2147483647

datasort bit = | O | I

datasort bits = BitsNil of () | BitsCons of (bit, bits)

dataprop BITSLEN (bits,int) =
 | BITSLENNIL (BitsNil,0) of ()
 | {n:int}{b:bit}{bs:bits}
   BITSLENCONS (BitsCons (b,bs),n+1) of BITSLEN (bs,n)

praxi bitslen_nat {n:int}{bs:bits} (BITSLEN (bs,n)):[0 <= n] void

dataprop BITEQINT (bit, int) =
 | B0EQ0 (O, 0) of ()
 | B1EQ1 (I, 1) of ()

typedef bit_uint_t (b:bit) = [v:int] (BITEQINT (b,v) | uint v)

dataprop BITSEQINT (int, bits, int) =
 | BEQNIL (0,BitsNil,0) of ()
 | {n:int}{b:bit}{bs:bits}{v,bitv:int | v <= INTMAX_HALF}
   BEQCONS (n+1,BitsCons (b, bs),v+v+bitv)
   of (BITSEQINT (n,bs,v),BITEQINT (b,bitv))

stadef Bits8 (b7,b6,b5,b4,b3,b2,b1,b0:bit): bits =
  BitsCons (b0, BitsCons (b1, BitsCons (b2, BitsCons (b3,
  BitsCons (b4, BitsCons (b5, BitsCons (b6, BitsCons (b7,
  BitsNil))))))))

prfn bits_test1    () : BITSEQINT (0,BitsNil (),0)
prfn bits8_test2   () : BITSEQINT (8,Bits8 (O,O,O,O,O,O,O,O),   0)
prfn bits8_test3   () : BITSEQINT (8,Bits8 (I,I,I,I,I,I,I,I), 255)
prfn bits8_test4_1 () : BITSEQINT (8,Bits8 (O,O,O,O,O,O,O,I),   1)
prfn bits8_test4_2 () : BITSEQINT (8,Bits8 (O,O,O,O,O,O,I,O),   2)
prfn bits8_test4_3 () : BITSEQINT (8,Bits8 (O,O,O,O,O,I,O,O),   4)
prfn bits8_test4_4 () : BITSEQINT (8,Bits8 (O,O,O,O,I,O,O,O),   8)
prfn bits8_test4_5 () : BITSEQINT (8,Bits8 (O,O,O,I,O,O,O,O),  16)
prfn bits8_test4_6 () : BITSEQINT (8,Bits8 (O,O,I,O,O,O,O,O),  32)
prfn bits8_test4_7 () : BITSEQINT (8,Bits8 (O,I,O,O,O,O,O,O),  64)
prfn bits8_test4_8 () : BITSEQINT (8,Bits8 (I,O,O,O,O,O,O,O), 128)

prfn bitscons0_eq_double {bs:bits}{n,v:int | v <= INTMAX_HALF}
  (BITSEQINT (n,bs,v)) : BITSEQINT (n+1,BitsCons (O,bs),v+v)
prfn bitscons0_eq__cons1_inc {bs:bits}{n,v:int}
  (BITSEQINT (n,BitsCons (O,bs),v)) : BITSEQINT (n,BitsCons (I,bs),v+1)

typedef bits_uint_t (n:int,bs:bits) =
  [v:int] (BITSEQINT (n,bs,v) | uint v)

dataprop EQBIT (bit, bit) = {b:bit} EQBIT (b, b)
praxi eqbit_make {b,c:bit | b == c} (): EQBIT (b,c)
praxi bit_eq_refl {b:bit} ():[b == b] void

dataprop EQBITS (bits, bits) = {bs:bits} EQBITS (bs, bs)
praxi eqbits_make {bs,cs:bits | bs == cs} (): EQBITS (bs,cs)
praxi bits_eq_refl {bs:bits} ():[bs == bs] void


dataprop POW2 (int,int) =
 | POW2_0 (0,1) of ()
 | {n,v:int} POW2_N (n+1,v+v) of POW2 (n,v)

praxi pow2_domain_nat {n,npow:int} (POW2 (n,npow)):[0 <= n] void

prfn beqint_is_nat {n,v:int}{bs:bits}
  (beqint_fst:BITSEQINT (n,bs,v)):[0 <= v] void


dataprop CHANGE_BIT_BITS (int,bits,int,bit,bits) =
 | {n:int}{b,c:bit}{bs:bits} CHANGE_BIT_BITS_bas
     (n+1,BitsCons (b,bs),n,c,BitsCons (c,bs)) of (BITSLEN (bs,n))
 | {n,bn:int}{b,c:bit}{bs,cs:bits}
   CHANGE_BIT_BITS_ind(n+1,BitsCons (c,bs),bn,b,BitsCons (c,cs))
    of CHANGE_BIT_BITS (n,bs,bn,b,cs)

dataprop TEST_BIT_BITS (bits,int,bool) =
 | {bn:int}{b:bit}{bs:bits} TEST_BIT_BITS_bas (BitsCons (b,bs),bn,b == I)
     of (BITSLEN (bs,bn))
 | {test:bool}{b:bit}{bs:bits}{bn:int}
   TEST_BIT_BITS_ind (BitsCons (b,bs),bn,test) of TEST_BIT_BITS (bs,bn,test)



fn {b:bit}{bs:bits}
  changeBitBits {n,bn:nat | bn < n; n < INTBITS} (bits_uint_t (n,bs),uint bn,bit_uint_t b)
  : [bs':bits] (CHANGE_BIT_BITS (n,bs,bn,b,bs') | bits_uint_t (n,bs'))

fn {bs:bits}
  setBitBits {n,bn:nat | bn < n; n < INTBITS} (bits_uint_t (n,bs),uint bn)
  : [cs:bits] (CHANGE_BIT_BITS (n,bs,bn,I,cs) | bits_uint_t (n,cs))

fn {bs:bits}
  clearBitBits {n,bn:nat | bn < n; n < INTBITS} (bits_uint_t (n,bs),uint bn)
  : [bs':bits] (CHANGE_BIT_BITS (n,bs,bn,O,bs') | bits_uint_t (n,bs'))

fn {bs:bits}
  testBitBits {n,bn:nat | bn < n}{n < INTBITS} (bits_uint_t (n,bs),uint bn)
  : [b:bool] (TEST_BIT_BITS (bs,bn,b) | bool b)

dataprop BIT_LOR (bit,bit,bit) =
 | BIT_LOR_II (I,I,I) of ()
 | BIT_LOR_IO (I,O,I) of ()
 | BIT_LOR_OI (O,I,I) of ()
 | BIT_LOR_OO (O,O,O) of ()

dataprop BITS_LOR (bits,bits,bits) =
 | BITS_LOR_NIL  (BitsNil,BitsNil,BitsNil) of ()
 | {b,c,d:bit}{bs,cs,ds:bits}
   BITS_LOR_CONS (BitsCons (b,bs),BitsCons (c,cs),BitsCons (d,ds))
    of (BIT_LOR (b,c,d), BITS_LOR (bs,cs,ds))

fn {n:int}{bs,cs:bits} bits_uint_lor (n:bits_uint_t (n,bs),m:bits_uint_t (n,cs)):
   [ds:bits] (BITS_LOR (bs,cs,ds) | bits_uint_t (n,ds))


dataprop BIT_LAND (bit,bit,bit) =
 | BIT_LAND_II (I,I,I) of ()
 | BIT_LAND_IO (I,O,O) of ()
 | BIT_LAND_OI (O,I,O) of ()
 | BIT_LAND_OO (O,O,O) of ()

dataprop BITS_LAND (bits,bits,bits) =
 | BITS_LAND_NIL  (BitsNil,BitsNil,BitsNil) of ()
 | {b,c,d:bit}{bs,cs,ds:bits}
   BITS_LAND_CONS (BitsCons (b,bs),BitsCons (c,cs),BitsCons (d,ds))
    of (BIT_LAND (b,c,d), BITS_LAND (bs,cs,ds))

fn {n:int}{bs,cs:bits} bits_uint_land (n:bits_uint_t (n,bs),m:bits_uint_t (n,cs)):
   [ds:bits] (BITS_LAND (bs,cs,ds) | bits_uint_t (n,ds))


dataprop SINGLE_BIT_BITS (int,int,bits) =
 | {n:int}{bs:bits}    SINGLE_BIT_BITS_bas (n+1,n, BitsCons (I,bs))
                                        of (BITSEQINT (n,bs,0))
 | {n,bn:int}{bs:bits} SINGLE_BIT_BITS_ind (n+1,bn,BitsCons (O,bs))
                                        of (SINGLE_BIT_BITS (n,bn,bs))

// 1 << bn
fn {n,bn:int} make_single_bit (bn:uint bn):
  [bs:bits] (SINGLE_BIT_BITS (n,bn,bs) | bits_uint_t (n,bs))


dataprop BIT_NOT (bit,bit) =
 | BIT_NOT1 (I,O)
 | BIT_NOT0 (O,I)

dataprop BITS_NOT (bits,bits) =
 | BITS_NOT_NIL  (BitsNil,BitsNil) of ()
 | {b,c:bit}{bs,cs:bits}
   BITS_NOT_CONS (BitsCons (b,bs),BitsCons (c,cs))
    of (BIT_NOT (b,c), BITS_NOT (bs,cs))

stadef neq_bit_bit (b,c:bit):bool = ~(b == c)
stadef != = neq_bit_bit

praxi bit_not_I_eq_O ():[I != O] void
praxi bit_not_eq_comm {b,c:bit | b != c} ():[c != b] void

fn {n:int}{bs:bits} bits_uint_not (n:bits_uint_t (n,bs)):
   [cs:bits] (BITS_NOT (bs,cs) | bits_uint_t (n,cs))



datasort permission = Permit | Prohibit

datasort bit_permission = BitPermission of
  (permission(*of 0*),permission(*of 1*))

datasort bit_permissions = 
 | BitPermsNil of ()
 | BitPermsCons of (bit_permission,bit_permissions)

stadef BitPermissions8 (b7_0,b7_1,b6_0,b6_1,b5_0,b5_1,b4_0,b4_1,
                        b3_0,b3_1,b2_0,b2_1,b1_0,b1_1,b0_0,b0_1:permission): bit_permissions =
  BitPermsCons (BitPermission (b0_0,b0_1),BitPermsCons (BitPermission (b1_0,b1_1),
  BitPermsCons (BitPermission (b2_0,b2_1),BitPermsCons (BitPermission (b3_0,b3_1),
  BitPermsCons (BitPermission (b4_0,b4_1),BitPermsCons (BitPermission (b5_0,b5_1),
  BitPermsCons (BitPermission (b6_0,b6_1),BitPermsCons (BitPermission (b7_0,b7_1),
  BitPermsNil ()))))))))

dataprop BIT_PERMIT_CERTIFICATE (bit_permission,bit) =
 | {p1:permission} BITPERMCERT_0 (BitPermission (Permit,p1),O) of ()
 | {p0:permission} BITPERMCERT_1 (BitPermission (p0,Permit),I) of ()

dataprop BIT_PERMIT_CERTIFICATES (int,bit_permissions,bits) =
 | BITPERMCERTS_NIL (0, BitPermsNil, BitsNil) of ()
 | {n:int}{p:bit_permission}{ps:bit_permissions}{b:bit}{bs:bits}
   BITPERMCERTS_CONS (n+1,BitPermsCons (p,ps),BitsCons (b,bs))
    of (BIT_PERMIT_CERTIFICATE (p,b),BIT_PERMIT_CERTIFICATES (n,ps,bs))


prfn breqperm_0 {bs:bits}(
    BIT_PERMIT_CERTIFICATES (8,BitPermissions8 (
        Permit,Prohibit, Permit,Prohibit, Permit,Prohibit, Permit,Prohibit,
        Permit,Prohibit, Permit,Prohibit, Permit,Prohibit, Permit,Prohibit),
      bs))
    : [bs == Bits8 (O,O,O,O,O,O,O,O)] void

prfn breqperm_1 {bs:bits}(
    BIT_PERMIT_CERTIFICATES (8,BitPermissions8 (
        Permit,Prohibit, Permit,Prohibit, Permit,Prohibit, Permit,Prohibit,
        Permit,Prohibit, Permit,Prohibit, Permit,Prohibit, Prohibit,Permit),
      bs))
    : [bs == Bits8 (O,O,O,O,O,O,O,I)] void

prfn breqperm_2 {bs:bits}(
    BIT_PERMIT_CERTIFICATES (8,BitPermissions8 (
        Permit,Prohibit, Permit,Prohibit, Permit,Prohibit, Permit,Prohibit,
        Permit,Prohibit, Permit,Prohibit, Prohibit,Permit, Permit,Prohibit),
      bs))
    : [bs == Bits8 (O,O,O,O,O,O,I,O)] void

prfn breqperm_128 {bs:bits}(
    BIT_PERMIT_CERTIFICATES (8,BitPermissions8 (
        Prohibit,Permit, Permit,Prohibit, Permit,Prohibit, Permit,Prohibit,
        Permit,Prohibit, Permit,Prohibit, Permit,Prohibit, Permit,Prohibit),
      bs))
    : [bs == Bits8 (I,O,O,O,O,O,O,O)] void

prfn breqperm_255 {bs:bits}(
    BIT_PERMIT_CERTIFICATES (8,BitPermissions8 (
        Prohibit,Permit, Prohibit,Permit, Prohibit,Permit, Prohibit,Permit, 
        Prohibit,Permit, Prohibit,Permit, Prohibit,Permit, Prohibit,Permit),
      bs))
    : [bs == Bits8 (I,I,I,I,I,I,I,I)] void

prfn breqperm_all {bs:bits}(BITSLEN (bs,8)):
    BIT_PERMIT_CERTIFICATES (8,BitPermissions8 (
        Permit,Permit, Permit,Permit, Permit,Permit, Permit,Permit,
        Permit,Permit, Permit,Permit, Permit,Permit, Permit,Permit),
      bs)

prfn breqperm_inhaditat {any_prop:prop}{n:int}{bs:bits}{ps:bit_permissions}
    (BIT_PERMIT_CERTIFICATES (n,
       BitPermsCons(BitPermission (Prohibit,Prohibit), ps),
       bs)): any_prop

dataprop BIT_PERMS_ADD (bit_permissions,bit_permissions,bit_permissions) =
| {ps:bit_permissions} BIT_PERMS_ADD_NIL (BitPermsNil (),ps,ps) of ()
| {p:bit_permission}{ps,qs,rs:bit_permissions}
  BIT_PERMS_ADD_CONS (BitPermsCons (p,ps),qs,BitPermsCons (p,rs))
    of BIT_PERMS_ADD (ps,qs,rs)

prfun breqperms_prohibit {any_prop:prop}{n:int}{bs:bits}{ps,qs,rs:bit_permissions}
    (BIT_PERMS_ADD (ps,BitPermsCons (BitPermission (Prohibit,Prohibit),qs),rs),
     BIT_PERMIT_CERTIFICATES (n,rs,bs))
    : any_prop




