"
Warning: this generator should not be used for cryptographic work.

    NO WARRANTY

    A Mersenne Twister based on code by Takuji Nishimura and Makoto Matsumoto.

    Before using, initialize the state by using initGen(seed) or initByArray(init_key).

    RandomMT19937 new nextInteger
    (RandomMT19937 new:5489) nextInteger
    (RandomMT19937 newByArray:{16r123 . 16r234 .16r345 . 16r456}) nextInteger

    If heavily used, it may be useful to embed the original C code as inline C code for a big speedup)

    Please read:
        Wikipedia article on Mersenne Twister end esp. MT19937
        http://de.wikipedia.org/wiki/Liste_von_Zufallszahlengeneratoren
        MT home page http://www.math.sci.hiroshima-u.ac.jp/~m-mat/MT/emt.html

    [see also:]
        http://www0.cs.ucl.ac.uk/staff/d.jones/GoodPracticeRNG.pdf
        RandomGenerator - the default; uses the machine's /dev/random if available
        Random  - fast, but generates less quality random numbers
        RandomTT800 - another random generator
        RandomParkMiller - another random generator

    [author:]
        Original algorithm by Takuji Nishimura and Makoto Matsumoto
        Ported to Smalltalk by Claus Gittinger.
"
Class {
	#name : #RandomMT19937,
	#superclass : #Object,
	#instVars : [
		'n',
		'm',
		'matrixA',
		'upperMask',
		'lowerMask',
		'mt',
		'mti'
	],
	#category : #RandomMT19937
}

{ #category : #'instance creation' }
RandomMT19937 class >> new [
    ^ self basicNew 
        initialize;
        initGenRand:(Random randomSeed bitAnd:16rFFFFFFFF)
]

{ #category : #'instance creation' }
RandomMT19937 class >> new:seed [
    ^ self basicNew 
        initialize;
        initGenRand:seed
]

{ #category : #'instance creation' }
RandomMT19937 class >> newByArray:keyArray [
    ^ self basicNew 
        initialize;
        initByArray:keyArray
]

{ #category : #'as yet unclassified' }
RandomMT19937 >> initByArray:keyArray [

    |i j k kLen|

    self initGenRand: 19650218.

    kLen := keyArray size.
    i := 1. j := 0.
    k := (n max: kLen).

    [k > 0] whileTrue:[
        |t|

        t := (((mt at:i+1) bitXor: (((mt at:i) bitXor: ((mt at:i) >> 30)) * 1664525))
                        + (keyArray at:j+1) + j). 
        mt at:i+1 put:(t bitAnd: 16rFFFFFFFF).
        i := i+1. j := j+1.
        (i >= n) ifTrue:[ mt at:1 put:(mt at:n). i := 1. ].
        (j >= kLen) ifTrue:[ j := 0].
        k := k - 1.
    ].

    k := n-1.
    [k > 0] whileTrue:[
        |t|

        t := ((mt at:i+1) bitXor:(((mt at:i) bitXor: ((mt at:i) >> 30)) * 1566083941)) - i.
        mt at:i+1 put:(t bitAnd: 16rFFFFFFFF).
        i := i+1.
        (i >= n) ifTrue:[ mt at:1 put:(mt at:n). i := 1. ].
        k := k - 1.
    ].

    mt at:1 put: 16r80000000. " MSB is 1; assuring non-zero initial array "
]

{ #category : #'as yet unclassified' }
RandomMT19937 >> initGenRand:seedUsed [
    |s|

    s := seedUsed.

    mt at: 1 put: (s bitAnd: 16rFFFFFFFF). 
    mti := 1.
    [mti < n] whileTrue:[
        |t|

        t := (1812433253 * ((mt at: (mti)) bitXor: ((mt at: (mti)) >> 30))) + mti.

        mt at: (mti+1) put: (t bitAnd: 16rFFFFFFFF).
        mti := mti + 1.
    ].

    "
     self new nextInteger
    "
]

{ #category : #'as yet unclassified' }
RandomMT19937 >> initialize [
    n := 624.
    m := 397.
    matrixA := 16r9908b0df.			" constant vector a"
    upperMask := 16r80000000.		" most significant w-r bits "
    lowerMask := 16r7fffffff.		" least significant r bits "

    mt := Array new: n.				" the array for the state vector "
    mti := n + 1.						" mti==N+1 means mt[N] is not initialized "
]

{ #category : #'as yet unclassified' }
RandomMT19937 >> nextBoolean [
    "generates a boolean random"

    ^ self nextInteger > 16r7FFFFFFF
]

{ #category : #'as yet unclassified' }
RandomMT19937 >> nextInteger [
    "generates the next integer in 0..FFFFFFFF"

    | y mag01 |

    mag01 := { 0. matrixA }.
    " mag01[x] = x * MATRIX_A  for x=0,1 "

    (mti >= n) ifTrue: [ " generate N words at one time"
        |kk|

        (mti == (n+1)) ifTrue: [     " if init_genrand() has not been called,"
            self initGenRand:5489.      " a default initial seed is used"
        ].

        kk := 0.
        [kk < (n-m)] whileTrue: [
            y := ((mt at: kk+1) bitAnd:upperMask)
                    bitOr: ((mt at:(kk+1+1)) bitAnd:lowerMask).
            mt at: (kk+1) put: (((mt at: (kk+m+1)) bitXor: (y>>1)) bitXor: (mag01 at: (y bitAnd: 1)+1)).
            kk := kk + 1.
        ].
        [kk < (n-1)] whileTrue:[
            y := ((mt at: (kk+1)) bitAnd:upperMask)
                    bitOr: ((mt at:(kk+1+1)) bitAnd: lowerMask).
            mt at: (kk+1) put: (((mt at: (kk+(m-n)+1)) bitXor: (y>>1)) bitXor:(mag01 at: (y bitAnd: 1)+1)).
            kk := kk + 1.
        ].

        y := ((mt at: (n-1+1)) bitAnd:upperMask) bitOr: ((mt at: 1) bitAnd: lowerMask).
        mt at: n-1+1 put:(((mt at: m) bitXor:(y>>1)) bitXor: (mag01 at:(y bitAnd: 1)+1)).

        mti := 0.
    ].

    y := mt at: (mti+1). mti := mti + 1.

    " Tempering" 
    y := y bitXor: (y >> 11).
    y := y bitXor: ((y << 7) bitAnd: 16r9d2c5680).
    y := y bitXor: ((y << 15) bitAnd: 16refc60000).
    y := y bitXor: (y >> 18).

    ^ y
]
