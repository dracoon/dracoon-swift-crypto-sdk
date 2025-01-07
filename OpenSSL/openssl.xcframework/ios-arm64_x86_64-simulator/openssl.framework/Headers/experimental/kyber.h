/* Copyright 2023 The BoringSSL Authors
 *
 * Permission to use, copy, modify, and/or distribute this software for any
 * purpose with or without fee is hereby granted, provided that the above
 * copyright notice and this permission notice appear in all copies.
 *
 * THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES
 * WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
 * MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY
 * SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
 * WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN ACTION
 * OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF OR IN
 * CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE. */

#ifndef OPENSSL_HEADER_KYBER_H
#define OPENSSL_HEADER_KYBER_H

#include <openssl/base.h>

#if defined(__cplusplus)
extern "C" {
#endif


#if defined(OPENSSL_UNSTABLE_EXPERIMENTAL_KYBER)
// This header implements experimental, draft versions of not-yet-standardized
// primitives. When the standard is complete, these functions will be removed
// and replaced with the final, incompatible standard version. They are
// available now for short-lived experiments, but must not be deployed anywhere
// durable, such as a long-lived key store. To use these functions define
// OPENSSL_UNSTABLE_EXPERIMENTAL_KYBER

// Kyber768.
//
// This implements the round-3 specification of Kyber, defined at
// https://pq-crystals.org/kyber/data/kyber-specification-round3-20210804.pdf


// KYBER_public_key contains a Kyber768 public key. The contents of this
// object should never leave the address space since the format is unstable.
struct KYBER_public_key {
  union {
    uint8_t bytes[512 * (3 + 9) + 32 + 32];
    uint16_t alignment;
  } opaque;
};

// KYBER_private_key contains a Kyber768 private key. The contents of this
// object should never leave the address space since the format is unstable.
struct KYBER_private_key {
  union {
    uint8_t bytes[512 * (3 + 3 + 9) + 32 + 32 + 32];
    uint16_t alignment;
  } opaque;
};

// KYBER_PUBLIC_KEY_BYTES is the number of bytes in an encoded Kyber768 public
// key.
#define KYBER_PUBLIC_KEY_BYTES 1184

// KYBER_SHARED_SECRET_BYTES is the number of bytes in the Kyber768 shared
// secret. Although the round-3 specification has a variable-length output, the
// final ML-KEM construction is expected to use a fixed 32-byte output. To
// simplify the future transition, we apply the same restriction.
#define KYBER_SHARED_SECRET_BYTES 32

// KYBER_generate_key generates a random public/private key pair, writes the
// encoded public key to |out_encoded_public_key| and sets |out_private_key| to
// the private key.
OPENSSL_EXPORT void KYBER_generate_key(
    uint8_t out_encoded_public_key[KYBER_PUBLIC_KEY_BYTES],
    struct KYBER_private_key *out_private_key);

// KYBER_public_from_private sets |*out_public_key| to the public key that
// corresponds to |private_key|. (This is faster than parsing the output of
// |KYBER_generate_key| if, for some reason, you need to encapsulate to a key
// that was just generated.)
OPENSSL_EXPORT void KYBER_public_from_private(
    struct KYBER_public_key *out_public_key,
    const struct KYBER_private_key *private_key);

// KYBER_CIPHERTEXT_BYTES is number of bytes in the Kyber768 ciphertext.
#define KYBER_CIPHERTEXT_BYTES 1088

// KYBER_encap encrypts a random shared secret for |public_key|, writes the
// ciphertext to |out_ciphertext|, and writes the random shared secret to
// |out_shared_secret|.
OPENSSL_EXPORT void KYBER_encap(
    uint8_t out_ciphertext[KYBER_CIPHERTEXT_BYTES],
    uint8_t out_shared_secret[KYBER_SHARED_SECRET_BYTES],
    const struct KYBER_public_key *public_key);

// KYBER_decap decrypts a shared secret from |ciphertext| using |private_key|
// and writes it to |out_shared_secret|. If |ciphertext| is invalid,
// |out_shared_secret| is filled with a key that will always be the same for the
// same |ciphertext| and |private_key|, but which appears to be random unless
// one has access to |private_key|. These alternatives occur in constant time.
// Any subsequent symmetric encryption using |out_shared_secret| must use an
// authenticated encryption scheme in order to discover the decapsulation
// failure.
OPENSSL_EXPORT void KYBER_decap(
    uint8_t out_shared_secret[KYBER_SHARED_SECRET_BYTES],
    const uint8_t ciphertext[KYBER_CIPHERTEXT_BYTES],
    const struct KYBER_private_key *private_key);


// Serialisation of keys.

// KYBER_marshal_public_key serializes |public_key| to |out| in the standard
// format for Kyber public keys. It returns one on success or zero on allocation
// error.
OPENSSL_EXPORT int KYBER_marshal_public_key(
    CBB *out, const struct KYBER_public_key *public_key);

// KYBER_parse_public_key parses a public key, in the format generated by
// |KYBER_marshal_public_key|, from |in| and writes the result to
// |out_public_key|. It returns one on success or zero on parse error or if
// there are trailing bytes in |in|.
OPENSSL_EXPORT int KYBER_parse_public_key(
    struct KYBER_public_key *out_public_key, CBS *in);

// KYBER_marshal_private_key serializes |private_key| to |out| in the standard
// format for Kyber private keys. It returns one on success or zero on
// allocation error.
OPENSSL_EXPORT int KYBER_marshal_private_key(
    CBB *out, const struct KYBER_private_key *private_key);

// KYBER_PRIVATE_KEY_BYTES is the length of the data produced by
// |KYBER_marshal_private_key|.
#define KYBER_PRIVATE_KEY_BYTES 2400

// KYBER_parse_private_key parses a private key, in the format generated by
// |KYBER_marshal_private_key|, from |in| and writes the result to
// |out_private_key|. It returns one on success or zero on parse error or if
// there are trailing bytes in |in|.
OPENSSL_EXPORT int KYBER_parse_private_key(
    struct KYBER_private_key *out_private_key, CBS *in);

#endif // OPENSSL_UNSTABLE_EXPERIMENTAL_KYBER


#if defined(__cplusplus)
}  // extern C
#endif

#endif  // OPENSSL_HEADER_KYBER_H
