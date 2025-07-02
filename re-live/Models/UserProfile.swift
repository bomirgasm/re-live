//
//  UserProfile.swift
//  re-live
//
//  Created by Suzie Kim on 6/28/25.
//

import Foundation

/// Basic profile information for a signed in user.
/// This type is separate from FirebaseAuth.User to avoid name conflicts.
struct UserProfile: Codable, Identifiable {
    var id: String
    var email: String?
    var displayName: String?

    init(id: String, email: String? = nil, displayName: String? = nil) {
        self.id = id
        self.email = email
        self.displayName = displayName
    }
}
