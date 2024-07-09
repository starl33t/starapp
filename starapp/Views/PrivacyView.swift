import SwiftUI

struct PrivacyView: View {
    var body: some View {
        ZStack {
            Color.starBlack.ignoresSafeArea()
            VStack(alignment: .leading) {
                TabView {
                    Text("""
                    **Privacy Policy**

                    Welcome to StarApp! Your privacy is important to us. This privacy policy explains how we collect, use, disclose, and protect your information when you use our fitness app.
                    """)
                    .padding()
                    
                    Text("""
                    **Information We Collect**

                    1. **Personal Information**: When you create an account, we collect personal details such as your name, email address, age, and gender.
                    2. **Health Data**: We collect health-related data such as your weight, height, fitness goals, and activity levels to provide personalized fitness recommendations.
                    3. **Location Data**: To enhance your fitness experience, we collect location data to track your routes, distances, and provide location-based services.
                    4. **Usage Data**: We collect information on how you use the app, including the features you interact with and the time spent on the app.
                    """)
                    .padding()
                    
                    Text("""
                    **How We Use Your Information**

                    1. **To Provide and Improve Our Services**: We use the collected data to offer personalized fitness plans, track your progress, and suggest improvements.
                    2. **To Communicate with You**: We use your information to send you notifications, updates, and promotional messages related to our services.
                    3. **For Analytics and Research**: We analyze the data to understand user behavior, improve our app, and conduct research on fitness trends.
                    4. **To Ensure Security**: We use your information to detect and prevent fraud, abuse, and other harmful activities.
                    """)
                    .padding()
                    
                    Text("""
                    **Sharing Your Information**

                    1. **With Third-Party Service Providers**: We share your information with third-party vendors who assist us in providing our services, such as cloud storage providers, analytics services, and customer support.
                    2. **For Legal Reasons**: We may disclose your information if required by law or to protect our rights, property, or safety, or the rights, property, or safety of others.
                    3. **With Your Consent**: We may share your information with third parties when we have your explicit consent to do so.
                    """)
                    .padding()
                    
                    Text("""
                    **Your Rights and Choices**

                    1. **Access and Update Your Information**: You can access and update your personal information through your account settings.
                    2. **Delete Your Account**: You can delete your account at any time. Upon deletion, your data will be removed from our active databases.
                    3. **Opt-Out of Communications**: You can opt-out of receiving promotional communications from us through the unsubscribe link in the emails or by adjusting your account settings.
                    4. **Control Location Data**: You can disable location tracking in your device settings, but this may limit the functionality of certain features of the app.
                    """)
                    .padding()
                    
                    Text("""
                    **Security of Your Information**

                    We implement industry-standard security measures to protect your information from unauthorized access, use, or disclosure. However, no data transmission over the internet or electronic storage is completely secure, so we cannot guarantee absolute security.
                    """)
                    .padding()
                    
                    Text("""
                    **Changes to This Privacy Policy**

                    We may update this privacy policy from time to time. We will notify you of any changes by posting the new policy on this page and updating the effective date. Your continued use of the app after the changes take effect will signify your acceptance of the revised policy.
                    """)
                    .padding()
                    
                    Text("""
                    **Contact Us**

                    If you have any questions or concerns about this privacy policy, please contact us at hi@starapp.com.
                    """)
                    .padding()
                }
                .foregroundStyle(.whiteOne)
                .tabViewStyle(PageTabViewStyle())
                .presentationDetents([.large])
            }
            .background(.starBlack)
        }
    }
}

#Preview {
    PrivacyView()
}
