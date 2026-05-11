import MHUI
import SwiftUI

struct FluelNoticeBannerModifier: ViewModifier {
    private enum Layout {
        static let dismissDelaySeconds = 3.0
    }

    @Environment(\.mhDesignMetrics)
    private var metrics

    let noticeCenter: FluelNoticeCenter

    func body(
        content: Content
    ) -> some View {
        content
            .safeAreaInset(edge: .top) {
                if let notice = noticeCenter.activeNotice {
                    let dismissNotice = {
                        noticeCenter.dismiss(id: notice.id)
                    }

                    FluelNoticeBanner(
                        notice: notice,
                        dismiss: dismissNotice
                    )
                    .padding(.horizontal, metrics.layout.screen.compactContentInsetHorizontal)
                    .padding(.top, metrics.spacing.inline)
                    .padding(.bottom, metrics.spacing.inline)
                    .task(id: notice.id) {
                        try? await Task.sleep(
                            for: .seconds(Layout.dismissDelaySeconds)
                        )
                        noticeCenter.dismiss(id: notice.id)
                    }
                }
            }
    }
}
