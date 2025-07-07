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
            if (UserApi.isKakaoTalkLoginAvailable()) {
                UserApi.shared.loginWithKakaoTalk {(oauthToken, error) in
                    if let error = error {
                        print(error)
                    }
                    else {
                        print("loginWithKakaoTalk() success.")
                        
                        // 성공 시 동작 구현
                        _ = oauthToken
                        
                        self.handleKakao(oauthToken: oauthToken, error: nil, completion: completion)
                        
                    }
                }
            }
        }
    
//    func loginWithKakao(
//        kakaoUserId: Int,
//        completion: @escaping (Bool) -> Void) {
//            let kakaoId = kakaoUserId
//            let dummyEmail = "\(kakaoId)@re-live.local"
//            let dummyPassword = String(kakaoId)
//            
//            Auth.auth().createUser(withEmail: dummyEmail, password: dummyPassword) { _, error in
//                if let err = error as NSError?, err.code == AuthErrorCode.emailAlreadyInUse.rawValue {
//                    Auth.auth().signIn(withEmail: dummyEmail, password: dummyPassword) { _, signInError in
//                        if let _ = signInError {
//                            completion(false)
//                        } else {
//                            self.fetchRecordsAfterSignIn(completion: completion)
//                        }
//                    }
//                } else if error == nil {
//                    self.fetchRecordsAfterSignIn(completion: completion)
//                } else {
//                    completion(false)
//                }
//            }
//        }
    
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
    
    func handleKakao(oauthToken: OAuthToken?, error: Error?, completion: @escaping BooleanCompletion) {
        // 1) 토큰 에러 체크
        if let _ = error {
            completion(false)
            return
        }
        // 2) 카카오 사용자 프로필 정보 요청
        UserApi.shared.me { user, meError in
            if let meError = meError {
                print("Failed to fetch Kakao user: \(meError)")
                completion(false)
                return
            }
            // 2-2) 프로필에서 id 추출
            guard let id = user?.id else {
                completion(false)
                return
            }
            
            let kakaoId = Int(id)
            // 3) Firebase용 더미 이메일/비밀번호 생성
            let dummyEmail = "\(kakaoId)@re-live.local"
            let dummyPassword = String(kakaoId)
            
            // 4) Firebase에 사용자 생성 시도
            Auth.auth().createUser(withEmail: dummyEmail, password: dummyPassword) { _, createError in
                if let err = createError as NSError?,
                   err.code == AuthErrorCode.emailAlreadyInUse.rawValue {
                    // 4-1) 이미 있으면 signIn 시도
                    Auth.auth().signIn(withEmail: dummyEmail, password: dummyPassword) { _, signInError in
                        if let signInError = signInError {
                            // 4-1-1) signIn 실패
                            print("Firebase signIn 오류:", signInError)
                            completion(false)
                        } else {
                            // 4-1-2) signIn 성공 후 추가 데이터 로드
                            self.fetchRecordsAfterSignIn(completion: completion)
                        }
                    }
                } else if createError == nil {
                    // 4-2) 새 사용자 생성 성공 후 추가 데이터 로드
                    self.fetchRecordsAfterSignIn(completion: completion)
                } else {
                    // 4-3) 사용자 생성 중 기타 오류
                    print("Firebase createUser 오류:", createError!)
                    completion(false)
                }
            }
        }
    }
}
