import SwiftUI
struct NotificationView: View {
    @State private var check = false
    @State private var selectedSegment = 0
    @ObservedObject var firebaseFetch = FirebaseFetch()
    @Environment(\.colorScheme) var colorScheme
    
    private let segments = ["Updates", "Educators"]
    
    var body: some View {
        
        
        
        VStack {
            Picker("Select Segment", selection: $selectedSegment) {
                ForEach(0..<segments.count) { index in
                    Text(segments[index])
                        .tag(index)
                }
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding()
            
            if selectedSegment == 0 {
                ScrollView {
                    VStack(spacing: 10) {
                        ForEach(firebaseFetch.courses.filter { $0.state == "completed" }) { course in
                            UpdateCardView(course: course)
                        }

                        .background(Color("color 3"))
                        .cornerRadius(12)
                        .shadow(color: .black.opacity(0.08), radius: 10, x: 0, y: 5)
                        .padding(10)
                        .onAppear(){
                            firebaseFetch.fetchCourses()
                        }
                        
                    }
                }.padding(10)
            } else if selectedSegment == 1 {
                
                
                GeometryReader { geometry in
                    ScrollView{
                        VStack(spacing: 5){
                            if firebaseFetch.pendingEducators.isEmpty {
                                Text("No Educators")
                                    .font(.title)
                                    .fontWeight(.bold)
                                    .foregroundColor(Color(.black))
                                    .opacity(0)
                                    .position(x: geometry.size.width / 2, y: geometry.size.height * 0.4)
                            } else {
                                
                                ForEach(firebaseFetch.pendingEducators) { educator in
                                    EducatorCardView(educator: educator)
                                }
                                .background(Color("color 3"))
                                .cornerRadius(12)
                                .shadow(color: .black.opacity(0.08), radius: 10, x: 0, y: 5)
                                .padding(10)
                                .onAppear(){
                                    print(firebaseFetch.fetchPendingEducators)
                                }
                                
                            }
                        }
                    }
                }.padding(10)
            }
        
    }
        .onAppear {
            firebaseFetch.fetchPendingEducators()
            firebaseFetch.fetchCourses()
        }
        .navigationTitle("Notifications")
        .navigationBarTitleDisplayMode(.inline)
    
    
    
}

    }

#Preview {
    NotificationView()
}
    
struct EducatorCardView: View {
    @Environment(\.colorScheme) var colorScheme

    var educator : Educator
    var body: some View {
        NavigationLink(destination: EducatorAccept(educator: educator)) {
            HStack(spacing: 10){
                ProfileCircleImage(imageURL: educator.profileImageURL, width: 60, height: 60)
                VStack(alignment: .leading){
                    Text(educator.fullName)
                        .font(.custom("Poppins-Medium", size: 18))                        
                        .foregroundColor(colorScheme == .dark ? .white : .black)

                    Text(educator.about)
                        .lineLimit(2)
                        .font(.custom("Poppins-Regular", size: 16))
                        .foregroundColor(.secondary)
                }
                Spacer()
                Image(systemName: "chevron.right")
                    .foregroundColor(colorScheme == .dark ? .white : .black)
            }
            .padding(10)
            
        }
    }
}

struct UpdateCardView: View {
    var course : Course
    var body: some View {
        NavigationLink(destination: PublishCourse(course: course)){
            
        HStack(spacing: 10){
            CoursethumbnailImage(imageURL: course.courseImageURL, width: 100, height: 80)
            VStack(alignment: .leading){
                Text(course.courseName)
                    .font(.custom("Poppins-Medium", size: 18))
                Text(course.assignedEducator.firstName + " " + course.assignedEducator.lastName)
                    .lineLimit(2)
                    .font(.custom("Poppins-Regular", size: 16))
                    .foregroundColor(.secondary)
            }
            Spacer()
            Image(systemName: "chevron.right")
                .foregroundColor(.black)
        }
        .padding(10)
       
    }
        
    }
        
}

