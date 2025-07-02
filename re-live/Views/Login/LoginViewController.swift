//
//  LoginViewController.swift
//  re-live
//
//  Created by Suzie Kim on 6/28/25.
//

import SwiftUI
import Combine
import UIKit
// Google Sign-In
import GoogleSignIn
// Apple Sign-In
import AuthenticationServices
// Kakao 최신 SDK
import KakaoSDKAuth
import KakaoSDKUser
import FirebaseCore

//final class LoginViewController: UIViewController {
final class LoginViewController: UIViewController,
                                 ASAuthorizationControllerDelegate,
                                 ASAuthorizationControllerPresentationContextProviding {
    private let viewModel = LoginViewModel()

    private let emailField = UITextField()
    private let passwordField = UITextField()
    private let passwordToggle = UIButton(type: .system)
    private let loginButton = UIButton(type: .system)
    private var toastLabel: UILabel?
    private var isPasswordVisible = false
    private let googleButton = UIButton(type: .custom)
    private let appleButton = UIButton(type: .system)
//    private let kakaoButton = UIButton(type: .system)
    
    private lazy var googleSignInConfig: GIDConfiguration = {
            guard let clientID = FirebaseApp.app()?.options.clientID else {
                fatalError("Missing Google Client ID in FirebaseApp configuration")
            }
            return GIDConfiguration(clientID: clientID)
        }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupUI()
    }

    // PresentationContextProvider
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        return view.window!
    }
    
    private func setupUI() {
        // Logo
        let logoLabel = UILabel()
        logoLabel.text = "ReLive"
        logoLabel.font = UIFont(name: "Pacifico", size: 36)
        logoLabel.textColor = UIColor(hex: "#007AFF")
        logoLabel.textAlignment = .center
        logoLabel.translatesAutoresizingMaskIntoConstraints = false

        // Welcome Texts
        let welcomeLabel = UILabel()
        welcomeLabel.text = "Welcome Back!"
        welcomeLabel.font = .systemFont(ofSize: 24, weight: .semibold)
        welcomeLabel.textColor = UIColor.gray.withAlphaComponent(0.9)
        welcomeLabel.textAlignment = .center
        welcomeLabel.translatesAutoresizingMaskIntoConstraints = false

        let subtitleLabel = UILabel()
        subtitleLabel.text = "Sign in to continue"
        subtitleLabel.font = .systemFont(ofSize: 16)
        subtitleLabel.textColor = .gray
        subtitleLabel.textAlignment = .center
        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false

        // Email Field
        emailField.placeholder = "Email or Username"
        emailField.borderStyle = .roundedRect
        emailField.autocapitalizationType = .none
        emailField.translatesAutoresizingMaskIntoConstraints = false

        // Password Field
        passwordField.placeholder = "Password"
        passwordField.borderStyle = .roundedRect
        passwordField.autocapitalizationType = .none
        passwordField.isSecureTextEntry = true
        passwordField.translatesAutoresizingMaskIntoConstraints = false

        // Password Toggle
        passwordToggle.setImage(UIImage(systemName: "eye.slash"), for: .normal)
        passwordToggle.tintColor = .gray
        passwordToggle.addTarget(self, action: #selector(togglePasswordVisibility), for: .touchUpInside)
        passwordToggle.translatesAutoresizingMaskIntoConstraints = false

        // Login Button
        loginButton.setTitle("Log In", for: .normal)
        loginButton.setTitleColor(.white, for: .normal)
        loginButton.backgroundColor = UIColor(hex: "#007AFF")
        loginButton.layer.cornerRadius = 8
        loginButton.addTarget(self, action: #selector(loginTapped), for: .touchUpInside)
        loginButton.translatesAutoresizingMaskIntoConstraints = false

        
        // MARK: – Social Login Buttons
        
        // 1) 버튼 생성
        let googleButton = UIButton(type: .custom)
        if let raw = UIImage(named: "google_icon") {
            let original = raw.withRenderingMode(.alwaysOriginal)
            googleButton.setImage(original, for: .normal)
        }
        googleButton.tintColor = .white
        googleButton.backgroundColor = .white
        googleButton.layer.cornerRadius = 8
        googleButton.layer.borderWidth = 1
        googleButton.layer.borderColor = UIColor.gray.withAlphaComponent(0.3).cgColor
        googleButton.addTarget(self, action: #selector(googleLoginTapped), for: .touchUpInside)
        googleButton.translatesAutoresizingMaskIntoConstraints = false
        
        // 3. 컨텐츠 중앙 정렬 & 이미지 비율 맞춤
        googleButton.contentHorizontalAlignment = .center
        googleButton.contentVerticalAlignment   = .center
        googleButton.imageView?.contentMode     = .scaleAspectFit
        googleButton.translatesAutoresizingMaskIntoConstraints = false
        googleButton.imageEdgeInsets = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)

        
        NSLayoutConstraint.activate([
            googleButton.widthAnchor.constraint(equalToConstant: 44),
            googleButton.heightAnchor.constraint(equalToConstant: 44)
        ])
        
        let appleButton = UIButton(type: .system)
        appleButton.setImage(UIImage(systemName: "applelogo"), for: .normal)
        appleButton.tintColor = .black
        appleButton.layer.cornerRadius = 8
        appleButton.layer.borderWidth = 1
        appleButton.layer.borderColor = UIColor.gray.withAlphaComponent(0.3).cgColor
        appleButton.addTarget(self, action: #selector(appleLoginTapped), for: .touchUpInside)
        appleButton.translatesAutoresizingMaskIntoConstraints = false
        
        let kakaoButton = UIButton(type: .system)
        kakaoButton.setImage(UIImage(named: "kakao_icon"), for: .normal)
        kakaoButton.tintColor = .black
        kakaoButton.layer.cornerRadius = 8
        kakaoButton.layer.borderWidth = 1
        kakaoButton.layer.borderColor = UIColor.gray.withAlphaComponent(0.3).cgColor
        kakaoButton.addTarget(self, action: #selector(kakaoLoginTapped), for: .touchUpInside)
        kakaoButton.translatesAutoresizingMaskIntoConstraints = false
        
//         2) 스택뷰로 묶기
        let socialStack = UIStackView(arrangedSubviews: [googleButton, appleButton, kakaoButton])
        socialStack.axis = .horizontal
        socialStack.distribution = .fillEqually
        socialStack.spacing = 16
        socialStack.translatesAutoresizingMaskIntoConstraints = false
        
        // Divider (or continue with)
        let leftLine = UIView()
        leftLine.backgroundColor = UIColor.gray.withAlphaComponent(0.3)
        leftLine.translatesAutoresizingMaskIntoConstraints = false
        let rightLine = UIView()
        rightLine.backgroundColor = UIColor.gray.withAlphaComponent(0.3)
        rightLine.translatesAutoresizingMaskIntoConstraints = false
        let orLabel = UILabel()
        orLabel.text = "or continue with"
        orLabel.font = .systemFont(ofSize: 14)
        orLabel.textColor = .gray
        orLabel.translatesAutoresizingMaskIntoConstraints = false
        
        let dividerStack = UIStackView(arrangedSubviews: [leftLine, orLabel, rightLine])
        dividerStack.axis = .horizontal
        dividerStack.alignment = .center
        dividerStack.spacing = 8
        dividerStack.translatesAutoresizingMaskIntoConstraints = false
        
        // Forgot / Join Links
        let forgotButton = UIButton(type: .system)
        forgotButton.setTitle("Forgot Password?", for: .normal)
        forgotButton.titleLabel?.font = .systemFont(ofSize: 14)
        forgotButton.setTitleColor(UIColor(hex: "#007AFF"), for: .normal)
        forgotButton.translatesAutoresizingMaskIntoConstraints = false
        let joinButton = UIButton(type: .system)
        joinButton.setTitle("Create Account", for: .normal)
        joinButton.titleLabel?.font = .systemFont(ofSize: 14)
        joinButton.setTitleColor(UIColor(hex: "#007AFF"), for: .normal)
        joinButton.translatesAutoresizingMaskIntoConstraints = false
        
        let linksStack = UIStackView(arrangedSubviews: [forgotButton, joinButton])
        linksStack.axis = .horizontal
        linksStack.distribution = .equalCentering
        linksStack.translatesAutoresizingMaskIntoConstraints = false
        
        // Return to Home
        let homeButton = UIButton(type: .system)
        homeButton.setTitle("Return to Home", for: .normal)
        homeButton.setImage(UIImage(systemName: "house"), for: .normal)
        homeButton.tintColor = .gray
        homeButton.titleLabel?.font = .systemFont(ofSize: 14)
        homeButton.semanticContentAttribute = .forceLeftToRight
        homeButton.imageEdgeInsets = UIEdgeInsets(top: 0, left: -4, bottom: 0, right: 4)
        homeButton.translatesAutoresizingMaskIntoConstraints = false
        homeButton.addTarget(self, action: #selector(returnHomeTapped), for: .touchUpInside)
        
        // Add subviews
        view.addSubview(logoLabel)
        view.addSubview(welcomeLabel)
        view.addSubview(subtitleLabel)
        view.addSubview(emailField)
        view.addSubview(passwordField)
        view.addSubview(passwordToggle)
        view.addSubview(loginButton)
        view.addSubview(socialStack)
        view.addSubview(linksStack)
        view.addSubview(homeButton)

        // Layout
        NSLayoutConstraint.activate([
            logoLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 80),
            logoLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),

            welcomeLabel.topAnchor.constraint(equalTo: logoLabel.bottomAnchor, constant: 24),
            welcomeLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),

            subtitleLabel.topAnchor.constraint(equalTo: welcomeLabel.bottomAnchor, constant: 4),
            subtitleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),

            emailField.topAnchor.constraint(equalTo: subtitleLabel.bottomAnchor, constant: 32),
            emailField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            emailField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
            emailField.heightAnchor.constraint(equalToConstant: 44),

            passwordField.topAnchor.constraint(equalTo: emailField.bottomAnchor, constant: 16),
            passwordField.leadingAnchor.constraint(equalTo: emailField.leadingAnchor),
            passwordField.trailingAnchor.constraint(equalTo: emailField.trailingAnchor, constant: -40),
            passwordField.heightAnchor.constraint(equalToConstant: 44),

            passwordToggle.centerYAnchor.constraint(equalTo: passwordField.centerYAnchor),
            passwordToggle.leadingAnchor.constraint(equalTo: passwordField.trailingAnchor, constant: 8),
            passwordToggle.widthAnchor.constraint(equalToConstant: 30),
            passwordToggle.heightAnchor.constraint(equalToConstant: 30),

            loginButton.topAnchor.constraint(equalTo: passwordField.bottomAnchor, constant: 24),
            loginButton.leadingAnchor.constraint(equalTo: emailField.leadingAnchor),
            loginButton.trailingAnchor.constraint(equalTo: emailField.trailingAnchor),
            loginButton.heightAnchor.constraint(equalToConstant: 44),
            
            socialStack.topAnchor.constraint(equalTo: loginButton.bottomAnchor, constant: 32),
            socialStack.leadingAnchor.constraint(equalTo: emailField.leadingAnchor),
            socialStack.trailingAnchor.constraint(equalTo: emailField.trailingAnchor),
            socialStack.heightAnchor.constraint(equalToConstant: 50),
            
            linksStack.topAnchor.constraint(equalTo: socialStack.bottomAnchor, constant: 16),
            linksStack.leadingAnchor.constraint(equalTo: emailField.leadingAnchor),
            linksStack.trailingAnchor.constraint(equalTo: emailField.trailingAnchor),
            
            homeButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            homeButton.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }

    @objc private func togglePasswordVisibility() {
        isPasswordVisible.toggle()
        passwordField.isSecureTextEntry = !isPasswordVisible
        let icon = isPasswordVisible ? "eye" : "eye.slash"
        passwordToggle.setImage(UIImage(systemName: icon), for: .normal)
    }

    @objc private func loginTapped() {
        let email = emailField.text
        let password = passwordField.text

        viewModel.login(email: email, password: password) { [weak self] success in
            if success {
                self?.showToast(message: "Login successful")
                // TODO: 다음 화면으로 이동
            } else {
                self?.showToast(message: "Login failed")
            }
        }
    }
    
    // MARK: – Social Login Actions
    
    @objc private func googleLoginTapped() {
        
        // 1) 옵셔널 바인딩으로 clientID 추출
        guard let clientID = FirebaseApp.app()?.options.clientID else {
            // 만약 값이 없으면 토스트나 로그로 사용자에게 알려주고 리턴
            self.showToast(message: "Google Sign-In not configured")
            return
        }
        
        // 2) GIDConfiguration 생성 및 할당
        let config = GIDConfiguration(clientID: clientID)
        GIDSignIn.sharedInstance.configuration = config
        
        // 3) 호출 (withPresenting:completion:)
        GIDSignIn.sharedInstance.signIn(withPresenting: self) { signInResult, error in
            if let error = error {
                self.showToast(message: "Google login failed: \(error.localizedDescription)")
                return
            }
            
            // signInResult.user 에 접근
            self.showToast(message: "Google login success")
            // TODO: 화면 전환 등
        }
    }
    
    @objc private func appleLoginTapped() {
        // 예: Apple 로그인 요청
        let provider = ASAuthorizationAppleIDProvider()
        let request = provider.createRequest()
        request.requestedScopes = [.fullName, .email]
        let controller = ASAuthorizationController(authorizationRequests: [request])
        controller.delegate = self
        controller.presentationContextProvider = self
        controller.performRequests()
    }
    
    @objc private func kakaoLoginTapped() {
        // 예: Kakao SDK 호출
        UserApi.shared.loginWithKakaoAccount {(oauthToken, error) in
                if let error = error {
                    print(error)
                }
                else {
                    print("loginWithKakaoAccount() success.")
                    self.importKakaoProfile()

                    // 성공 시 동작 구현
                    _ = oauthToken
                }
            }
    }
    
    @objc private func importKakaoProfile() {
        UserApi.shared.me() {(user, error) in
            if let error = error {
                print(error)
            }
            else {
                print("me() success.")
                
                // 성공 시 동작 구현
                _ = user
            }
        }
    }
    
    @objc private func returnHomeTapped() {
        // 로그인 화면 닫고 탭바 컨트롤러 루트로 돌아가기
        dismiss(animated: true, completion: nil)
    }


    private func showToast(message: String) {
        toastLabel?.removeFromSuperview()

        let label = UILabel()
        label.text = message
        label.textColor = .systemGreen
        label.font = .systemFont(ofSize: 14)
        label.backgroundColor = UIColor.systemGreen.withAlphaComponent(0.1)
        label.textAlignment = .center
        label.layer.cornerRadius = 8
        label.layer.masksToBounds = true
        label.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(label)
        toastLabel = label

        NSLayoutConstraint.activate([
            label.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 8),
            label.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            label.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
            label.heightAnchor.constraint(equalToConstant: 40)
        ])

        label.alpha = 0
        UIView.animate(withDuration: 0.3, animations: {
            label.alpha = 1
        }) { _ in
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                UIView.animate(withDuration: 0.3, animations: {
                    label.alpha = 0
                }) { _ in
                    label.removeFromSuperview()
                }
            }
        }
    }
    
}
//// MARK: - Color Hex Extension
//extension Color {
//    init(hex: String) {
//        let hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines)
//                                .replacingOccurrences(of: "#", with: "")
//        var rgb: UInt64 = 0
//        Scanner(string: hexSanitized).scanHexInt64(&rgb)
//        let r = Double((rgb & 0xFF0000) >> 16) / 255.0
//        let g = Double((rgb & 0x00FF00) >> 8) / 255.0
//        let b = Double(rgb & 0x0000FF) / 255.0
//        self.init(red: r, green: g, blue: b)
//    }
//}
//
//// MARK: - ViewModel
//final class LoginViewModel: ObservableObject {
//    @Published var email: String = ""
//    @Published var password: String = ""
//    @Published var isPasswordVisible: Bool = false
//    @Published var showToast: Bool = false
//    private var cancellables = Set<AnyCancellable>()
//
//    // TODO: Inject authentication service or coordinator for navigation
//    func togglePasswordVisibility() {
//        isPasswordVisible.toggle()
//    }
//
//    func login() {
//        // TODO: Perform login logic (e.g., call service)
//        // On success:
//        showToast = true
//        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
//            withAnimation {
//                self.showToast = false
//            }
//        }
//    }
//}
//
//// MARK: - Social Login Button
//struct SocialButton: View {
//    let systemImage: String
//    let action: () -> Void
//
//    var body: some View {
//        Button(action: action) {
//            Image(systemName: systemImage)
//                .resizable()
//                .scaledToFit()
//                .frame(width: 20, height: 20)
//                .padding()
//                .background(Color.white)
//                .overlay(
//                    RoundedRectangle(cornerRadius: 8)
//                        .stroke(Color.gray.opacity(0.3), lineWidth: 1)
//                )
//        }
//    }
//}
//
//// MARK: - Toast View
//struct ToastView: View {
//    let message: String
//
//    var body: some View {
//        HStack(spacing: 8) {
//            Image(systemName: "checkmark-circle.fill")
//                .font(.title2)
//                .foregroundColor(.green)
//            Text(message)
//                .font(.subheadline)
//                .foregroundColor(.green)
//        }
//        .padding(.vertical, 8)
//        .padding(.horizontal, 16)
//        .background(Color.green.opacity(0.1))
//        .cornerRadius(8)
//        .padding(.top, 8)
//        .frame(maxWidth: .infinity)
//    }
//}
//
//// MARK: - Login View
//struct LoginView: View {
//    @StateObject private var viewModel = LoginViewModel()
//
//    var body: some View {
//        ZStack(alignment: .top) {
//            Color.white
//                .ignoresSafeArea()
//
//            VStack {
//                Spacer().frame(height: 80)
//                // Logo
//                Text("logo")
//                    .font(.custom("Pacifico", size: 36))
//                    .foregroundColor(Color(hex: "#007AFF"))
//                    .frame(width: 96, height: 96)
//                Spacer().frame(height: 24)
//                Text("Welcome Back")
//                    .font(.system(size: 24, weight: .semibold))
//                    .foregroundColor(.gray.opacity(0.9))
//                Text("Sign in to continue")
//                    .font(.system(size: 16))
//                    .foregroundColor(.gray)
//                    .padding(.bottom, 32)
//
//                // Login Form
//                VStack(spacing: 16) {
//                    // Email Field
//                    HStack {
//                        Image(systemName: "envelope")
//                            .foregroundColor(.gray)
//                        TextField("Email or Username", text: $viewModel.email)
//                            .autocapitalization(.none)
//                            .disableAutocorrection(true)
//                    }
//                    .padding()
//                    .background(Color.gray.opacity(0.1))
//                    .cornerRadius(8)
//
//                    // Password Field
//                    HStack {
//                        Image(systemName: "lock")
//                            .foregroundColor(.gray)
//                        Group {
//                            if viewModel.isPasswordVisible {
//                                TextField("Password", text: $viewModel.password)
//                                    .autocapitalization(.none)
//                                    .disableAutocorrection(true)
//                            } else {
//                                SecureField("Password", text: $viewModel.password)
//                            }
//                        }
//                        Button(action: viewModel.togglePasswordVisibility) {
//                            Image(systemName: viewModel.isPasswordVisible ? "eye" : "eye.slash")
//                                .foregroundColor(.gray)
//                        }
//                    }
//                    .padding()
//                    .background(Color.gray.opacity(0.1))
//                    .cornerRadius(8)
//
//                    // Login Button
//                    Button(action: viewModel.login) {
//                        Text("Log In")
//                            .frame(maxWidth: .infinity)
//                            .padding()
//                            .background(Color(hex: "#007AFF"))
//                            .foregroundColor(.white)
//                            .cornerRadius(8)
//                    }
//                }
//                .padding(.horizontal, 16)
//
//                // Divider & Social Login
//                HStack(alignment: .center) {
//                    Rectangle()
//                        .frame(height: 1)
//                        .foregroundColor(.gray.opacity(0.3))
//                    Text("or continue with")
//                        .font(.caption)
//                        .foregroundColor(.gray)
//                    Rectangle()
//                        .frame(height: 1)
//                        .foregroundColor(.gray.opacity(0.3))
//                }
//                .padding(.vertical, 24)
//                .padding(.horizontal, 16)
//
//                HStack(spacing: 16) {
//                    SocialButton(systemImage: "globe") { /* Google login */ }
//                    SocialButton(systemImage: "applelogo") { /* Apple login */ }
//                    SocialButton(systemImage: "message.fill") { /* Kakao login */ }
//                }
//                .padding(.horizontal, 16)
//
//                // Links
//                HStack {
//                    Button("Forgot Password?") { /* TODO */ }
//                        .font(.caption)
//                        .foregroundColor(Color(hex: "#007AFF"))
//                    Spacer()
//                    Button("Create Account") { /* TODO */ }
//                        .font(.caption)
//                        .foregroundColor(Color(hex: "#007AFF"))
//                }
//                .padding(.horizontal, 16)
//
//                Spacer()
//
//                // Footer Home Link
//                Button(action: {
//                    // TODO: Navigate back to home, e.g., via coordinator
//                }) {
//                    HStack(spacing: 4) {
//                        Image(systemName: "house")
//                        Text("Return to Home")
//                    }
//                    .font(.caption)
//                    .foregroundColor(.gray)
//                }
//                .padding(.bottom, 16)
//            }
//
//            // Toast Notification
//            if viewModel.showToast {
//                ToastView(message: "Successfully signed out")
//                    .transition(.move(edge: .top).combined(with: .opacity))
//            }
//        }
//    }
//}
//
// MARK: - Preview
#if DEBUG
import SwiftUI
import UIKit
import AuthenticationServices

// 1) UIViewController를 SwiftUI View 로 감싸는 래퍼
struct LoginViewControllerRepresentable: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> UINavigationController {
        let vc = LoginViewController()
        // 네비게이션 바가 필요 없으면 그냥 vc 만 리턴하셔도 됩니다.
        return UINavigationController(rootViewController: vc)
    }

    func updateUIViewController(_ uiViewController: UINavigationController, context: Context) {
        // 동적 업데이트가 필요하면 여기에 추가
    }
}

// 2) PreviewProvider 에서 래퍼를 사용
struct LoginViewController_Previews: PreviewProvider {
    static var previews: some View {
        LoginViewControllerRepresentable()
            .edgesIgnoringSafeArea(.all)    // 전체 화면 보기
    }
}
#endif
