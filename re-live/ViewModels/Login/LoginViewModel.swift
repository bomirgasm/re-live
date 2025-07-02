//
//  LoginViewModel.swift
//  re-live
//
//  Created by Suzie Kim on 6/28/25.
//

import UIKit
import FirebaseAuth
import KakaoSDKUser
import KakaoSDKAuth

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
    

    private func handleKakao(
        oauthToken: OAuthToken?,
        error: Error?,
        completion: @escaping BooleanCompletion
    ) {
        guard error == nil, let token = oauthToken else {
            completion(false)
            return
        }

        // 1) 현재 사용자 정보 조회
        UserApi.shared.me { user, kakaoError in
            guard kakaoError == nil, let user = user else {
                completion(false)
                return
            }

            // 2) Firebase 커스텀 토큰 혹은 OAuthProvider를 이용해 로그인
            //    실제 서비스에서는 서버에서 발급받은 커스텀 토큰을 사용해야 합니다.
            let credential = OAuthProvider.credential(
                withProviderID: "oidc.kakao",
                idToken: token.idToken ?? "",
                accessToken: token.accessToken
            )

            Auth.auth().signIn(with: credential) { _, firebaseError in
                if let firebaseError = firebaseError {
                    print("Firebase sign-in failed: \(firebaseError)")
                    completion(false)
                } else {
                    print("Kakao user \(user.id ?? 0) signed in")
                    completion(true)
                }
            }
        }
    }
        
}
