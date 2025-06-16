import SwiftUI

struct TutorialView: View {
    @State private var currentPage = 0
    @State private var navigateToMain = false
    
    var body: some View {
        NavigationStack {
            TabView(selection: $currentPage) {
                FirstTutorialView()
                    .tag(0)
                
                SecondTutorialView()
                    .tag(1)
                
                ThirdTutorialView(navigateToMain: $navigateToMain)
                    .tag(2)
            }
            .tabViewStyle(PageTabViewStyle())
            .indexViewStyle(PageIndexViewStyle(backgroundDisplayMode: .always))
            .navigationDestination(isPresented: $navigateToMain) {
                MainView()
            }
        }
    }
}

struct FirstTutorialView: View {
    var body: some View {
        ZStack {
            Image("Tutorial1")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .ignoresSafeArea()
        }
        .background(Color(UIColor.systemBackground))
    }
}

struct SecondTutorialView: View {
    var body: some View {
        ZStack {
            Image("tutorial2")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .ignoresSafeArea()
        }
        .background(Color(UIColor.systemBackground))
    }
}

struct ThirdTutorialView: View {
    @Binding var navigateToMain: Bool
    
    var body: some View {
        ZStack {
            Image("tutorial3")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .ignoresSafeArea()
            
            VStack {
                Spacer()
                
                Button("Enjoy a new experience!!") {
                    navigateToMain = true
                }
                .foregroundColor(.white)
                .frame(minWidth: 185, minHeight: 30)
                .background(Color.blue)
                .cornerRadius(5)
                .opacity(0.9)
                .padding(.bottom, 53)
            }
        }
        .background(Color(UIColor.systemBackground))
    }
}

#Preview {
    TutorialView()
}