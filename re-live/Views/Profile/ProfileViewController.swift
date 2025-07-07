//
//  ProfileViewController.swift
//  re-live
//
//  Created by Suzie Kim on 6/18/25.
//

import UIKit
import FirebaseAuth

class ProfileViewController: UIViewController {
    
    // MARK: - UI Elements
    private let statusLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 18)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let indicatorView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 10
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let actionButton: UIButton = {
        let button = UIButton(type: .system)
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .semibold)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    // MARK: - Auth Listener Handle
    private var authHandle: AuthStateDidChangeListenerHandle?
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemGroupedBackground
        title = "Profile"
        setupUI()
        // Listen for auth state changes to update indicator automatically
        authHandle = Auth.auth().addStateDidChangeListener { [weak self] _, _ in
            self?.updateUI()
        }
        updateUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
            super.viewWillAppear(animated)
            // Ensure UI reflects current auth state
            updateUI()
        }

        deinit {
            // Remove listener on deinit
            if let handle = authHandle {
                Auth.auth().removeStateDidChangeListener(handle)
            }
        }

    // MARK: - Setup
    private func setupUI() {
        // Add subviews
        view.addSubview(indicatorView)
        view.addSubview(statusLabel)
        view.addSubview(actionButton)
        
        // Layout constraints
        NSLayoutConstraint.activate([
            indicatorView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 40),
            indicatorView.centerXAnchor.constraint(equalTo: view.centerXAnchor, constant: -60),
            indicatorView.widthAnchor.constraint(equalToConstant: 20),
            indicatorView.heightAnchor.constraint(equalToConstant: 20),
            
            statusLabel.centerYAnchor.constraint(equalTo: indicatorView.centerYAnchor),
            statusLabel.leadingAnchor.constraint(equalTo: indicatorView.trailingAnchor, constant: 12),
            statusLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
            
            actionButton.topAnchor.constraint(equalTo: statusLabel.bottomAnchor, constant: 32),
            actionButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            actionButton.heightAnchor.constraint(equalToConstant: 44),
            actionButton.widthAnchor.constraint(equalToConstant: 140)
        ])
        
        actionButton.addTarget(self, action: #selector(actionButtonTapped), for: .touchUpInside)
    }
    
    // MARK: - UI Update
    private func updateUI() {
        if let user = Auth.auth().currentUser {
            // Logged in state
            indicatorView.backgroundColor = .systemGreen
            statusLabel.text = "Logged in as \(user.email ?? "User")"
            actionButton.setTitle("Log Out", for: .normal)
        } else {
            // Logged out state
            indicatorView.backgroundColor = .systemRed
            statusLabel.text = "Not Logged In"
            actionButton.setTitle("Log In", for: .normal)
        }
    }
    
    // MARK: - Actions
    @objc private func actionButtonTapped() {
        if Auth.auth().currentUser != nil {
            // Perform logout
            do {
                try Auth.auth().signOut()
                updateUI()
            } catch {
                let alert = UIAlertController(title: "Error", message: "Failed to sign out: \(error.localizedDescription)", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default))
                present(alert, animated: true)
            }
        } else {
            // Present login screen
            let loginVC = LoginViewController()
            loginVC.modalPresentationStyle = .fullScreen
            present(loginVC, animated: true)
        }
    }
}

