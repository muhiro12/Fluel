import SwiftUI

struct FluelNoticeBannerModifier: ViewModifier {
    private enum Layout {
        static let horizontalPadding: CGFloat = 16
        static let topPadding: CGFloat = 8
        static let dismissDelaySeconds = 3.0
    }

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
                    .padding(.horizontal, Layout.horizontalPadding)
                    .padding(.top, Layout.topPadding)
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
