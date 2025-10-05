//
//  TweetNaclWrapper.h
//  TweetNaclSwift
//
//  Objective-C wrapper for TweetNaCl C functions
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface TweetNaclWrapper : NSObject

// Hash functions
+ (int)crypto_hash_sha512_tweet:(unsigned char *)out
                              in:(const unsigned char *)m
                          length:(unsigned long long)n;

// Verify functions
+ (int)crypto_verify_32_tweet:(const unsigned char *)x
                            y:(const unsigned char *)y;

// Scalar multiplication
+ (int)crypto_scalarmult_curve25519_tweet_base:(unsigned char *)q
                                             n:(const unsigned char *)n;

+ (int)crypto_scalarmult_curve25519_tweet:(unsigned char *)q
                                        n:(const unsigned char *)n
                                        p:(const unsigned char *)p;

// Box functions
+ (int)crypto_box_curve25519xsalsa20poly1305_tweet_beforenm:(unsigned char *)k
                                                         pk:(const unsigned char *)pk
                                                         sk:(const unsigned char *)sk;

// Secretbox functions
+ (int)crypto_secretbox_xsalsa20poly1305_tweet:(unsigned char *)c
                                             m:(const unsigned char *)m
                                             d:(unsigned long long)d
                                         nonce:(const unsigned char *)n
                                           key:(const unsigned char *)k;

+ (int)crypto_secretbox_xsalsa20poly1305_tweet_open:(unsigned char *)m
                                                  c:(const unsigned char *)c
                                                  d:(unsigned long long)d
                                              nonce:(const unsigned char *)n
                                                key:(const unsigned char *)k;

// Sign functions
+ (int)crypto_sign_ed25519_tweet_keypair:(unsigned char *)pk
                                      sk:(unsigned char *)sk;

+ (int)crypto_sign_ed25519_tweet:(unsigned char *)sm
                            smlen:(unsigned long long *)smlen_p
                                m:(const unsigned char *)m
                                n:(unsigned long long)n
                               sk:(const unsigned char *)sk;

+ (int)crypto_sign_ed25519_tweet_open:(unsigned char *)m
                                 mlen:(unsigned long long *)mlen_p
                                   sm:(const unsigned char *)sm
                                    n:(unsigned long long)n
                                   pk:(const unsigned char *)pk;

@end

NS_ASSUME_NONNULL_END