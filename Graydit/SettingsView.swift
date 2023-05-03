
import SwiftUI

struct SettingsView: View {
    @Binding var showAvatars: Bool

    var body: some View {
        Form {
            Toggle("Show Avatars", isOn: $showAvatars)
        }
        .navigationBarTitle("Settings")
    }
}
