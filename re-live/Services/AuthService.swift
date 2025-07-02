//
//  AuthService.swift
//  re-live
//
//  Created by Suzie Kim on 6/28/25.
//

import Foundation
import FirebaseCore
import FirebaseAuth
import GoogleSignIn
import AuthenticationServices
import UIKit
import CryptoKit

final class AuthService: NSObject {
    
    static let shared = AuthService()
    
    private override init() { }
    
    // MARK: - Apple 로그인
    
    private var currentNonce: String?
    
    func signInWithApple(from viewController: UIViewController, completion: @escaping (Result<User, Error>) -> Void) {
        let provider = ASAuthorizationAppleIDProvider()
        let request = provider.createRequest()
        request.requestedScopes = [.fullName, .email]
        let nonce = randomNonceString()
        currentNonce = nonce
        request.nonce = sha256(nonce)
        
        let controller = ASAuthorizationController(authorizationRequests: [request])
        controller.delegate = self
        controller.presentationContextProvider = viewController as? ASAuthorizationControllerPresentationContextProviding
        controller.performRequests()
        
        self.appleLoginCompletion = completion
    }
    
    private var appleLoginCompletion: ((Result<User, Error>) -> Void)?
    
    // MARK: - Google 로그인
    
    func signInWithGoogle(from viewController: UIViewController, completion: @escaping (Result<User, Error>) -> Void) {
        guard let clientID = FirebaseApp.app()?.options.clientID else {
            completion(.failure(AuthError.missingClientID))
            return
        }
        
        let config = GIDConfiguration(clientID: clientID)
        GIDSignIn.sharedInstance.configuration = config
        
        
        GIDSignIn.sharedInstance.signIn(withPresenting: viewController) { result, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let user = result?.user else {
                completion(.failure(AuthError.invalidGoogleCredential))
                return
            }

            let idToken     = user.idToken!.tokenString
               let accessToken = user.accessToken.tokenString

               let credential = GoogleAuthProvider.credential(
                   withIDToken:     idToken,
                   accessToken:     accessToken
               )
            
            Auth.auth().signIn(with: credential) { result, error in
                if let error = error {
                    completion(.failure(error))
                } else if let user = result?.user {
                    completion(.success(user))
                }
            }
        }
    }
    
    // MARK: - 공통 에러
    enum AuthError: Error {
        case missingClientID
        case invalidGoogleCredential
        case unknown
    }
}


// Apple 로그인 결과 처리
extension AuthService: ASAuthorizationControllerDelegate {
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        guard let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential else {
            appleLoginCompletion?(.failure(AuthError.unknown))
            return
        }
        
        guard
            let identityToken = appleIDCredential.identityToken,
            let tokenString = String(data: identityToken, encoding: .utf8),
            let nonce = currentNonce
        else {
            appleLoginCompletion?(.failure(AuthError.unknown))
            return
        }
        
        let credential = OAuthProvider.credential(withProviderID: "apple.com", idToken: tokenString, rawNonce: nonce)
        Auth.auth().signIn(with: credential) { result, error in
            if let error = error {
                self.appleLoginCompletion?(.failure(error))
            } else if let user = result?.user {
                self.appleLoginCompletion?(.success(user))
            }
        }
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        appleLoginCompletion?(.failure(error))
    }
}

private func randomNonceString(length: Int = 32) -> String {
    let charset: Array<Character> =
    Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
    var result = ""
    var remainingLength = length
    
    while remainingLength > 0 {
        let randoms = (0..<16).map { _ in UInt8.random(in: 0...255) }
        
        randoms.forEach { random in
            if remainingLength == 0 { return }
            if random < charset.count {
                result.append(charset[Int(random)])
                remainingLength -= 1
            }
        }
    }
    
    return result
}

private func sha256(_ input: String) -> String {
    let inputData = Data(input.utf8)
    let hashed = SHA256.hash(data: inputData)
    return hashed.compactMap { String(format: "%02x", $0) }.joined()
}

