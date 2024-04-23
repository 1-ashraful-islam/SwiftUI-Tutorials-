//
//  SignupView.swift
//  MakeItSo-ReminderClone
//
//  Created by Ashraful Islam on 4/22/24.
//

import AuthenticationServices
import SwiftUI

private enum FocusableField: Hashable {
    case email
    case password
    case confirmPassword
}

struct SignupView: View {
    @EnvironmentObject var viewModel: AuthenticationViewModel
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.dismiss) var dismiss

    @FocusState private var focus: FocusableField?

    var body: some View {
        VStack {
            HStack {
                Image(colorScheme == .light ? "logo-light" : "logo-dark")
                    .resizable()
                    .frame(width: 30, height: 30, alignment: .center)
                Text("Make It So")
                    .font(.title)
                    .bold()
            }
            .padding(.horizontal)

            VStack {
                Image(colorScheme == .light ? "auth-hero-light" : "auth-hero-dark")
                    .resizable()
                    .frame(maxWidth: .infinity)
                    .scaledToFit()
                    .padding(.vertical, 24)
                Text("Get your work done. Make it so.")
                    .font(.title2)
                    .padding(.bottom, 16)
            }

            Spacer()

            GoogleSignInButton(.signUp) {
                // sign in with Google
            }

            SignInWithAppleButton(.signUp) { request in
                viewModel.handleSignInWithAppleRequest(request)
            } onCompletion: { result in
                Task {
                    if await viewModel.handleSignInWithAppleCompletion(result) {
                        dismiss()
                    }
                }
            }
            .signInWithAppleButtonStyle(colorScheme == .light ? .black : .white)
            .frame(maxWidth: .infinity, minHeight: 50, maxHeight: 50)
            .cornerRadius(8)

            Button(action: {
                withAnimation {
                    viewModel.isOtherAuthOptionsVisible.toggle()
                    self.focus = .email
                }
            }) {
                Text("More sign-up options")
                    .underline()
            }
            .buttonStyle(.plain)
            .padding(.top, 16)

            if viewModel.isOtherAuthOptionsVisible {
                emailPasswordSignInArea
            }

            HStack {
                Text("Already have an account?")
                Button(action: { viewModel.switchFlow() }) {
                    Text("Log in")
                        .fontWeight(.semibold)
                        .foregroundColor(.blue)
                }
            }
            .padding(.vertical, 8)
        }
        .padding()
        .analyticsScreen(name: "\(Self.self)")
    }

    var emailPasswordSignInArea: some View {
        VStack {
            HStack {
                Image(systemName: "at")
                TextField("Email", text: $viewModel.email, axis: .horizontal)
                    .textInputAutocapitalization(.never)
                    .disableAutocorrection(true)
                    .focused($focus, equals: .email)
                    .submitLabel(.next)
                    .onSubmit {
                        self.focus = .password
                    }
            }
            .padding(.vertical, 6)
            .background(Divider(), alignment: .bottom)
            .padding(.bottom, 4)

            HStack {
                Image(systemName: "lock")
                SecureField("Password", text: $viewModel.password)
                    .focused($focus, equals: .password)
                    .submitLabel(.next)
                    .onSubmit {
                        self.focus = .confirmPassword
                    }
            }
            .padding(.vertical, 6)
            .background(Divider(), alignment: .bottom)
            .padding(.bottom, 4)

            HStack {
                Image(systemName: "lock")
                SecureField("Confirm password", text: $viewModel.confirmPassword)
                    .focused($focus, equals: .confirmPassword)
                    .submitLabel(.go)
                    .onSubmit {
                        // Sign up with email and password
                    }
            }
            .padding(.vertical, 6)
            .background(Divider(), alignment: .bottom)
            .padding(.bottom, 4)

            if !viewModel.errorMessage.isEmpty {
                VStack {
                    Text(viewModel.errorMessage)
                        .foregroundStyle(Color(UIColor.systemRed))
                }
            }

            Button(action: { /* sign up with email and password */  }) {
                if viewModel.authenticationState != .authenticating {
                    Text("Sign up")
                        .padding(.vertical, 8)
                        .frame(maxWidth: .infinity)
                } else {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        .padding(.vertical, 8)
                        .frame(maxWidth: .infinity)
                }
            }
            .disabled(!viewModel.isValid)
            .frame(maxWidth: .infinity)
            .buttonStyle(.borderedProminent)
        }
    }
}

#Preview("Dark") {
    SignupView()
        .preferredColorScheme(.dark)
        .environmentObject(AuthenticationViewModel())
}

#Preview("Light") {
    SignupView()
        .preferredColorScheme(.light)
        .environmentObject(AuthenticationViewModel())
}