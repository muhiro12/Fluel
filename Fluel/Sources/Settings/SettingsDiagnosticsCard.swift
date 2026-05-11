import MHUI
import SwiftUI

struct SettingsDiagnosticsCard: View {
    @Environment(\.mhDesignMetrics)
    private var metrics
    @Environment(FluelDebugSettingsStore.self)
    private var debugSettings

    var body: some View {
        VStack(alignment: .leading, spacing: metrics.spacing.inline) {
            Text(FluelCopy.diagnostics())
                .mhTextStyle(.sectionTitle)

            Toggle(
                FluelCopy.enableDiagnosticsMode(),
                isOn: diagnosticsModeBinding
            )

            Text(diagnosticsSummary)
                .mhRowSupporting()

            if debugSettings.isDiagnosticsEnabled {
                NavigationLink {
                    FluelDiagnosticsView()
                } label: {
                    VStack(
                        alignment: .leading,
                        spacing: metrics.spacing.inline
                    ) {
                        Text(FluelCopy.openDiagnosticsConsole())
                            .mhRowTitle()

                        Text(FluelCopy.openDiagnosticsConsoleSummary())
                            .mhRowSupporting()
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
                .buttonStyle(.plain)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .mhSurfaceInset()
        .mhSurface(role: .muted)
    }
}

private extension SettingsDiagnosticsCard {
    var diagnosticsModeBinding: Binding<Bool> {
        .init(
            get: {
                debugSettings.isDiagnosticsEnabled
            },
            set: { newValue in
                debugSettings.isDiagnosticsEnabled = newValue
            }
        )
    }

    var diagnosticsSummary: String {
        if debugSettings.isDiagnosticsEnabled {
            return FluelCopy.diagnosticsEnabledSummary()
        }

        return FluelCopy.diagnosticsDisabledSummary()
    }
}
