#include "blst.h"
#include <stdio.h> // for NULL 
#include <string.h> // for memcmp

// Two variants:
// _A: min signature size
// _B: min pk size

// demo_DST_A and demo_DST_B are 43 bytes to avoid the null terminator.  This
// is needed for SAW to treat the allocations as 43 bytes.
byte demo_DST_A[43] = "BLS_SIG_BLS12381G1_XMD:SHA-256_SSWU_RO_NUL_";
byte demo_DST_B[43] = "BLS_SIG_BLS12381G2_XMD:SHA-256_SSWU_RO_NUL_";

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
  if (r != BLST_SUCCESS) return 0;
  if (! blst_p2_affine_on_curve(&pk)) return 0;
  if (blst_p2_affine_is_inf(&pk)) return 0;
  if (! blst_p2_affine_in_g2(&pk)) return 0;
  return 1;
};

limb_t demo_KeyValidate_B(const unsigned char in[48]) {
  blst_p1_affine pk;
  BLST_ERROR r;
  r = blst_p1_uncompress(&pk, in);
  if (r != BLST_SUCCESS) return 0;
  if (! blst_p1_affine_on_curve(&pk)) return 0;
  if (blst_p1_affine_is_inf(&pk)) return 0;
  if (! blst_p1_affine_in_g1(&pk)) return 0;
  return 1;
};


// BasicSign

void demo_BasicSign_A(byte out[48], const blst_scalar *SK,
                     const byte *message, size_t message_len) {
  blst_p1 Q1, Q2;
  blst_hash_to_g1(&Q1, message, message_len, demo_DST_A, 43, NULL, 0); // no "aug" string
  blst_sign_pk_in_g2(&Q2, &Q1, SK);
  blst_p1_compress(out, &Q2);
};

void demo_BasicSign_B(byte out[96], const blst_scalar *SK,
                     const byte *message, size_t message_len) {
  blst_p2 Q1, Q2;
  blst_hash_to_g2(&Q1, message, message_len, demo_DST_B, 43, NULL, 0); // no "aug" string
  blst_sign_pk_in_g1(&Q2, &Q1, SK);
  blst_p2_compress(out, &Q2);
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

  if (!demo_KeyValidate_A(pk)) return 0;

  // uncompress and check the pub key
  if (blst_p2_uncompress(&PK, pk) != BLST_SUCCESS) return 0;

  if (blst_core_verify_pk_in_g2(&PK, &R, 1, message, message_len, demo_DST_A, 43, NULL, 0) != BLST_SUCCESS)
    return 0;
  return 1;
};

limb_t demo_BasicVerify_B(const byte sig[96], const byte pk[48], const byte *message, size_t message_len) {
  blst_p2_affine R;
  blst_p2 Q;
  blst_p1_affine PK;
  // uncompress and check the sig
  if (blst_p2_uncompress(&R, sig) != BLST_SUCCESS) return 0;
  if (! blst_p2_affine_on_curve(&R)) return 0;
  if (blst_p2_affine_is_inf(&R)) return 0;
  if (! blst_p2_affine_in_g2(&R)) return 0;

  if (!demo_KeyValidate_B(pk)) return 0;

  // uncompress and check the pub key
  if (blst_p1_uncompress(&PK, pk) != BLST_SUCCESS) return 0;

  if (blst_core_verify_pk_in_g1(&PK, &R, 1, message, message_len, demo_DST_B, 43, NULL, 0) != BLST_SUCCESS)
    return 0;
  return 1;
};

// Assert no two messages are equal
limb_t all_distinct(size_t n, size_t message_len, const byte messages[n][message_len]) {
  for (size_t i; i < n; ++i) {
    for (size_t j = i+1; j < n; ++j) {
      if (memcmp(messages[i], messages[j], message_len)) return 0;
    }
  }
  return 1;
}

limb_t demo_BasicAggregateVerify_A(size_t n,
                                   size_t message_len,
                                   const byte pks[n][96],
                                   const byte messages[n][message_len],
                                   const byte sig[48]) {
  if (!all_distinct(n, message_len, messages)) return 0;

  // uncompress and check the sig
  blst_p1_affine R;
  if (blst_p1_uncompress(&R, sig) != BLST_SUCCESS) return 0;
  if (! blst_p1_affine_on_curve(&R)) return 0;
  if (blst_p1_affine_is_inf(&R)) return 0;
  if (! blst_p1_affine_in_g1(&R)) return 0;

  // Create aggregate verify context
  blst_pairing ctx;
  blst_pairing_init(&ctx, 1, demo_DST_A, 43);

  for (size_t i = 0; i < n; ++i) {
    const byte* pk = pks[i];
    // Check and Uncompress PK
    if (!demo_KeyValidate_A(pk)) return 0;

    blst_p2_affine PK;
    if (blst_p2_uncompress(&PK, pk) != BLST_SUCCESS) return 0;

    // Aggregate
    if (blst_pairing_aggregate_pk_in_g2(&ctx,
                                        &PK,
                                        i ? NULL : &R,
                                        messages[i],
                                        message_len,
                                        NULL,
                                        0) != BLST_SUCCESS) return 0;
  }
  blst_pairing_commit(&ctx);
  if (!blst_pairing_finalverify(&ctx, NULL)) return 0;
  return 1;
}

limb_t demo_BasicAggregateVerify_B(size_t n,
                                   size_t message_len,
                                   const byte pks[n][48],
                                   const byte messages[n][message_len],
                                   const byte sig[96]) {
  if (!all_distinct(n, message_len, messages)) return 0;

  // uncompress and check the sig
  blst_p2_affine R;
  if (blst_p2_uncompress(&R, sig) != BLST_SUCCESS) return 0;
  if (! blst_p2_affine_on_curve(&R)) return 0;
  if (blst_p2_affine_is_inf(&R)) return 0;
  if (! blst_p2_affine_in_g2(&R)) return 0;

  // Create aggregate verify context
  blst_pairing ctx;
  blst_pairing_init(&ctx, 1, demo_DST_B, 43);

  for (size_t i = 0; i < n; ++i) {
    const byte* pk = pks[i];
    // Check and Uncompress PK
    if (!demo_KeyValidate_B(pk)) return 0;
    blst_p1_affine PK;
    if (blst_p1_uncompress(&PK, pk) != BLST_SUCCESS) return 0;

    // Aggregate
    if (blst_pairing_aggregate_pk_in_g1(&ctx,
                                        &PK,
                                        i ? NULL : &R,
                                        messages[i],
                                        message_len,
                                        NULL,
                                        0) != BLST_SUCCESS) return 0;
  }
  blst_pairing_commit(&ctx);
  if (!blst_pairing_finalverify(&ctx, NULL)) return 0;
  return 1;
}
