import SwiftUI

struct SettingView: View {
    @State private var selectedBackgroundImage = "flower"
    @State private var audioQuality: AudioQuality = .high
    @State private var showingImagePicker = false
    @State private var showingTermsSheet = false
    @Environment(\.dismiss) private var dismiss
    
    let backgroundImages = ["flower", "backGround", "Tutorial1"]
    
    var body: some View {
        NavigationView {
            ZStack {
                // Background
                BackgroundImageView()
                    .ignoresSafeArea()
                
                // Dark overlay
                Color.black.opacity(0.6)
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 25) {
                        // Header
                        VStack(spacing: 8) {
                            Text("設定")
                                .font(.largeTitle)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                            
                            Text("アプリの動作をカスタマイズ")
                                .font(.subheadline)
                                .foregroundColor(.white.opacity(0.8))
                        }
                        .padding(.top, 20)
                        
                        // Audio Quality Section
                        SettingSectionView(title: "音質設定", icon: "hifispeaker") {
                            VStack(spacing: 12) {
                                Text("録音品質")
                                    .font(.headline)
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                
                                ForEach(AudioQuality.allCases, id: \.self) { quality in
                                    Button(action: {
                                        audioQuality = quality
                                    }) {
                                        HStack {
                                            Image(systemName: audioQuality == quality ? "checkmark.circle.fill" : "circle")
                                                .foregroundColor(audioQuality == quality ? .blue : .gray)
                                            
                                            VStack(alignment: .leading, spacing: 2) {
                                                Text(quality.displayName)
                                                    .font(.body)
                                                    .foregroundColor(.white)
                                                
                                                Text(quality.description)
                                                    .font(.caption)
                                                    .foregroundColor(.white.opacity(0.7))
                                            }
                                            
                                            Spacer()
                                        }
                                        .padding(.vertical, 8)
                                    }
                                }
                            }
                        }
                        
                        // Background Settings Section
                        SettingSectionView(title: "背景設定", icon: "photo") {
                            VStack(spacing: 15) {
                                Text("背景画像")
                                    .font(.headline)
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                
                                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 3), spacing: 12) {
                                    ForEach(backgroundImages, id: \.self) { imageName in
                                        Button(action: {
                                            selectedBackgroundImage = imageName
                                        }) {
                                            ZStack {
                                                Image(imageName)
                                                    .resizable()
                                                    .aspectRatio(contentMode: .fill)
                                                    .frame(width: 80, height: 80)
                                                    .clipped()
                                                    .cornerRadius(12)
                                                
                                                if selectedBackgroundImage == imageName {
                                                    RoundedRectangle(cornerRadius: 12)
                                                        .stroke(Color.blue, lineWidth: 3)
                                                        .frame(width: 80, height: 80)
                                                    
                                                    Image(systemName: "checkmark.circle.fill")
                                                        .font(.title2)
                                                        .foregroundColor(.blue)
                                                        .background(Color.white.clipShape(Circle()))
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                        
                        // App Info Section
                        SettingSectionView(title: "アプリ情報", icon: "info.circle") {
                            VStack(spacing: 12) {
                                SettingsRowView(title: "プライバシーポリシー", icon: "hand.raised") {
                                    openPrivacyPolicy()
                                }
                                
                                SettingsRowView(title: "利用規約", icon: "doc.text") {
                                    showingTermsSheet = true
                                }
                                
                                SettingsRowView(title: "アプリについて", icon: "questionmark.circle") {
                                    // TODO: Add about page
                                }
                                
                                HStack {
                                    Image(systemName: "app.badge")
                                        .foregroundColor(.blue)
                                        .frame(width: 20)
                                    
                                    Text("バージョン")
                                        .foregroundColor(.white)
                                    
                                    Spacer()
                                    
                                    Text("2.0.0")
                                        .foregroundColor(.white.opacity(0.7))
                                        .font(.caption)
                                }
                                .padding(.vertical, 8)
                            }
                        }
                        
                        Spacer(minLength: 40)
                    }
                    .padding(.horizontal, 20)
                }
            }
            .navigationBarHidden(true)
            .sheet(isPresented: $showingTermsSheet) {
                TermsOfServiceView()
            }
        }
    }
    
    private func openPrivacyPolicy() {
        guard let url = URL(string: "https://scrapbox.io/Pickout/Privacy_policy") else { return }
        if UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url)
        }
    }
}

// MARK: - Supporting Types and Views

enum AudioQuality: String, CaseIterable {
    case low = "low"
    case medium = "medium"
    case high = "high"
    case lossless = "lossless"
    
    var displayName: String {
        switch self {
        case .low: return "低音質"
        case .medium: return "標準"
        case .high: return "高音質"
        case .lossless: return "ロスレス"
        }
    }
    
    var description: String {
        switch self {
        case .low: return "64 kbps - 容量を節約"
        case .medium: return "128 kbps - バランス重視"
        case .high: return "256 kbps - 推奨設定"
        case .lossless: return "44.1 kHz - 最高品質"
        }
    }
}

struct SettingSectionView<Content: View>: View {
    let title: String
    let icon: String
    let content: Content
    
    init(title: String, icon: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.icon = icon
        self.content = content()
    }
    
    var body: some View {
        VStack(spacing: 15) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(.blue)
                    .frame(width: 24, height: 24)
                
                Text(title)
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                
                Spacer()
            }
            
            content
        }
        .padding(20)
        .background(Color.white.opacity(0.1))
        .cornerRadius(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.white.opacity(0.2), lineWidth: 1)
        )
    }
}

struct SettingsRowView: View {
    let title: String
    let icon: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(.blue)
                    .frame(width: 20)
                
                Text(title)
                    .foregroundColor(.white)
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .foregroundColor(.white.opacity(0.5))
                    .font(.caption)
            }
            .padding(.vertical, 8)
        }
    }
}

struct TermsOfServiceView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    Text("""
                    利用規約
                    
                    最終更新日: 2025年6月17日
                    
                    1. サービスの提供
                    本アプリは音声録音およびエフェクト処理機能を提供します。
                    
                    2. ユーザーの責任
                    ユーザーは本アプリを適切に使用し、他者の権利を侵害しないものとします。
                    
                    3. プライバシー
                    録音データはユーザーのデバイス内にのみ保存され、外部に送信されることはありません。
                    
                    4. 免責事項
                    本アプリの使用により生じた損害について、開発者は責任を負いません。
                    
                    5. 規約の変更
                    本規約は予告なく変更される場合があります。
                    
                    6. お問い合わせ
                    ご質問等がございましたら、アプリ内のプライバシーポリシーページよりお問い合わせください。
                    """)
                    .font(.body)
                    .lineSpacing(4)
                }
                .padding()
            }
            .navigationTitle("利用規約")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar(content: {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("閉じる") {
                        dismiss()
                    }
                }
            })
        }
    }
}

#Preview {
    SettingView()
}