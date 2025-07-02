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
        completion: @escaping (Result<User, Error>) -> Void
    )

    func loginWithApple(
        from viewController: UIViewController,
        completion: @escaping (Result<User, Error>) -> Void
    )
    
    func loginWithKakao(
        from viewController: UIViewController,
        completion: @escaping BooleanCompletion
    )
}



final class LoginViewModel: LoginViewModelType {
    
    private let authService = AuthService.shared

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
            completion(error == nil)
        }
    }

    func loginWithGoogle(
        from viewController: UIViewController,
        completion: @escaping (Result<User, Error>) -> Void
    ) {
        authService.signInWithGoogle(from: viewController, completion: completion)
    }

    func loginWithApple(
        from viewController: UIViewController,
        completion: @escaping (Result<User, Error>) -> Void
    ) {
        authService.signInWithApple(from: viewController, completion: completion)
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

            // Firebase Email/Password 방식으로 가입 시도
            Auth.auth().createUser(withEmail: dummyEmail, password: dummyPassword) { _, error in
                if let err = error as NSError?, err.code == AuthErrorCode.emailAlreadyInUse.rawValue {
                    // 이미 가입된 경우 -> 로그인
                    Auth.auth().signIn(withEmail: dummyEmail, password: dummyPassword) { _, signInError in
                        completion(signInError == nil)
                    }
                } else {
                    // 신규 가입 성공 또는 다른 에러
                    completion(error == nil)
                }
            }
        }
        
}
