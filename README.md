```
Copyright (c) 2020 Galois, Inc.
SPDX-License-Identifier: Apache-2.0 OR MIT
```

# blst Verification

This repository contains specifications and correctness proofs for the [blst](https://github.com/supranational/blst) BLS12-381 signature library.

# Building and running
The easiest way to build the library and run the proofs is to use [Docker](https://www.docker.com/).

1. Install [Docker](https://docs.docker.com/get-docker/) and [Docker Compose](https://docs.docker.com/compose/install/).
2. Clone the submodules: `git submodule update --init`
3. Build a Docker image containing all of the dependencies: `docker-compose build`
4. Run the proofs inside the Docker container: `docker-compose run blst`

Running `docker-compose run --entrypoint bash blst` will enter an interactive shell within the container, which is often useful for debugging.

# Proof status
The proofs are still underway.  Proving involves writing Cryptol definitions for the functions defined by the BLS12-381 specifications, writing SAWscript specifications for the functions of the library, and writing proof scripts in SAW.  Along the way we write Cryptol definitions and SAWScript specifications for other intermediate functions, to break the main proofs into manageable parts.

The proofs are also staged.  The first set of specifications and proofs state only that the called functions will return without error.  These show the memory-safety of these functions.  The next set then expands on these specifications to include a proof that the functions return proper results.

## Cryptol definitions

Cryptol definitions exist for the BLS12-381 parameters, and for all functions needed for the minimal-signature-size suite `BLS_SIG_BLS12381G1_XMD:SHA-256_SSWU_RO_NUL_`, other than for the aggregate signing and aggregate verification operations.  Definitions for the minimal-pubkey-size suite and for the aggregate operations is in progress.

## Memory Safety proofs

We have proved memory safety for the following x86_64 routines: `add_mod_256`, `mul_by_3_mod_256`, `lshift_mod_256`, `rshift_mod_256`, `cneg_mod_256`, `sub_mod_256`, `add_mod_384`, `add_mod_384x`, `lshift_mod_384`, `mul_by_3_mod_384`, `mul_by_8_mod_384`, `mul_by_b_onE1`, `mul_by_3_mod_384x`, `mul_by_8_mod_384x`, `mul_by_b_onE2`, `cneg_mod_384`, `sub_mod_384`, `sub_mod_384x`, `mul_by_1_plus_i_mod_384x`, `sgn0_pty_mod_384`, `sgn0_pty_mod_384x`, `add_mod_384x384`, `sub_mod_384x384`, `mulx_mont_sparse_256`, `sqrx_mont_sparse_256`, `from_mont_256`, `redcx_mont_256`, `mulx_mont_384x`, `sqrx_mont_384x`, `mulx_382x`, `sqrx_382x`, `redcx_mont_384`, `fromx_mont_384`, `sgn0x_pty_mont_384`, `sgn0x_pty_mont_384x`, `mulx_mont_384`, `sqrx_mont_384`, `sqrx_n_mul_mont_383`, and `sqrx_mont_382x`. There are variants of some routines that do not use the ADX instruction `mulx`; these are also proven memory-safe. A few changes from newer versions of BLST are introduced as patches in order to make the proofs more tractable, notably commit `5e3d137`.

We do not prove the memory safety of `eucl_inverse_mod_384`, as it is difficult for SAW to establish termination. Instead, we prove memory safety for `ctx_inverse_mod_383` (and the non-`mulx` counterpart `ct_inverse_mod_383`). This is done against a newer version of BLST, as that routine does not exist in the older version we use otherwise.

Under these assumptions, memory safety has been shown for all the following C functions: `blst_sk_to_pk_in_g1`, `blst_sk_to_pk_in_g2`, `blst_p1_affine_in_g1`, `blst_p2_affine_in_g2`, `blst_p1_deserialize`, `blst_p2_deserialize`, `hash_to_field`, `map_to_g1`, `map_to_g2`, `blst_core_verify_pk_in_g1`, `blst_core_verify_pk_in_g1`, `blst_pairing_init`, `blst_pairing_aggregate_pk_in_g1`, `blst_pairing_aggregate_pk_in_g2`, `blst_pairing_commit`, `blst_pairing_finalverify`.
As noted below, for a few of these we have had to restrict the proof to a few specific input sizes.

## Functional correctness

Function `blst_keygen` has been shown to give a result in agreement with the Cryptol specification for `KeyGen`, with some proof limitations as noted below. In particular, this proof is not completely general, but instead has selected a variety of lengths for both `IKM` and `info` (for a total of 5 combinations).  Functions  `blst_sk_to_pk_in_g1` and  `blst_sk_to_pk_in_g2` have been shown to agree with the requirements of `SkToPk` (with one extra condition on the secret key as noted below).  Functions `blst_p1_affine_in_g1`, `blst_p2_affine_in_g2`, `blst_p1_uncompress`, and `blst_p2_uncompress` have been shown to agree with the Cryptol specification of `KeyValidate`, except that there are some additional checks in the C implementation that are believed to be a good idea and will likely be added to the IETF specifications.  These checks are not yet in the Cryptol formalization.

# Proof limitations

* The verified code base is a little behind the current blst development.  Some proofs will need to be modified to suit the changes to the code when we bring in a more recent version.  The extra condition needed in the proof of the `blst_sk_to_pk` routines is an artifact of this; recent code changes make it unnecessary.

* Some of the blst functions have parameters of arbitrary length, for example `blst_keygen` and the signing functions that take an arbitrary-length message.  SAW cannot prove these functions in full generality; it can only prove them for fixed input sizes.  In these cases, the proofs here pick some reasonable set of fixed sizes to be proved.

* The proof of scalar multiplication takes time that increases rapidly with the number of bits in the exponent.  We have a generic proof that has been run of a variety of sizes, up to 22 bits.  So the 255-bit call used in `blst_sk_to_pk_in_g1` and  `blst_sk_to_pk_in_g2` has not been mechanically checked, but is deemed to hold by extrapolation from the proofs that have been run.

* There is an ambiguity in the IETF about the representation of field values in extension fields.  The Cryptol specification and C implementation initially differed on this point.  They are now in agreement and we hope that the specification authors will clarify this point.

* Many algebraic properties of field operations, such as the associative and unit laws, have been assumed rather than proved.  Similarly, some algebraic properties relating to elliptic curves are assumed.

* For now, the assembly language subroutines have their functional correctness assumed.

* We make an additional assumption about the stack pointer when verifying `ctx_inverse_mod_383` and `ct_inverse_mod_383` - see the comment in `proof/x86/ctx_inverse_mod_384.saw`

* We have assumed the memory-safety and functional correctness of the implementation of SHA-256.
