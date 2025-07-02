//
//  LoginViewModel.swift
//  re-live
//
//  Created by Suzie Kim on 6/28/25.
//

import UIKit
import FirebaseAuth
import KakaoSDKUser

// ViewModel 프로토콜 정의
typealias BooleanCompletion = (Bool) -> Void

protocol LoginViewModelType {
    func login(
        email: String?,
        password: String?,
        completion: @escaping (Bool) -> Void
    )

    func loginWithGoogle(
        from viewController: UIViewController,
        completion: @escaping (Result<FirebaseAuth.User, Error>) -> Void
    )

    func loginWithApple(
        from viewController: UIViewController,
        completion: @escaping (Result<FirebaseAuth.User, Error>) -> Void
    )
    
    func loginWithKakao(
        from viewController: UIViewController,
        completion: @escaping BooleanCompletion
    )
}



final class LoginViewModel: LoginViewModelType {

    private let authService = AuthService.shared
    var onRecordsLoaded: (([HealthScanResult]) -> Void)?

    func login(
        email: String?,
        password: String?,
        completion: @escaping (Bool) -> Void
    ) {
        guard let email = email, !email.isEmpty,
              let password = password, !password.isEmpty else {
            completion(false)
            return
        }

        Auth.auth().signIn(withEmail: email, password: password) { _, error in
            if let _ = error {
                completion(false)
                return
            }

            guard let uid = Auth.auth().currentUser?.uid else {
                completion(false)
                return
            }

            FirebaseService.shared.loadRecords(for: uid) { records in
                self.onRecordsLoaded?(records)
                completion(true)
            }
        }
    }

    func loginWithGoogle(
        from viewController: UIViewController,
        completion: @escaping (Result<FirebaseAuth.User, Error>) -> Void
    ) {
        authService.signInWithGoogle(from: viewController) { result in
            switch result {
            case .success(let user):
                if let uid = Auth.auth().currentUser?.uid {
                    FirebaseService.shared.loadRecords(for: uid) { records in
                        self.onRecordsLoaded?(records)
                        completion(.success(user))
                    }
                } else {
                    completion(.success(user))
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }

    func loginWithApple(
        from viewController: UIViewController,
        completion: @escaping (Result<FirebaseAuth.User, Error>) -> Void
    ) {
        authService.signInWithApple(from: viewController) { result in
            switch result {
            case .success(let user):
                if let uid = Auth.auth().currentUser?.uid {
                    FirebaseService.shared.loadRecords(for: uid) { records in
                        self.onRecordsLoaded?(records)
                        completion(.success(user))
                    }
                } else {
                    completion(.success(user))
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    func loginWithKakao(
        from viewController: UIViewController,
        completion: @escaping BooleanCompletion) {
            // 1) 앱 설치 여부 분기
            if UserApi.isKakaoTalkLoginAvailable() {
                UserApi.shared.loginWithKakaoTalk(presentationController: viewController) { oauthToken, error in
                    self.handleKakao(oauthToken: oauthToken, error: error, completion: completion)
                }
            } else {
                UserApi.shared.loginWithKakaoAccount(presentationController: viewController) { oauthToken, error in
                    self.handleKakao(oauthToken: oauthToken, error: error, completion: completion)
                }
                    }
    }
    
    func loginWithKakao(
        kakaoUserId: Int,
        completion: @escaping (Bool) -> Void
    ) {
        let kakaoId = kakaoUserId
        let dummyEmail = "\(kakaoId)@re-live.local"
        let dummyPassword = String(kakaoId)

        Auth.auth().createUser(withEmail: dummyEmail, password: dummyPassword) { _, error in
            if let err = error as NSError?, err.code == AuthErrorCode.emailAlreadyInUse.rawValue {
                Auth.auth().signIn(withEmail: dummyEmail, password: dummyPassword) { _, signInError in
                    if let _ = signInError {
                        completion(false)
                    } else {
                        self.fetchRecordsAfterSignIn(completion: completion)
                    }
                }
            } else if error == nil {
                self.fetchRecordsAfterSignIn(completion: completion)
            } else {
                completion(false)
            }
        }
    }

    private func fetchRecordsAfterSignIn(completion: @escaping (Bool) -> Void) {
        guard let uid = Auth.auth().currentUser?.uid else {
            completion(false)
            return
        }
        FirebaseService.shared.loadRecords(for: uid) { records in
            self.onRecordsLoaded?(records)
            completion(true)
        }
    }

    private func handleKakao(oauthToken: OAuthToken?, error: Error?, completion: @escaping BooleanCompletion) {
        if let _ = error {
            completion(false)
            return
        }

        UserApi.shared.me { user, meError in
            if let meError = meError {
                print("Failed to fetch Kakao user: \(meError)")
                completion(false)
                return
            }

            guard let id = user?.id else {
                completion(false)
                return
            }

            self.loginWithKakao(kakaoUserId: Int(id)) { success in
                completion(success)
            }
        }
    }
        
}
