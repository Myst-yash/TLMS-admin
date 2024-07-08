import SwiftUI
import FirebaseAuth
import FirebaseFirestore
import FirebaseStorage

struct CreateAccountView: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var showAlert = false
    @State private var alertMessage = ""
    @State private var profilePicture: Image? = nil
    @State private var first: String = ""
    @State private var last: String = ""
    @State private var about: String = ""
    @State private var phoneNumber: String = ""
    @State private var email: String = ""
    @State private var newPassword: String = ""
    @State private var confirmPassword: String = ""
    @State private var showImagePicker: Bool = false
    @State private var selectedImage: UIImage? = nil
    @State private var isLoading = false
    @State private var navigateToPendingEdu = false
    
    @State private var isFirstNameValid = false
    @State private var isLastNameValid = false
    @State private var isEmailValid = false
    @State private var isPasswordValid = false
    @State private var isAboutValid = false
    @State private var isPhoneNumberValid = false

    var body: some View {
        NavigationView {
            ZStack(alignment: .bottom) {
                PNGImageView(imageName: "Waves", width: 394, height: 194)

                VStack(spacing: 20) {
                    ScrollView {
                        VStack {
                            Button(action: {
                                showImagePicker = true
                            }) {
                                if let selectedImage = selectedImage {
                                    Image(uiImage: selectedImage)
                                        .resizable()
                                        .frame(width: 100, height: 100)
                                        .clipShape(Circle())
                                        .overlay(Circle().stroke(Color.black, lineWidth: 2))
                                        .padding()
                                } else {
                                    Image(systemName: "person.circle.fill")
                                        .resizable()
                                        .frame(width: 100, height: 100)
                                        .clipShape(Circle())
                                        .overlay(Circle().stroke(Color.black, lineWidth: 2))
                                        .padding()
                                }
                            }

                            VStack(spacing: 15) {
                                HStack {
                                    TextField("First Name", text: $first).padding()
                                        .frame(height: 55)
                                        .background(Color.white)
                                        .cornerRadius(12)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 12)
                                                .stroke(Color.gray, lineWidth: 1)
                                        )
                                        .onChange(of: first) { _, newVal in
                                            isFirstNameValid = validateName(name: first)
                                        }
                                    
                                    TextField("Last Name", text: $last).padding()
                                        .frame(height: 55)
                                        .background(Color.white)
                                        .cornerRadius(12)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 12)
                                                .stroke(Color.gray, lineWidth: 1)
                                        )
                                        .onChange(of: first) { _, newVal in
                                            isLastNameValid = validateName(name: last)
                                        }
                                    
                                }.padding(.horizontal, 17)
                                
                                HStack {
                                    Spacer()
                                    if !isFirstNameValid && first != "" && !isLastNameValid && last != ""{
                                        Text("Name should only contain alphabets")
                                            .font(.caption2)
                                            .foregroundColor(.red)
                                            .padding(.trailing, 35)
                                    } else {
                                        Text("Name should only contain alphabets")
                                            .font(.caption2)
                                            .foregroundColor(.white)
                                            .padding(.trailing, 15)
                                    }
                                }


                                CustomTextField(placeholder: "About", text: $about)
                                CustomTextField(placeholder: "Phone Number", text: $phoneNumber)
                                CustomTextField(placeholder: "Email", text: $email)
                                CustomSecureField(placeholder: "New Password", text: $newPassword)
                                CustomSecureField(placeholder: "Confirm Password", text: $confirmPassword)

                                CustomButton(label: "Register", action: {
                                    register()
                                    presentationMode.wrappedValue.dismiss()
                                })
                                .padding(.bottom, 20)
                                .alert(isPresented: $showAlert) {
                                    Alert(title: Text("Error"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
                                }

                                Button(action: {
                                    navigateToPendingEdu = true
                                }) {
                                    Text("Pending...")
                                }

                                NavigationLink(destination: PendingEducatorsView(), isActive: $navigateToPendingEdu) {
                                    EmptyView()
                                }
                            }
                        }
                        .padding(.horizontal)

                        Spacer()
                    }
                }
                .sheet(isPresented: $showImagePicker) {
                    ImagePicker(selectedImage: $selectedImage)
                }
                .navigationTitle("Create Account")
                .ignoresSafeArea(edges: .bottom)
            }
        }
    }

    func register() {
        guard newPassword == confirmPassword else {
            alertMessage = "Passwords do not match"
            showAlert = true
            return
        }

        isLoading = true

        if let image = selectedImage {
            uploadProfileImage(image: image) { url in
                guard let url = url else {
                    alertMessage = "Failed to upload profile image"
                    showAlert = true
                    isLoading = false
                    return
                }

                savePendingEducatorData(profileImageUrl: url.absoluteString)
            }
        } else {
            savePendingEducatorData(profileImageUrl: nil)
        }
    }

    func uploadProfileImage(image: UIImage, completion: @escaping (URL?) -> Void) {
        let storageRef = Storage.storage().reference().child("profile_images").child(UUID().uuidString + ".jpg")
        guard let imageData = image.jpegData(compressionQuality: 0.75) else {
            completion(nil)
            return
        }

        storageRef.putData(imageData, metadata: nil) { metadata, error in
            if let error = error {
                print("Error uploading image: \(error.localizedDescription)")
                completion(nil)
                return
            }

            storageRef.downloadURL { url, error in
                if let error = error {
                    print("Error getting download URL: \(error.localizedDescription)")
                    completion(nil)
                    return
                }

                completion(url)
            }
        }
    }

    func savePendingEducatorData(profileImageUrl: String?) {
        let educatorInfo: Educator = Educator(firstName: first, lastName: last, about: about, email: email, password: confirmPassword, phoneNumber: phoneNumber, profileImageURL: profileImageUrl ?? "")

        Firestore.firestore().collection("Pending-Educators").document(email).setData(educatorInfo.toDictionary()) { error in
            if let error = error {
                alertMessage = error.localizedDescription
                showAlert = true
            } else {
                alertMessage = "Registration request submitted successfully!"
                showAlert = true
            }
            isLoading = false
        }
    }
}

struct ImagePicker: UIViewControllerRepresentable {
    @Binding var selectedImage: UIImage?

    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        picker.sourceType = .photoLibrary
        return picker
    }

    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        let parent: ImagePicker

        init(_ parent: ImagePicker) {
            self.parent = parent
        }

        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
            if let image = info[.originalImage] as? UIImage {
                parent.selectedImage = image
            }
            picker.dismiss(animated: true, completion: nil)
        }
    }
}

struct CreateAccountView_Previews: PreviewProvider {
    static var previews: some View {
        CreateAccountView()
    }
}
