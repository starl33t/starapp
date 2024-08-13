import SwiftUI

struct LearnView: View {
    var body: some View {
        ZStack {
            Color.starBlack.ignoresSafeArea()
            VStack(alignment: .leading) {
                TabView {
                    Text("""
                    **What is Starleet?**
                    
                    Starleet was founded by a group of athletes in Denmark, inspired by recent advancements in sensor technology and the performance gains of athletes using lactate meters. We set out to create the world's first continuous lactate monitor, believing that AI-driven sensors will revolutionize health and performance.
                    """)
                    .padding()
                    
                    Text("""
                    **Why lactate?**
                    
                    Lactate is a proven biomarker for cellular stress, widely used by Norwegian cross-country skiers and gradually adopted by other sports. While lactate testing has been around for over 50 years, the full potential of its measurements remains untapped.
                    """)
                    .padding()
                    
                    Text("""
                    **What's in it for me?**
                    
                    Lactate is more than just a stress indicator. Elite athletes use it to reach peak performance, longevity enthusiasts use it to fine-tune activities, and medical professionals monitor patients with it. The versatility of lactate suggests there are many more insights to uncover.
                    """)
                    .padding()
                    
                    Text("""
                    **How can I use lactate?**
                    
                    The fastest way to use lactate is during exercise. Gauging your intensity with lactate is key to understanding how your body responds. Along with our AI, discovering a new you becomes a rewarding, life-changing journey. You may even find your own unique way to leverage lactate.
                    """)
                    .padding()
                }
                .foregroundStyle(.whiteOne)
                .tabViewStyle(PageTabViewStyle())
                .presentationDetents([.medium])
            }
        }
    }
}

