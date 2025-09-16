import SwiftUI
import AVKit

final class PlayerContainerView: UIView {
    override class var layerClass: AnyClass { AVPlayerLayer.self }
    var playerLayer: AVPlayerLayer { layer as! AVPlayerLayer }

    var player: AVQueuePlayer? {
        get { playerLayer.player as? AVQueuePlayer }
        set { playerLayer.player = newValue }
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        playerLayer.videoGravity = .resizeAspect   // or .resizeAspectFill if you want full-bleed
    }
}

struct LoopingVideoView: UIViewRepresentable {
    let player: AVQueuePlayer

    func makeUIView(context: Context) -> PlayerContainerView {
        let v = PlayerContainerView()
        v.player = player
        return v
    }

    func updateUIView(_ uiView: PlayerContainerView, context: Context) {
        uiView.player = player // keep it hooked if SwiftUI reuses the view
    }
}
