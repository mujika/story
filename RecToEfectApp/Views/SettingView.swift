import SwiftUI
// import RealmSwift // Removed - migrated to SwiftData

struct SettingView: View {
    @State private var backGroundImageView: UIImage?
    // Realm references removed - migrated to SwiftData
    // @State private var realm = try! Realm()
    // @State private var config = Realm.Configuration()
    
    var body: some View {
        ZStack {
            // Background Image
            if let backgroundImage = backGroundImageView {
                Image(uiImage: backgroundImage)
                    .resizable()
                    .scaledToFill()
                    .ignoresSafeArea()
            } else {
                Image("flower")
                    .resizable()
                    .scaledToFill()
                    .ignoresSafeArea()
            }
            
            // Filter overlay
            Color.black
                .opacity(0.7)
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Top view
                Rectangle()
                    .fill(Color(red: 35/255, green: 35/255, blue: 51/255))
                    .opacity(0.95)
                    .frame(height: 100)
                    .allowsHitTesting(false)
                
                // Select view (table view area)
                Rectangle()
                    .fill(Color(red: 5/255, green: 7/255, blue: 29/255))
                    .opacity(0.55)
                    .allowsHitTesting(false)
                
                Spacer()
            }
            
            VStack(alignment: .leading, spacing: 20) {
                Spacer()
                
                // Privacy Policy Button
                Button(action: pushButton) {
                    HStack {
                        Text("○ Plivacy policy")
                            .font(.system(size: 19))
                            .foregroundColor(.white)
                    }
                }
                .frame(width: 150, height: 50)
                .padding(.leading, 10)
                .padding(.bottom, 100)
                
                Spacer()
            }
        }
        .background(Color.blue)
        .onAppear {
            loadImage()
        }
    }
    
    private func pushButton() {
        guard let url = URL(string: "https://scrapbox.io/Pickout/Privacy_policy") else { return }
        if UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url)
        }
        print("プラポリ")
    }
    
    private func loadImage() {
        // Legacy Realm code removed - using default image
        // TODO: Implement SwiftData image loading if needed
        backGroundImageView = UIImage(named: "flower")
    }
}

#Preview {
    SettingView()
}