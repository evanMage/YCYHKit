//
//  SYEllipticCurveCrypto.h
//  SYEmbeddedSDK
//
//  Created by evan on 2023/1/30.
//

#import <Foundation/Foundation.h>

typedef enum SYEllipticCurve {
    SYEllipticCurveNone      = 0,
    SYEllipticCurveSecp128r1 = 128,
    SYEllipticCurveSecp192r1 = 192,
    SYEllipticCurveSecp256r1 = 256,
    SYEllipticCurveSecp384r1 = 384,
} SYEllipticCurve;

NS_ASSUME_NONNULL_BEGIN

/// 椭圆曲线
@interface SYEllipticCurveCrypto : NSObject
/**
 *  Create a new instance with new public key and private key pair.
 */
+ (SYEllipticCurveCrypto *)generateKeyPairForCurve: (SYEllipticCurve)curve;

- (NSData *)getPublicKeyWithX:(NSData *)x y:(NSData *)y;

/**
 *  Given a private key or public key, determine which is the appropriate curve
 */
+ (SYEllipticCurve)curveForKey: (NSData*)privateOrPublicKey;
+ (SYEllipticCurve)curveForKeyBase64: (NSString*)privateOrPublicKey;


/**
 *  Given a private key or public key, create an instance with the appropriate curve and key
 */
+ (SYEllipticCurveCrypto *)cryptoForKey: (NSData*)privateOrPublicKey;
+ (SYEllipticCurveCrypto *)cryptoForKeyBase64: (NSString*)privateOrPublicKey;


+ (id)cryptoForCurve: (SYEllipticCurve)curve;
- (id)initWithCurve: (SYEllipticCurve)curve;

/**
 *  The length of the curve in bits.
 */
@property (nonatomic, readonly) int bits;

/**
 *  The common name given to the curve (e.g. secp192r1).
 */
@property (nonatomic, readonly) NSString *name;

/**
 *  Determines whether the public key will be compressed or uncompressed.
 *
 *  It is updated when a public key is assigned and can be changed anytime
 *  to select what the publicKey property emits.
 *
 *  A compressed point stores only the x co-ordinate of the point as well as
 *  a leading byte to indicate the parity of the y co-ordinate, which can then
 *  be computed from x.
 *
 *  By default, keys are compressed.
 */
@property (nonatomic, assign) BOOL compressedPublicKey;

/**
 *  The public key for an elliptic curve.
 *
 *  A compressed public key's length is ((curve_bits / 8) + 1) bytes.
 *  An uncompressed public key's length is (2 * (curve_bits / 8) + 1) bytes.
 */
@property (nonatomic, strong) NSData *publicKey;

/**
 *  The public key encoded in base64
 */
@property (nonatomic, strong) NSString *publicKeyBase64;


/**
 *  The public key x coordinate encoded in base64
 */
@property (nonatomic, strong) NSString *publicKeyXBase64;
@property (nonatomic, strong) NSData *publicKeyX;

/**
 *  The public key y coordinate encoded in base64
 */
@property (nonatomic, strong) NSString *publicKeyYBase64;
@property (nonatomic, strong) NSData *publicKeyY;

/**
 *  The private key for an elliptic curve.
 *
 *  This is also sometimes referred to as the secret exponent.
 *
 *  A private key's length is (crypto_bits / 8) bytes.
 */
@property (nonatomic, strong) NSData *privateKey;

/**
 *  The private key encoded in base64
 */
@property (nonatomic, strong) NSString *privateKeyBase64;

/// 压缩Key
- (NSData*)compressPublicKey: (NSData*)publicKey;
/// 解压key
- (NSData*)decompressPublicKey: (NSData*)publicKey;

@property (nonatomic, readonly) int sharedSecretLength;
- (NSData*)sharedSecretForPublicKey: (NSData*)otherPublicKey;

- (NSData*)sharedSecretForPublicKeyBase64: (NSString*)otherPublicKeyBase64;

@property (nonatomic, readonly) int hashLength;
- (NSData*)signatureForHash: (NSData*)hash;

@property (nonatomic, readonly) int signatureLength;
- (BOOL)verifySignature: (NSData*)signature forHash: (NSData*)hash;

@end

NS_ASSUME_NONNULL_END
