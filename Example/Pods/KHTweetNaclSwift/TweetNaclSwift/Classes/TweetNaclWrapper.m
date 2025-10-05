//
//  TweetNaclWrapper.m
//  TweetNaclSwift
//
//  Objective-C wrapper for TweetNaCl C functions
//

#import "TweetNaclWrapper.h"
#import "C/ctweetnacl.h"

@implementation TweetNaclWrapper

+ (int)crypto_hash_sha512_tweet:(unsigned char *)out
                              in:(const unsigned char *)m
                          length:(unsigned long long)n {
    return crypto_hash_sha512_tweet(out, m, n);
}

+ (int)crypto_verify_32_tweet:(const unsigned char *)x
                            y:(const unsigned char *)y {
    return crypto_verify_32_tweet(x, y);
}

+ (int)crypto_scalarmult_curve25519_tweet_base:(unsigned char *)q
                                             n:(const unsigned char *)n {
    return crypto_scalarmult_curve25519_tweet_base(q, n);
}

+ (int)crypto_scalarmult_curve25519_tweet:(unsigned char *)q
                                        n:(const unsigned char *)n
                                        p:(const unsigned char *)p {
    return crypto_scalarmult_curve25519_tweet(q, n, p);
}

+ (int)crypto_box_curve25519xsalsa20poly1305_tweet_beforenm:(unsigned char *)k
                                                         pk:(const unsigned char *)pk
                                                         sk:(const unsigned char *)sk {
    return crypto_box_curve25519xsalsa20poly1305_tweet_beforenm(k, pk, sk);
}

+ (int)crypto_secretbox_xsalsa20poly1305_tweet:(unsigned char *)c
                                             m:(const unsigned char *)m
                                             d:(unsigned long long)d
                                         nonce:(const unsigned char *)n
                                           key:(const unsigned char *)k {
    return crypto_secretbox_xsalsa20poly1305_tweet(c, m, d, n, k);
}

+ (int)crypto_secretbox_xsalsa20poly1305_tweet_open:(unsigned char *)m
                                                  c:(const unsigned char *)c
                                                  d:(unsigned long long)d
                                              nonce:(const unsigned char *)n
                                                key:(const unsigned char *)k {
    return crypto_secretbox_xsalsa20poly1305_tweet_open(m, c, d, n, k);
}

+ (int)crypto_sign_ed25519_tweet_keypair:(unsigned char *)pk
                                      sk:(unsigned char *)sk {
    return crypto_sign_ed25519_tweet_keypair(pk, sk);
}

+ (int)crypto_sign_ed25519_tweet:(unsigned char *)sm
                            smlen:(unsigned long long *)smlen_p
                                m:(const unsigned char *)m
                                n:(unsigned long long)n
                               sk:(const unsigned char *)sk {
    return crypto_sign_ed25519_tweet(sm, smlen_p, m, n, sk);
}

+ (int)crypto_sign_ed25519_tweet_open:(unsigned char *)m
                                 mlen:(unsigned long long *)mlen_p
                                   sm:(const unsigned char *)sm
                                    n:(unsigned long long)n
                                   pk:(const unsigned char *)pk {
    return crypto_sign_ed25519_tweet_open(m, mlen_p, sm, n, pk);
}

@end