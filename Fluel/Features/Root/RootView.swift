import MHPlatform
import SwiftUI

struct RootView: View {
    @Environment(MHAppRuntime.self) private var appRuntime
    @State private var isPresentingLicenses = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    VStack(alignment: .leading, spacing: 12) {
                        Text(FluelAppConfiguration.appName)
                            .font(.largeTitle.weight(.semibold))

                        Text(FluelAppConfiguration.concept)
                            .font(.title3)
                            .foregroundStyle(.secondary)
                    }

                    RootCard(
                        title: "Baseline",
                        message: baselineMessage,
                        detail: "MHPlatform is connected as the app runtime foundation."
                    )

                    RootCard(
                        title: "Next",
                        message: "This is the lightest baseline for building Fluel features.",
                        detail: "Core features, navigation flows, and domain models are still to come."
                    )

                    if appRuntime.configuration.showsLicenses {
                        Button("Open Licenses") {
                            isPresentingLicenses = true
                        }
                        .buttonStyle(.bordered)
                    }
                }
                .padding(24)
            }
            .background(Color(uiColor: .systemGroupedBackground))
            .navigationTitle(FluelAppConfiguration.appName)
            .navigationBarTitleDisplayMode(.inline)
        }
        .sheet(isPresented: $isPresentingLicenses) {
            NavigationStack {
                appRuntime.licensesView()
                    .navigationTitle("Licenses")
                    .navigationBarTitleDisplayMode(.inline)
            }
        }
    }

    private var baselineMessage: String {
        if appRuntime.hasStarted {
            return FluelAppConfiguration.baselineStatusMessage
        }

        return "Starting MHPlatform runtime"
    }
}

private struct RootCard: View {
    let title: String
    let message: String
    let detail: String

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title)
                .font(.headline)
                .foregroundStyle(.secondary)

            Text(message)
                .font(.title3.weight(.medium))

            Text(detail)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(20)
        .background(.background, in: RoundedRectangle(cornerRadius: 20, style: .continuous))
    }
}

#Preview {
    RootView()
        .environment(
            MHAppRuntime(
                configuration: FluelAppConfiguration.runtimeConfiguration
            )
        )
}
