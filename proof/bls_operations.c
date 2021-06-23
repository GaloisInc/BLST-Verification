#include "blst.h"
#include <stdio.h> // for NULL 

// TODO: Move

// Two variants:
// _A: min signature size
// _B: min pk size

// Explicitly note that demo_DST_A is 43 bytes to avoid the null terminator
// (needed for SAW to treat the allocation as 32 bytes)
byte demo_DST_A[43] = "BLS_SIG_BLS12381G1_XMD:SHA-256_SSWU_RO_NUL_";
// TODO: demo_DST_B

// KeyGen maps directly to blst_keygen

// SkToPk
void demo_SkToPk_A(unsigned char out[96], const blst_scalar *SK) {
  blst_p2 pk;
  blst_sk_to_pk_in_g2(&pk, SK);
  blst_p2_compress(out, &pk);
  }

void demo_SkToPk_B(unsigned char out[48], const blst_scalar *SK) {
  blst_p1 pk;
  blst_sk_to_pk_in_g1(&pk, SK);
  blst_p1_compress(out, &pk);
};

// KeyValidate

limb_t demo_KeyValidate_A(const unsigned char in[96]) {
  blst_p2_affine pk;
  BLST_ERROR r;
  r = blst_p2_uncompress(&pk, in);
  /*
  return r == BLST_SUCCESS &&
         blst_p2_affine_on_curve(&pk) &&
         !blst_p2_affine_is_inf(&pk) &&
         blst_p2_affine_in_g2(&pk);
         */
  if (r != BLST_SUCCESS) return 0;
  if (! blst_p2_affine_on_curve(&pk)) return 0;
  if (blst_p2_affine_is_inf(&pk)) return 0;
  if (! blst_p2_affine_in_g2(&pk)) return 0;
  return 1;
};

BLST_ERROR demo_KeyValidate_B(const unsigned char in[48]) {
  blst_p1_affine pk;
  BLST_ERROR r;
  r = blst_p1_uncompress(&pk, in);
  if (r != BLST_SUCCESS) return r;
  if (! blst_p1_affine_on_curve(&pk)) return BLST_POINT_NOT_ON_CURVE;
  if (blst_p1_affine_is_inf(&pk)) return BLST_PK_IS_INFINITY;
  if (! blst_p1_affine_in_g1(&pk)) return BLST_POINT_NOT_IN_GROUP;
  return BLST_SUCCESS;
};


// BasicSign

void demo_BasicSign_A(byte out[48], const blst_scalar *SK,
                     const byte *message, size_t message_len) {
  // TODO: Figure out how to use globals in SAW?
  //const byte local_DST_A[] = "BLS_SIG_BLS12381G1_XMD:SHA-256_SSWU_RO_AUG_";
  blst_p1 Q1, Q2;
  // TODO: Double check, but I think aug is supposed to be a public key?  That
  // will determine the size it should be.
  // TODO: Is DST_len supposted to include the null terminator?  It's 44 with
  // the null terminator, and 43 without.
  blst_hash_to_g1(&Q1, message, message_len, demo_DST_A, 43, NULL, 0); // no "aug" string
  // blst_p1_mult(&Q, &Q, SK, 256); // or 255?
  blst_sign_pk_in_g2(&Q2, &Q1, SK);
  blst_p1_compress(out, &Q2);
};

void demo_BasicSign_B(byte out[96], const blst_scalar *SK,
                     const byte *message, size_t message_len) {
  blst_p2 Q;
  blst_hash_to_g2(&Q, message, message_len, demo_DST_A, 43, NULL, 0); // no "aug" string
  // TODO: fix DST string above
  blst_sign_pk_in_g1(&Q, &Q, SK);
  blst_p2_compress(out, &Q);
};

// BasicVerify

limb_t demo_BasicVerify_A(const byte sig[48], const byte pk[96], const byte *message, size_t message_len) {
  blst_p1_affine R;
  blst_p1 Q;
  blst_p2_affine PK;
  // uncompress and check the sig
  if (blst_p1_uncompress(&R, sig) != BLST_SUCCESS) return 0;
  if (! blst_p1_affine_on_curve(&R)) return 0;
  if (blst_p1_affine_is_inf(&R)) return 0;
  if (! blst_p1_affine_in_g1(&R)) return 0;

  // TODO: Use KeyValidate below instead to better match the spec?
  // uncompress and check the pub key
  if (blst_p2_uncompress(&PK, pk) != BLST_SUCCESS) return 0;
  if (! blst_p2_affine_on_curve(&PK)) return 0;
  if (blst_p2_affine_is_inf(&PK)) return 0;
  if (! blst_p2_affine_in_g2(&PK)) return 0;

  if (blst_core_verify_pk_in_g2(&PK, &R, 1, message, message_len, demo_DST_A, 43, NULL, 0) != BLST_SUCCESS)
    return 0;
  return 1;
};

bool demo_BasicVerify_B(const byte sig[96], const byte pk[48], const byte *message, size_t message_len) {
  blst_p2_affine R;
  blst_p2 Q;
  blst_p1_affine PK;
  // uncompress and check the sig
  if (blst_p2_uncompress(&R, sig) != BLST_SUCCESS) return 0;
  if (! blst_p2_affine_on_curve(&R)) return 0;
  if (blst_p2_affine_is_inf(&R)) return 0;
  if (! blst_p2_affine_in_g2(&R)) return 0;

  // TODO: Maybe remove the above checks if the override handles error cases.
  // Can't remove pubkey checks?  (Same goes for A variant)

  // uncompress and check the pub key
  if (blst_p1_uncompress(&PK, pk) != BLST_SUCCESS) return 0;
  if (! blst_p1_affine_on_curve(&PK)) return 0;
  if (blst_p1_affine_is_inf(&PK)) return 0;
  if (! blst_p1_affine_in_g1(&PK)) return 0;


  // TODO: fix DST string
  if (blst_core_verify_pk_in_g1(&PK, &R, 1, message, message_len, demo_DST_A, 43, NULL, 0) != BLST_SUCCESS)
    return 0;
  return 1;
};
