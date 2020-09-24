// Copyright © 2020 Shawn James. All rights reserved.
// UIView+LivePreviews.swift

#if DEBUG

    import SwiftUI

    extension UIView {
        var livePreview: some View { LivePreview(view: self) }

        struct LivePreview<V: UIView>: UIViewRepresentable {
            let view: V

            func makeUIView(context: UIViewRepresentableContext<LivePreview<V>>) -> V {
                return view
            }

            func updateUIView(_ uiView: V, context: Context) {}
        }
    }

#endif

/// Use the snippet below at the bottom of files to get livePreviews in those files

//// MARK: - Live Previews
//
// #if DEBUG
//
// import SwiftUI
//
// struct <#FileName#>Preview: PreviewProvider {
//    static var previews: some View {
//        let viewController = <#FileName#>()
//
//        return viewController.view.livePreview.edgesIgnoringSafeArea(.all)
//    }
// }
//
// #endif
