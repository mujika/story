import SwiftUI

struct TutorialView: View {
    @State private var currentPage = 0
    @Environment(\.dismiss) private var dismiss
    
    let tutorialPages = [
        TutorialPage(
            title: "RecToEfectAppへようこそ",
            subtitle: "高品質録音とリアルタイムエフェクト",
            description: "録音しながらリアルタイムでエフェクトを聞くことができます。録音とエフェクト処理を同時に行う革新的なアプリです。",
            systemImage: "waveform.circle.fill",
            color: .blue
        ),
        TutorialPage(
            title: "リアルタイムエフェクト",
            subtitle: "録音中にエフェクトを体験",
            description: "リバーブやディレイエフェクトを録音中にリアルタイムで適用。エフェクトのかかった音声を確認しながら録音できます。",
            systemImage: "music.note.house.fill",
            color: .purple
        ),
        TutorialPage(
            title: "波形表示とトリミング",
            subtitle: "視覚的な音声編集",
            description: "録音中の音声レベルを波形で確認。録音後は直感的なインターフェースで音声のトリミングが可能です。",
            systemImage: "waveform.and.mic",
            color: .green
        ),
        TutorialPage(
            title: "音源管理",
            subtitle: "録音の整理と共有",
            description: "録音した音源は自動的に保存され、いつでも再生・編集・共有できます。高音質M4A形式で保存されます。",
            systemImage: "folder.circle.fill",
            color: .orange
        )
    ]
    
    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                colors: [Color.black.opacity(0.8), tutorialPages[currentPage].color.opacity(0.3)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack {
                // Skip button
                HStack {
                    Spacer()
                    Button("スキップ") {
                        dismiss()
                    }
                    .foregroundColor(.white.opacity(0.8))
                    .padding()
                }
                
                Spacer()
                
                // Tutorial content
                TabView(selection: $currentPage) {
                    ForEach(Array(tutorialPages.enumerated()), id: \.offset) { index, page in
                        TutorialPageView(page: page, isLastPage: index == tutorialPages.count - 1) {
                            dismiss()
                        }
                        .tag(index)
                    }
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                
                // Page indicator
                HStack(spacing: 8) {
                    ForEach(0..<tutorialPages.count, id: \.self) { index in
                        Circle()
                            .fill(index == currentPage ? Color.white : Color.white.opacity(0.3))
                            .frame(width: 8, height: 8)
                            .animation(.easeInOut, value: currentPage)
                    }
                }
                .padding(.bottom, 40)
            }
        }
    }
}

struct TutorialPage {
    let title: String
    let subtitle: String
    let description: String
    let systemImage: String
    let color: Color
}

struct TutorialPageView: View {
    let page: TutorialPage
    let isLastPage: Bool
    let onComplete: () -> Void
    
    var body: some View {
        VStack(spacing: 30) {
            // Icon
            Image(systemName: page.systemImage)
                .font(.system(size: 100))
                .foregroundColor(page.color)
                .shadow(color: page.color.opacity(0.3), radius: 10)
            
            // Content
            VStack(spacing: 15) {
                Text(page.title)
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                
                Text(page.subtitle)
                    .font(.title2)
                    .foregroundColor(page.color)
                    .multilineTextAlignment(.center)
                
                Text(page.description)
                    .font(.body)
                    .foregroundColor(.white.opacity(0.8))
                    .multilineTextAlignment(.center)
                    .lineLimit(nil)
                    .padding(.horizontal, 20)
            }
            
            // Action button (only on last page)
            if isLastPage {
                Button(action: onComplete) {
                    HStack {
                        Text("始める")
                            .font(.headline)
                        Image(systemName: "arrow.right")
                    }
                    .foregroundColor(.white)
                    .padding(.horizontal, 30)
                    .padding(.vertical, 15)
                    .background(page.color)
                    .cornerRadius(25)
                    .shadow(color: page.color.opacity(0.3), radius: 10)
                }
                .padding(.top, 20)
            }
        }
        .padding(.horizontal, 30)
    }
}

#Preview {
    TutorialView()
}