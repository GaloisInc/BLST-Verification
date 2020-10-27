+++
title = "build/keygen_output"
date = 2020-10-27
+++
# LLVM Functions Analyzed

* blst_keygen
    * verified
* blst_sha256_block_data_order
    * assumed
* HKDF_Expand
    * verified
* blst_sha256_block_data_order
    * assumed
* HKDF_Extract
    * verified
* blst_sha256_block_data_order
    * assumed
* blst_keygen
    * verified
* blst_sha256_block_data_order
    * assumed
* HKDF_Expand
    * verified
* blst_sha256_block_data_order
    * assumed
* HKDF_Extract
    * verified
* blst_sha256_block_data_order
    * assumed
* blst_keygen
    * verified
* blst_sha256_block_data_order
    * assumed
* HKDF_Expand
    * verified
* blst_sha256_block_data_order
    * assumed
* HKDF_Extract
    * verified
* blst_sha256_block_data_order
    * assumed
* blst_keygen
    * verified
* blst_sha256_block_data_order
    * assumed
* HKDF_Expand
    * verified
* blst_sha256_block_data_order
    * assumed
* HKDF_Extract
    * verified
* blst_sha256_block_data_order
    * assumed
* blst_keygen
    * verified
* blst_sha256_block_data_order
    * assumed
* HKDF_Expand
    * verified
* blst_sha256_block_data_order
    * assumed
* HKDF_Extract
    * verified
* blst_sha256_block_data_order
    * assumed
* limbs_from_be_bytes
    * verified
* redcx_mont_256
    * assumed
* redcx_mont_256
    * assumed
* mulx_mont_sparse_256
    * assumed
* blst_sha256_hcopy
    * assumed
* blst_sha256_emit
    * assumed
* blst_sha256_bcopy
    * assumed
* blst_sha256_bcopy
    * assumed
* blst_sha256_bcopy
    * assumed
* blst_sha256_bcopy
    * assumed
* blst_sha256_bcopy
    * assumed
* blst_sha256_bcopy
    * assumed
* blst_sha256_bcopy
    * assumed
* blst_sha256_bcopy
    * assumed
* blst_sha256_bcopy
    * assumed
* blst_sha256_bcopy
    * assumed
* blst_sha256_bcopy
    * assumed
* blst_sha256_bcopy
    * assumed
* blst_sha256_bcopy
    * assumed
* blst_sha256_bcopy
    * assumed
* blst_sha256_bcopy
    * assumed
* blst_sha256_bcopy
    * assumed
* blst_sha256_bcopy
    * assumed
* blst_sha256_bcopy
    * assumed
* blst_sha256_bcopy
    * assumed
* blst_sha256_bcopy
    * assumed
* blst_sha256_bcopy
    * assumed
* blst_sha256_bcopy
    * assumed
* blst_sha256_bcopy
    * assumed
* blst_sha256_bcopy
    * assumed
* blst_sha256_bcopy
    * assumed
* blst_sha256_bcopy
    * assumed
* blst_sha256_bcopy
    * assumed
* blst_sha256_bcopy
    * assumed
* blst_sha256_bcopy
    * assumed
* blst_sha256_bcopy
    * assumed
* blst_sha256_bcopy
    * assumed
* blst_sha256_bcopy
    * assumed
* blst_sha256_bcopy
    * assumed
* blst_sha256_bcopy
    * assumed
* blst_sha256_bcopy
    * assumed
* blst_sha256_bcopy
    * assumed
* blst_sha256_bcopy
    * assumed
* blst_sha256_bcopy
    * assumed
* blst_sha256_bcopy
    * assumed
* blst_sha256_bcopy
    * assumed
* blst_sha256_bcopy
    * assumed
* blst_sha256_bcopy
    * assumed
* blst_sha256_bcopy
    * assumed
* blst_sha256_bcopy
    * assumed
* blst_sha256_bcopy
    * assumed
* blst_sha256_bcopy
    * assumed
* blst_sha256_bcopy
    * assumed
* blst_sha256_bcopy
    * assumed
* blst_sha256_bcopy
    * assumed
* blst_sha256_bcopy
    * assumed
* blst_sha256_bcopy
    * assumed
* blst_sha256_bcopy
    * assumed
* blst_sha256_bcopy
    * assumed
* blst_sha256_bcopy
    * assumed
* blst_sha256_bcopy
    * assumed
* blst_sha256_bcopy
    * assumed
* blst_sha256_bcopy
    * assumed
* blst_sha256_bcopy
    * assumed
* blst_sha256_bcopy
    * assumed
* blst_sha256_bcopy
    * assumed
* blst_sha256_bcopy
    * assumed
* blst_sha256_bcopy
    * assumed
* blst_sha256_bcopy
    * assumed
* blst_sha256_bcopy
    * assumed
# Theorems Proved or Assumed

* Theorem:
~~~~
  let { x@1 = Prelude.Vec 8
                Prelude.Bool
        x@2 = Cryptol.TCNum 16
        x@3 = Cryptol.TCNum 80
      }
   in (IKM : Prelude.Vec 80 x@1)
  -> (info : Prelude.Vec 16 x@1)
  -> let { x@4 = (IKM,info)
      }
   in Prelude.EqTrue
        (Cryptol.ecEq
           (Prelude.Vec 256 Prelude.Bool)
           (Cryptol.PEqSeqBool
              (Cryptol.TCNum 256))
           (pow256_abs
              (KeyGen_rep x@3 x@2 x@4))
           (KeyGen x@3 x@2 x@4))
~~~~

* Theorem:
~~~~
  let { x@1 = Prelude.Vec 8
                Prelude.Bool
        x@2 = Cryptol.TCNum 16
        x@3 = Prelude.Vec 256
                Prelude.Bool
        x@4 = Cryptol.TCNum 80
      }
   in (salt : x@3)
  -> (IKM : Prelude.Vec 80 x@1)
  -> (info : Prelude.Vec 16 x@1)
  -> Prelude.EqTrue
       (Cryptol.ecEq x@3
          (Cryptol.PEqSeqBool
             (Cryptol.TCNum 256))
          (KeyGenStep x@4 x@2 salt IKM
             info)
          (vec256_abs
             (KeyGenStep_rep x@4 x@2 salt IKM
                info)))
~~~~

* Theorem:
~~~~
  let { x@1 = Prelude.Vec 8
                Prelude.Bool
        x@2 = Cryptol.TCNum 7
        x@3 = Cryptol.TCNum 33
      }
   in (IKM : Prelude.Vec 33 x@1)
  -> (info : Prelude.Vec 7 x@1)
  -> let { x@4 = (IKM,info)
      }
   in Prelude.EqTrue
        (Cryptol.ecEq
           (Prelude.Vec 256 Prelude.Bool)
           (Cryptol.PEqSeqBool
              (Cryptol.TCNum 256))
           (pow256_abs
              (KeyGen_rep x@3 x@2 x@4))
           (KeyGen x@3 x@2 x@4))
~~~~

* Theorem:
~~~~
  let { x@1 = Prelude.Vec 8
                Prelude.Bool
        x@2 = Cryptol.TCNum 7
        x@3 = Prelude.Vec 256
                Prelude.Bool
        x@4 = Cryptol.TCNum 33
      }
   in (salt : x@3)
  -> (IKM : Prelude.Vec 33 x@1)
  -> (info : Prelude.Vec 7 x@1)
  -> Prelude.EqTrue
       (Cryptol.ecEq x@3
          (Cryptol.PEqSeqBool
             (Cryptol.TCNum 256))
          (KeyGenStep x@4 x@2 salt IKM
             info)
          (vec256_abs
             (KeyGenStep_rep x@4 x@2 salt IKM
                info)))
~~~~

* Theorem:
~~~~
  let { x@1 = Prelude.Vec 8
                Prelude.Bool
        x@2 = Cryptol.TCNum 32
        x@3 = Cryptol.TCNum 4
      }
   in (IKM : Prelude.Vec 32 x@1)
  -> (info : Prelude.Vec 4 x@1)
  -> let { x@4 = (IKM,info)
      }
   in Prelude.EqTrue
        (Cryptol.ecEq
           (Prelude.Vec 256 Prelude.Bool)
           (Cryptol.PEqSeqBool
              (Cryptol.TCNum 256))
           (pow256_abs
              (KeyGen_rep x@2 x@3 x@4))
           (KeyGen x@2 x@3 x@4))
~~~~

* Theorem:
~~~~
  let { x@1 = Prelude.Vec 8
                Prelude.Bool
        x@2 = Cryptol.TCNum 32
        x@3 = Cryptol.TCNum 4
        x@4 = Prelude.Vec 256
                Prelude.Bool
      }
   in (salt : x@4)
  -> (IKM : Prelude.Vec 32 x@1)
  -> (info : Prelude.Vec 4 x@1)
  -> Prelude.EqTrue
       (Cryptol.ecEq x@4
          (Cryptol.PEqSeqBool
             (Cryptol.TCNum 256))
          (KeyGenStep x@2 x@3 salt IKM
             info)
          (vec256_abs
             (KeyGenStep_rep x@2 x@3 salt IKM
                info)))
~~~~

* Theorem:
~~~~
  let { x@1 = Prelude.Vec 8
                Prelude.Bool
        x@2 = Cryptol.TCNum 0
        x@3 = Cryptol.TCNum 32
      }
   in (IKM : Prelude.Vec 32 x@1)
  -> (info : Prelude.Vec 0 x@1)
  -> let { x@4 = (IKM,info)
      }
   in Prelude.EqTrue
        (Cryptol.ecEq
           (Prelude.Vec 256 Prelude.Bool)
           (Cryptol.PEqSeqBool
              (Cryptol.TCNum 256))
           (pow256_abs
              (KeyGen_rep x@3 x@2 x@4))
           (KeyGen x@3 x@2 x@4))
~~~~

* Theorem:
~~~~
  let { x@1 = Prelude.Vec 8
                Prelude.Bool
        x@2 = Cryptol.TCNum 0
        x@3 = Cryptol.TCNum 32
        x@4 = Prelude.Vec 256
                Prelude.Bool
      }
   in (salt : x@4)
  -> (IKM : Prelude.Vec 32 x@1)
  -> (info : Prelude.Vec 0 x@1)
  -> Prelude.EqTrue
       (Cryptol.ecEq x@4
          (Cryptol.PEqSeqBool
             (Cryptol.TCNum 256))
          (KeyGenStep x@3 x@2 salt IKM
             info)
          (vec256_abs
             (KeyGenStep_rep x@3 x@2 salt IKM
                info)))
~~~~

* Theorem:
~~~~
  let { x@1 = Prelude.Vec 8
                Prelude.Bool
        x@2 = Cryptol.TCNum 0
        x@3 = Cryptol.TCNum 16
      }
   in (IKM : Prelude.Vec 16 x@1)
  -> (info : Prelude.Vec 0 x@1)
  -> let { x@4 = (IKM,info)
      }
   in Prelude.EqTrue
        (Cryptol.ecEq
           (Prelude.Vec 256 Prelude.Bool)
           (Cryptol.PEqSeqBool
              (Cryptol.TCNum 256))
           (pow256_abs
              (KeyGen_rep x@3 x@2 x@4))
           (KeyGen x@3 x@2 x@4))
~~~~

* Theorem:
~~~~
  let { x@1 = Prelude.Vec 8
                Prelude.Bool
        x@2 = Cryptol.TCNum 0
        x@3 = Cryptol.TCNum 16
        x@4 = Prelude.Vec 256
                Prelude.Bool
      }
   in (salt : x@4)
  -> (IKM : Prelude.Vec 16 x@1)
  -> (info : Prelude.Vec 0 x@1)
  -> Prelude.EqTrue
       (Cryptol.ecEq x@4
          (Cryptol.PEqSeqBool
             (Cryptol.TCNum 256))
          (KeyGenStep x@3 x@2 salt IKM
             info)
          (vec256_abs
             (KeyGenStep_rep x@3 x@2 salt IKM
                info)))
~~~~

* Theorem:
~~~~
  let { x@1 = Cryptol.TCNum 256
        x@2 = Cryptol.TCNum 512
        x@3 = Prelude.Vec 512
                Prelude.Bool
        x@4 = Cryptol.tcAdd x@1 x@1
      }
   in (x : x@3)
  -> Prelude.EqTrue
       (Cryptol.ecEq
          (Prelude.Vec 256 Prelude.Bool)
          (Cryptol.PEqSeqBool x@1)
          (mul_mont_r_bv (redc_r_bv x)
             (vec256_abs RR_rep))
          (drop x@1 x@1 Prelude.Bool
             (Prelude.coerce x@3
                (Cryptol.seq x@4 Prelude.Bool)
                (Cryptol.seq_cong1 x@2 x@4
                   Prelude.Bool
                   (Prelude.unsafeAssert
                      Cryptol.Num
                      x@2
                      x@4))
                (Cryptol.ecMod x@3
                   (Cryptol.PIntegralSeqBool x@2)
                   x
                   (zext x@2 x@1 bv_r)))))
~~~~

* Theorem:
~~~~
  let { x@1 = Prelude.Vec 64
                Prelude.Bool
        x@2 = Prelude.Vec 4 x@1
      }
   in (x : x@2)
  -> Prelude.EqTrue
       (Cryptol.ecEq x@2
          (Cryptol.PEqSeq
             (Cryptol.TCNum 4)
             x@1
             (Cryptol.PEqSeqBool
                (Cryptol.TCNum 64)))
          (vec256_rep (vec256_abs x))
          x)
~~~~

* Theorem:
~~~~
  let { x@1 = Prelude.Vec 256
                Prelude.Bool
      }
   in (x : x@1)
  -> Prelude.EqTrue
       (Cryptol.ecEq x@1
          (Cryptol.PEqSeqBool
             (Cryptol.TCNum 256))
          (vec256_abs (vec256_rep x))
          x)
~~~~

# Solvers Used

* SBV->Z3
* W4 ->z3
* quickcheck
