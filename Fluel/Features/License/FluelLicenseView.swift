import FluelLibrary
import LicenseList
import SwiftUI

struct FluelLicenseView: View {
    var body: some View {
        LicenseList.LicenseListView()
            .licenseViewStyle(.withRepositoryAnchorLink)
            .navigationTitle(FluelCopy.licenses())
            .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview(traits: .modifier(FluelSampleData())) {
    NavigationStack {
        FluelLicenseView()
    }
    .fluelAppStyle()
}
