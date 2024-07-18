//
//  ForgotPasswordView.swift
//  TLMS-admin
//
//  Created by Abcom on 09/07/24.
//

import SwiftUI
import FirebaseAuth

struct ForgotPasswordView: View {
    
    @Environment(\.presentationMode) var presentationMode
    @Environment(\.colorScheme) var colorScheme
    @State private var email = ""
    @State private var isEmailValid = false
    @State private var showAlert = false
    @State private var navigateToHome = false
    @State private var alertMessage = ""
    
    var body: some View {
        VStack(alignment: .center, spacing: 70) {
            Text("Enter your registered email address")
                .font(.largeTitle)
                .foregroundColor(colorScheme == .dark ? .white : .black)
                .padding(.bottom, 100)
            VStack() {
                CustomTextField(placeholder: "Email", text: $email)
                    .onChange(of: email) { _, newVal in
                        isEmailValid = validateEmail(email: newVal)
                        print(isEmailValid)
                }
            }
            HStack {
                Spacer()
                if !isEmailValid && email != "" {
                    Text("Enter a valid email address")
                        .font(.caption2)
                        .foregroundColor(.red)
                        .padding(.trailing, 35)
                } else {
                    Text("Enter a valid email address")
                        .font(.caption2)
                        .foregroundColor(colorScheme == .dark ? .white : .black)
                        .padding(.trailing, 15)
                }
            }
            
            CustomButton(label: "Send E-Mail", action: {
                if !isEmailValid {
                    alertMessage = "Please enter the field correctly"
                    showAlert = true
                } else {
                    passwordReset()
                }
            })
        }
        .padding(.bottom, 100)
        .alert(isPresented: $showAlert) {
            Alert(
                title: Text("Notification"),
                message: Text(alertMessage),
                dismissButton: .default(Text("OK")) {
                    presentationMode.wrappedValue.dismiss()
                })
        }
    }
    
    func passwordReset() {
        Auth.auth().sendPasswordReset(withEmail: email) { error in
            if let _ = error {
                print("Error. Couldn't mail the link.")
                alertMessage = "Failed to send the link"
                showAlert = true
            } else {
                print("Sent Mail for Changing Password")
                alertMessage = "Successfully sent the link to your registered E-Mail."
                showAlert = true
            }
        }
    }
}

#Preview {
    ForgotPasswordView()
}
