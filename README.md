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

Cryptol definitions exist for the BLS12-381 parameters, for the `hash_to_curve` functions for bls from draft-irtf-cfrg-hash-to-curve-09, and for the pairing function from draft-irtf-cfrg-pairing-friendly-curves-07.  Definitions for the API functions from draft-irtf-cfrg-bls-signature-04 are in progress, with the definition of `KeyGen` complete.

## Memory Safety proofs

Under the assumption that the assembler routines are memory-safe when called correctly, memory safety has been shown for `blst_keygen`, `hash_to_field`, `blst_sk_to_pk_in_g1`, `blst_sk_to_pk_in_g2`, `blst_p1_affine_in_g1`, `blst_p2_affine_in_g2`, `blst_p1_deserialize`, `blst_p2_deserialize`, `expand_message_xmd`, `POINTonE1_dadd`, `POINTonE2_dadd`, `POINTonE1_dadd_affine`, `POINTonE2_dadd_affine`, `POINTonE1_add`, `POINTonE1_add`, `POINTonE1_add`, `POINTonE2_add`, `POINTonE2_add`, `POINTonE1_add_affine`, `POINTonE1_add_affine`, `POINTonE2_add_affine`, `POINTonE2_add_affine`, `POINTonE1_double`, `POINTonE1_double`, `POINTonE2_double`, `POINTonE2_double`, `POINTonE1_is_equal`, and `POINTonE2_is_equal`.  As noted below, for a few of these we have had to restrict the proof to a few specific input sizes.

## Functional correctness

Function `blst_keygen` has been shown to give a result in agreement with the Cryptol specification, with some proof limitations as noted below. In particular, this proof is not completely general, but instead has selected a variety of lengths for both `IKM` and `info` (for a total of 5 combinations).

# Proof limitations

* Some of the blst functions have parameters of arbitrary length, for example `blst_keygen` and the signing functions that take an arbitrary-length message.  SAW cannot prove these functions in full generality; it can only prove them for fixed input sizes.  In these cases, the proofs here pick some reasonable set of fixed sizes to be proved.

* For now, the assembly language subroutines have their memory safety and functional correctness assumed.

* We have assumed the memory-safety and functional correctness of the implementation of SHA-256.
