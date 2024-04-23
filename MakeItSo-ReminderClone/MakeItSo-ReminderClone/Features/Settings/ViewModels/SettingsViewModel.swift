//
//  SettingsViewModel.swift
//  MakeItSo-ReminderClone
//
//  Created by Ashraful Islam on 4/22/24.
//

import Combine
import FirebaseAuth
import Foundation

class SettingsViewModel: ObservableObject {
    @Published var user: User?
    @Published var displayName = ""

    @Published var isGuestUser = false

    @Published var loggedInAs = ""

    init() {
        $user
            .compactMap { user in
                user?.isAnonymous
            }
            .assign(to: &$isGuestUser)

        $user
            .compactMap { user in
                user?.displayName ?? user?.email ?? ""
            }
            .assign(to: &$displayName)

        Publishers.CombineLatest($isGuestUser, $displayName)
            .map { isGuest, displayName in
                isGuest
                    ? "You're using the app as a guest"
                    : "Logged in as \(displayName)"
            }
            .assign(to: &$loggedInAs)
    }

    func signOut() {
        fatalError("Not implemented yet")
    }
}
