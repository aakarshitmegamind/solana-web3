/// Imports
/// ------------------------------------------------------------------------------------------------

library nacl;

import 'package:flutter/foundation.dart';
import 'keypair.dart';
import 'package:pinenacl/tweetnacl.dart' show TweetNaCl;
import 'package:solana_common/utils/library.dart' show check;


/// NaCl
/// ------------------------------------------------------------------------------------------------

/// Public key length in bytes.
const int publicKeyLength = 32;

/// Secret key length in bytes.
const int secretKeyLength = 64;

/// Signature length in bytes.
const int signatureLength = 64;

/// The Maximum lengthin bytes of derived public key seed.
const int maxSeedLength = 32;

/// NaCl Sign singleton.
const NaClSign sign = NaClSign();


/// NaCl Sign
/// ------------------------------------------------------------------------------------------------

@protected
class NaClSign {
  const NaClSign();
  final keypair = const NaClKeypair();
  final detached = const NaClDetached();
}


/// NaCl Keypair
/// ------------------------------------------------------------------------------------------------

@protected
class NaClKeypair {

  /// NaCl `sign.keypair` methods.
  const NaClKeypair();

  /// {@macro NaClKeypair.sync}
  Future<Ed25519Keypair> call()
    => compute((_) => sync(), null);

  /// {@template NaClKeypair.sync}
  /// Generates a random keypair.
  /// 
  /// Throws an [AssertionError] if a keypair could not be generated.
  /// {@endtemplate}
  Ed25519Keypair sync() {
    return fromSeedSync(TweetNaCl.randombytes(maxSeedLength));
  }
  
  /// {@macro NaClKeypair.fromSecretKeySync}
  Future<Ed25519Keypair> fromSecretKey(final Uint8List secretKey)
    => compute(fromSecretKeySync, secretKey);

  /// {@template NaClKeypair.fromSecretKeySync}
  /// Creates a keypair from a [secretKey] byte array.
  /// 
  /// This method should only be used to recreate a keypair from a previously generated [secretKey]. 
  /// Generating keypairs from a random seed should be done using the [fromSeedSync] method.
  /// 
  /// Throws an [AssertionError] if the [secretKey] is invalid.
  /// {@endtemplate}
  Ed25519Keypair fromSecretKeySync(final Uint8List secretKey) {
    check(secretKey.length == secretKeyLength, 'Invalid secret key length ${secretKey.length}.');
    final Uint8List publicKey = secretKey.sublist(secretKey.length - publicKeyLength);
    return Ed25519Keypair(publicKey: publicKey, secretKey: secretKey);
  }

  /// {@macro NaClKeypair.fromSeedSync}
  Future<Ed25519Keypair> fromSeed(final Uint8List seed)
    => compute(fromSeedSync, seed);

  /// {@template NaClKeypair.fromSeedSync}
  /// Creates a keypair from a `32-byte` [seed].
  /// 
  /// Throws an [AssertionError] if the [seed] is invalid.
  /// {@endtemplate}
  Ed25519Keypair fromSeedSync(final Uint8List seed) {
    check(seed.length == maxSeedLength, 'Invalid seed length ${seed.length}.');
    final publicKey = Uint8List(publicKeyLength);
    final secretKey = Uint8List(secretKeyLength)..setAll(0, seed);
    final int result = TweetNaCl.crypto_sign_keypair(publicKey, secretKey, seed);
    check(result == 0, 'Failed to create keypair from seed $seed.');
    return Ed25519Keypair(publicKey: publicKey, secretKey: secretKey);
  }
}


/// NaCl Detached
/// ------------------------------------------------------------------------------------------------

@protected
class NaClDetached {

  /// NaCl `sign.detached` methods.
  const NaClDetached();

  /// {@macro NaClDetached.sync}
  Future<Uint8List> call(final Uint8List message, final Uint8List secretKey)
    => compute((_) => sync(message, secretKey), null);

  /// {@template NaClDetached.sync}
  /// Signs [message] using the [secretKey] and returns the `signature`.
  /// {@endtemplate}
  Uint8List sync(final Uint8List message, final Uint8List secretKey) {
    final Uint8List signedMessage = Uint8List(message.length + signatureLength);
    final int result = TweetNaCl.crypto_sign(
      signedMessage, -1, message, 0, message.length, secretKey,
    );
    check(result == 0, 'Failed to sign message.');
    return signedMessage.sublist(0, signatureLength);
  }

  /// {@macro NaClDetached.verifySync}
  Future<bool> verify(final Uint8List message, final Uint8List signature, final Uint8List publicKey)
    => compute((_) => verifySync(message, signature, publicKey), null);

  /// {@template NaClDetached.verifySync}
  /// Returns true if the [signature] was derived by signing the [message] using [publicKey]'s 
  /// `secret key`.
  /// {@endtemplate}
  bool verifySync(final Uint8List message, final Uint8List signature, final Uint8List publicKey) {
    check(signature.length == signatureLength, 'Invalid signature length.');
    final Uint8List signedMessage = Uint8List.fromList(signature + message);
    final Uint8List buffer = Uint8List(signedMessage.length);
    final int result = TweetNaCl.crypto_sign_open(
      buffer, -1, signedMessage, 0, signedMessage.length, publicKey,
    );
    return result == 0;
  }
}