//
//  SecureMessage.swift
//  KhenshinSecureMessage
//
//  Created by Emilio Davis on 23-10-23.
//

import Foundation
import KHTweetNacl

import Foundation


public class SecureMessageError : Error
{
    public var  source: String = "SecureMessage"
    public var  code: String = ""
    public var  message: String = ""
    
    public init (_ codeext: String = "",  _ message:String = "") {
        self.code = codeext
        self.message = message
    }
    
}


public class SecureMessage {
    
    var symmetricKeys = [String: Key]()
    
    struct Key {
        let raw: String
        let enc: String
    }
    
    func secureRandomBytes(count: Int) -> Data? {
        var bytes = [UInt8](repeating: 0, count: count)

        let status = SecRandomCopyBytes(
            kSecRandomDefault,
            count,
            &bytes
        )

        if status == errSecSuccess {
            return  Data(bytes)
        }else{
            return nil
        }
    }
    

    public let publicKeyBase64: String
    public let privateKeyBase64: String
    
    private func newNonceS() -> Data {
        return secureRandomBytes(count: 24)!
    }
    
    private func newNonceA() -> Data {
        return secureRandomBytes(count: 24)!
    }
    
    
    public init(publicKeyBase64: String?, privateKeyBase64: String?) {
        if (publicKeyBase64 != nil && privateKeyBase64 != nil) {
            self.publicKeyBase64 = publicKeyBase64!
            self.privateKeyBase64 = privateKeyBase64!
        } else {
            let keyPar = try! NaclBox.keyPair()
            self.publicKeyBase64 = SecureMessage.bin2base64(bin: keyPar.publicKey)
            self.privateKeyBase64 = SecureMessage.bin2base64(bin: keyPar.secretKey)
        }
    }
    
    
    private func getShared(publicKeyBase64: String) -> String? {
        guard let publicKey = SecureMessage.base642bin(base64Encoded: publicKeyBase64) else {return nil}
        guard let privateKey = SecureMessage.base642bin(base64Encoded: self.privateKeyBase64) else {return nil}
        guard let encripted = try? NaclBox.before(publicKey: publicKey, secretKey: privateKey) else {return nil}
        return SecureMessage.bin2base64(bin: encripted)
    }
    
    private func encryptSymmetricKey(publicKeyBase64: String) -> Key? {
        let symmetricKey = SecureMessage.bin2base64(bin: secureRandomBytes(count: 32)!)
        let nonce: Data = newNonceA()
        guard let finalKey = getShared(publicKeyBase64: publicKeyBase64) else {return nil}
        guard let publicKey = SecureMessage.base642bin(base64Encoded: finalKey) else {return nil}
        
        
        let message = ["key": symmetricKey]
        let encoder = JSONEncoder()
        
        guard let encrypted = try? NaclSecretBox.secretBox(message: encoder.encode(message), nonce: nonce, key: publicKey) else {return nil}

        var finalMessage = nonce
        finalMessage.append(encrypted)
        return Key(raw: symmetricKey, enc: SecureMessage.bin2base64(bin: finalMessage))
    }
    
    
    public func symmetricEncrypt(plainText: String, symmetricKey: String) -> String? {
        let nonce = newNonceS()
        guard let key = SecureMessage.base642bin(base64Encoded: symmetricKey) else {return nil}
        
        guard let newBox = try? NaclSecretBox.secretBox(message: plainText.data(using: .utf8)!, nonce: nonce, key: key) else {return nil}

        var finalMessage = nonce
        finalMessage.append(newBox)
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
        let finalKey = getShared(publicKeyBase64: publicKeyBase64)
        let privateKey = SecureMessage.base642bin(base64Encoded: finalKey!)
        let messageWithNonce = SecureMessage.base642bin(base64Encoded: messageWithNonceBase64)
        let nonce = messageWithNonce!.prefix(24)
        let message = messageWithNonce!.suffix(messageWithNonce!.count - 24)
        guard let decrypted = try? NaclSecretBox.open(box: message, nonce: nonce, key: privateKey!) else {return nil}
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
        
        let nonce = messageWithNonce.prefix(24)
        let message = messageWithNonce.suffix(messageWithNonce.count - 24)
        
        guard let decrypted = try? NaclSecretBox.open(box: message, nonce: nonce, key: key) else {
            return nil
        }
        
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
    
    public static func bin2base64(bin: Data) -> String {
        return bin.base64EncodedString()
    }
    
    public static func base642bin(base64Encoded: String) -> Data? {
        let data = Data(base64Encoded: base64Encoded)
        if (data == nil) {
            return nil
        }
        return data
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
