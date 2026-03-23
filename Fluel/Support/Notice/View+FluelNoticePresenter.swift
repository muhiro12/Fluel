import SwiftUI

extension View {
    func fluelNoticePresenter(
        _ noticeCenter: FluelNoticeCenter
    ) -> some View {
        modifier(
            FluelNoticeBannerModifier(
                noticeCenter: noticeCenter
            )
        )
    }
}
