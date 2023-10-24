//
//  KhenshinSecureMessageSpec.swift
//  KhenshinSecureMessage_Tests
//
//  Created by Emilio Davis on 24-10-23.
//  Copyright © 2023 CocoaPods. All rights reserved.
//

import Quick
import Nimble
import KhenshinSecureMessage

class KhenshinSecureMessageSpec: QuickSpec {
    override func spec() {
        describe("KhenshinSecureMessage tests") {
            it("Should create a public key") {
                let secureMessage = SecureMessage(publicKeyBase64: nil, privateKeyBase64: nil)
                expect(secureMessage.publicKeyBase64).toNot(beNil())
            }
            it("Should use a pre asigned public key") {
                let key = "1231231231231332112123132"
                let secureMessage = SecureMessage(publicKeyBase64: key, privateKeyBase64: "x")
                expect(secureMessage.publicKeyBase64).to(match(key))
            }
            it("encrypt and decrypt cycle") {
                let server = SecureMessage(publicKeyBase64: nil, privateKeyBase64: nil)
                let client = SecureMessage(publicKeyBase64: nil, privateKeyBase64: nil)
                let toEncrypt = UUID().uuidString
                let encrypted = server.encrypt(plainText: toEncrypt, receiverPublicKeyBase64: client.publicKeyBase64)
                let decrypted = client.decrypt(cipherText: encrypted!, senderPublicKey: server.publicKeyBase64)
                expect(decrypted).to(match(toEncrypt))

                let toEncrypt2 = UUID().uuidString
                let encrypted2 = client.encrypt(plainText: toEncrypt2, receiverPublicKeyBase64: server.publicKeyBase64)
                let decrypted2 = server.decrypt(cipherText: encrypted2!, senderPublicKey: client.publicKeyBase64)
                expect(decrypted2).to(match(toEncrypt2))

            }
            
            it("decryptMultipleMessagesWithMultipleSecureMessageInstances") {
                let encryptorPublicKey = "clSZlrJwCQt4j55+4JuZRwcxsM1LEkYwVVf5nADsOjs="
                let encryptorPrivateKey = "tM9UoPd2h3+JsRDrHnrEVT6z400tTVsMjV1Nbb9CsBM="
                let decrypterPublicKey = "GGmpYoMXtAw+xsuonXRhC2LgRDY03K5Jvx1cJ7cXoSw="
                let decrypterPrivateKey = "Xoh8Kn82TL0ORAGfiRCYSYEUOoMkeV57AzG2x4yMGDo="

                var encryptorList = [SecureMessage]()
                var decrypterList = [SecureMessage]()
                for _ in 1...100 {
                    encryptorList.append(SecureMessage(publicKeyBase64: encryptorPublicKey, privateKeyBase64: encryptorPrivateKey))
                    decrypterList.append(SecureMessage(publicKeyBase64: decrypterPublicKey, privateKeyBase64: decrypterPrivateKey))
                }
                for _ in 1...1000 {
                    let message = UUID().uuidString
                    let encryptor = encryptorList.randomElement()!
                    let decrypter = decrypterList.randomElement()!
                    let encrypted = encryptor.encrypt(plainText: message, receiverPublicKeyBase64: decrypter.publicKeyBase64)
                    let decrypted = decrypter.decrypt(cipherText: encrypted!, senderPublicKey: encryptor.publicKeyBase64)
                    expect(decrypted).to(match(message))
                }
            }
            it("decryptMultipleMessagesWithSameSymetricKey") {
                let decrypter = SecureMessage(publicKeyBase64: nil, privateKeyBase64: nil)
                let encrypterPublicKey = "clSZlrJwCQt4j55+4JuZRwcxsM1LEkYwVVf5nADsOjs="
                let encrypterPrivateKey = "tM9UoPd2h3+JsRDrHnrEVT6z400tTVsMjV1Nbb9CsBM="

                for _ in 1...10 {
                    let encrypter = SecureMessage(publicKeyBase64: encrypterPublicKey, privateKeyBase64: encrypterPrivateKey)
                    let message = UUID().uuidString
                    let encrypted = encrypter.encrypt(plainText: message, receiverPublicKeyBase64: decrypter.publicKeyBase64)
                    let decrypted = decrypter.decrypt(cipherText: encrypted!, senderPublicKey: encrypter.publicKeyBase64)
                    expect(decrypted).to(match(message))
                }
            }
            it("symmetric encrypt/decrypt") {
                let secureMessage = SecureMessage(publicKeyBase64: nil, privateKeyBase64: nil)
                let toEncrypt = UUID().uuidString
                let key = "clSZlrJwCQt4j55+4JuZRwcxsM1LEkYwVVf5nADsOjs="
                let encrypted = secureMessage.symmetricEncrypt(plainText: toEncrypt, symmetricKey: key)
                let decrypted = secureMessage.symmetricDecrypt(cipherText: encrypted!, symmetricKey: key)
                expect(toEncrypt).to(match(decrypted))
            }
        }
    }
}
