import SwiftUI

struct BackgroundImageView: View {
    var body: some View {
        Image("backGround")
            .resizable()
            .aspectRatio(contentMode: .fill)
            .clipped()
    }
}

#Preview {
    BackgroundImageView()
}