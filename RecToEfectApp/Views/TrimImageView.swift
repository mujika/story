import SwiftUI
// import RealmSwift // Removed - migrated to SwiftData

protocol ImageChangeDelegate: AnyObject {
    func imageChange()
}

struct TrimImageView: View {
    @State private var image: UIImage?
    @State private var zoomScale: CGFloat = 1.0
    @State private var offset: CGSize = .zero
    @Environment(\.presentationMode) var presentationMode
    
    weak var delegate: ImageChangeDelegate?
    
    var body: some View {
        ZStack {
            // Gradient background
            LinearGradient(
                colors: [
                    Color(red: 177/255, green: 23/255, blue: 23/255).opacity(0.7),
                    Color.black.opacity(0.8)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack {
                // Top button bar
                HStack {
                    // Cancel button
                    Button("cancel") {
                        dismissSelf()
                    }
                    .font(.system(size: 20))
                    .foregroundColor(Color(red: 239/255, green: 238/255, blue: 232/255).opacity(0.7))
                    .frame(width: UIScreen.main.bounds.width * 0.2, height: UIScreen.main.bounds.width * 0.2 * 0.5)
                    .background(Color(red: 5/255, green: 7/255, blue: 29/255).opacity(0.25))
                    .cornerRadius(8)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color(red: 239/255, green: 238/255, blue: 232/255).opacity(0.7), lineWidth: 1)
                    )
                    
                    Spacer()
                    
                    // Save button
                    Button("save") {
                        didTapConfirmButton()
                    }
                    .font(.system(size: 20))
                    .foregroundColor(Color(red: 239/255, green: 238/255, blue: 232/255).opacity(0.7))
                    .frame(width: UIScreen.main.bounds.width * 0.2, height: UIScreen.main.bounds.width * 0.2 * 0.5)
                    .background(Color(red: 5/255, green: 7/255, blue: 29/255).opacity(0.25))
                    .cornerRadius(8)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color(red: 239/255, green: 238/255, blue: 232/255).opacity(0.7), lineWidth: 1)
                    )
                }
                .padding(.horizontal, 25)
                .padding(.top, 50)
                
                // Image view with crop functionality
                if let image = image {
                    GeometryReader { geometry in
                        Image(uiImage: image)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .scaleEffect(zoomScale)
                            .offset(offset)
                            .gesture(
                                SimultaneousGesture(
                                    MagnificationGesture()
                                        .onChanged { value in
                                            zoomScale = value
                                        },
                                    DragGesture()
                                        .onChanged { value in
                                            offset = value.translation
                                        }
                                )
                            )
                    }
                } else {
                    Spacer()
                }
                
                // Skeleton parts overlay
                skeletonPartsOverlay()
            }
        }
        .background(Color.white)
    }
    
    private func skeletonPartsOverlay() -> some View {
        ZStack {
            // KurukuruView
            Circle()
                .fill(Color(red: 5/255, green: 7/255, blue: 29/255).opacity(0.25))
                .frame(width: 92, height: 92)
                .overlay(
                    Image("Kurukuru")
                        .resizable()
                        .frame(width: 70, height: 70)
                )
            
            // Play button
            Circle()
                .fill(Color(red: 5/255, green: 7/255, blue: 29/255).opacity(0.25))
                .frame(width: 80, height: 80)
                .overlay(
                    Image("StartButton")
                        .resizable()
                        .frame(width: 27, height: 27)
                )
            
            // Record button
            Circle()
                .fill(Color(red: 5/255, green: 7/255, blue: 29/255).opacity(0.25))
                .frame(width: 80, height: 80)
                .overlay(
                    Circle()
                        .fill(Color(red: 252/255, green: 33/255, blue: 79/255).opacity(0.6))
                        .frame(width: 58, height: 58)
                )
            
            // Background image button
            Button("BackgroundImage") {
                // Handle background image button action
            }
            .font(.system(size: 16))
            .foregroundColor(Color(red: 239/255, green: 238/255, blue: 232/255).opacity(0.7))
            .multilineTextAlignment(.center)
            .background(Color(red: 5/255, green: 7/255, blue: 29/255).opacity(0.25))
            .cornerRadius(8)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(Color(red: 239/255, green: 238/255, blue: 232/255).opacity(0.7), lineWidth: 1)
            )
            .allowsHitTesting(false)
        }
    }
    
    private func didTapConfirmButton() {
        guard let image = image else { return }
        
        // Create cropped image (simplified version)
        let croppedImage = image // In a real implementation, you'd apply the crop based on zoom and offset
        
        // Save image
        saveImage(image: croppedImage)
        
        delegate?.imageChange()
        presentationMode.wrappedValue.dismiss()
    }
    
    private func dismissSelf() {
        delegate?.imageChange()
        presentationMode.wrappedValue.dismiss()
    }
    
    func prepareView(image: UIImage) {
        self.image = image
    }
    
    private func saveImage(image: UIImage) {
        // Legacy Realm code removed - migrated to SwiftData
        // TODO: Implement SwiftData image saving if needed
        print("Image save functionality needs SwiftData implementation")
    }
}

#Preview {
    TrimImageView()
}