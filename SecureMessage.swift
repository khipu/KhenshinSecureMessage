//
//  SecureMessage.swift
//  KhenshinSecureMessage
//
//  Created by Emilio Davis on 23-10-23.
//

import Foundation
import Sodium


public class SecureMessage {
    
    var symmetricKeys = [String: Key]()
    
    struct Key {
        let raw: String
        let enc: String
    }
    
    
    let sodium: Sodium
    
    public let publicKeyBase64: String
    public let privateKeyBase64: String
    
    private func newNonceS() -> Bytes {
        return sodium.randomBytes.buf(length: sodium.secretBox.NonceBytes)!
    }
    
    private func newNonceA() -> Bytes {
        return sodium.randomBytes.buf(length: sodium.box.NonceBytes)!
    }
    
    
    public init(publicKeyBase64: String?, privateKeyBase64: String?) {
        sodium = Sodium()
        if (publicKeyBase64 != nil && privateKeyBase64 != nil) {
            self.publicKeyBase64 = publicKeyBase64!
            self.privateKeyBase64 = privateKeyBase64!
        } else {
            let keyPar = sodium.box.keyPair()!
            self.publicKeyBase64 = SecureMessage.bin2base64(bin: keyPar.publicKey)
            self.privateKeyBase64 = SecureMessage.bin2base64(bin: keyPar.secretKey)
        }
    }
    
    
    private func getShared(publicKeyBase64: String) -> String? {
        guard let publicKey = SecureMessage.base642bin(base64Encoded: publicKeyBase64) else {return nil}
        guard let privateKey = SecureMessage.base642bin(base64Encoded: self.privateKeyBase64) else {return nil}
        guard let encripted = sodium.box.beforenm(recipientPublicKey: publicKey, senderSecretKey: privateKey) else {return nil}
        return SecureMessage.bin2base64(bin: encripted)
    }
    
    private func encryptSymmetricKey(publicKeyBase64: String) -> Key? {
        let symmetricKey = SecureMessage.bin2base64(bin: sodium.randomBytes.buf(length: 32)!)
        let nonce: Bytes = newNonceA()
        guard let finalKey = getShared(publicKeyBase64: publicKeyBase64) else {return nil}
        guard let publicKey = SecureMessage.base642bin(base64Encoded: finalKey) else {return nil}
        
        
        let m = ["key": symmetricKey]
        let encoder = JSONEncoder()
        let message = String(data: try! encoder.encode(m), encoding: .utf8)!
        
        guard let encrypted = sodium.secretBox.seal(message: message.bytes, secretKey: publicKey, nonce: nonce) else {return nil}

        let finalMessage = nonce + encrypted
        return Key(raw: symmetricKey, enc: SecureMessage.bin2base64(bin: finalMessage))
    }
    
    
    public func symmetricEncrypt(plainText: String, symmetricKey: String) -> String? {
        let nonce = newNonceS()
        guard let key = SecureMessage.base642bin(base64Encoded: symmetricKey) else {return nil}
        let message = plainText.bytes
        guard let newBox = sodium.secretBox.seal(message: message, secretKey: key, nonce: nonce) else {return nil}
        let finalMessage = nonce + newBox
        return SecureMessage.bin2base64(bin: finalMessage)
    }
    
    public func encrypt(plainText: String, receiverPublicKeyBase64: String) -> String? {
        var symmetricKey: Key?
        if (!self.symmetricKeys.keys.contains(receiverPublicKeyBase64)) {
            symmetricKey = encryptSymmetricKey(publicKeyBase64: receiverPublicKeyBase64)
            self.symmetricKeys[receiverPublicKeyBase64] = symmetricKey
        } else {
            symmetricKey = self.symmetricKeys[receiverPublicKeyBase64]!
        }
        guard symmetricKey != nil else {return nil}
        guard let encrypted = symmetricEncrypt(plainText: plainText, symmetricKey: symmetricKey!.raw) else {return nil}
        return encrypted + "." + symmetricKey!.enc
    }
    
    public func decryptSymmetricKey(messageWithNonceBase64: String, publicKeyBase64: String) -> String? {
        guard let finalKey = getShared(publicKeyBase64: publicKeyBase64) else {return nil}
        guard let privateKey = SecureMessage.base642bin(base64Encoded: finalKey) else {return nil}
        guard let messageWithNonce = SecureMessage.base642bin(base64Encoded: messageWithNonceBase64) else {return nil}
        let nonce = messageWithNonce.prefix(sodium.secretBox.NonceBytes)
        let message = messageWithNonce.suffix(messageWithNonce.count - sodium.secretBox.NonceBytes)
        guard let decrypted = sodium.secretBox.open(authenticatedCipherText: Array(message), secretKey: privateKey, nonce: Array(nonce)) else {return nil}
        guard let dict = SecureMessage.convertStringToDictionary(text: String(decoding: decrypted, as: UTF8.self)) else {return nil}
        return dict["key"]!
        
    }

    
    private func _decrypt(cipherText: String, senderPublicKey: String) -> String? {
        let dataParts = cipherText.split(separator: ".")
        
        var symmetricKey: Key
        if (!self.symmetricKeys.keys.contains(senderPublicKey)) {
            guard let decryptedSymmetricKey = decryptSymmetricKey(messageWithNonceBase64: String(dataParts[1]), publicKeyBase64: senderPublicKey) else {return nil}
            symmetricKey = Key(raw: decryptedSymmetricKey, enc: String(dataParts[1]))
            self.symmetricKeys[senderPublicKey] = symmetricKey
        } else {
            symmetricKey = self.symmetricKeys[senderPublicKey]!
        }
        
        return symmetricDecrypt(cipherText: String(dataParts[0]), symmetricKey: symmetricKey.raw)
    }
    
    public func symmetricDecrypt(cipherText: String, symmetricKey: String) -> String? {
        guard let key = SecureMessage.base642bin(base64Encoded: symmetricKey) else {return nil}
        guard let messageWithNonce = SecureMessage.base642bin(base64Encoded: cipherText) else {return nil}
        
        let nonce = Array(messageWithNonce.prefix(sodium.secretBox.NonceBytes))
        let message = Array(messageWithNonce.suffix(messageWithNonce.count - sodium.secretBox.NonceBytes))
        
        guard let decrypted = sodium.secretBox.open(authenticatedCipherText: message, secretKey: key, nonce: nonce) else {return nil}
        
        return String(decoding: decrypted, as: UTF8.self)
    }
    
    
    public func decrypt(cipherText: String, senderPublicKey: String) -> String? {
        let result = _decrypt(cipherText: cipherText, senderPublicKey: senderPublicKey)
        if (result != nil) {
            return result
        }
        self.symmetricKeys.removeValue(forKey: senderPublicKey)
        return _decrypt(cipherText: cipherText, senderPublicKey: senderPublicKey)
    }
    
    public static func bin2base64(bin: Array<UInt8>) -> String {
        return Data(bin).base64EncodedString()
    }
    
    public static func base642bin(base64Encoded: String) -> Array<UInt8>? {
        let data = Data(base64Encoded: base64Encoded)
        if (data == nil) {
            return nil
        }
        return [UInt8](data!)
    }
    
    private static func convertStringToDictionary(text: String) -> [String:String]? {
       if let data = text.data(using: .utf8) {
           do {
               let json = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [String:String]
               return json
           } catch {
               
           }
       }
       return nil
    }
    
}
