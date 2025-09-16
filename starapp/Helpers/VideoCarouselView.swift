import SwiftUI
import AVKit

struct TutorialStep {
    let title: String
    let subtitle: String
    let videoName: String
}

struct VideoCarouselView: View {
    let steps: [TutorialStep]
    @State private var page = 0
    @State private var players: [AVQueuePlayer] = []
    @State private var loopers: [AVPlayerLooper] = []

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            if !players.isEmpty {
                TabView(selection: $page) {
                    ForEach(steps.indices, id: \.self) { i in
                        VStack(spacing: 16) {
                            ZStack(alignment: .top) {
                                // Video
                                LoopingVideoView(player: players[i])
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 360) // <- explicit height prevents "snip"
                                    .clipShape(RoundedRectangle(cornerRadius: 16))
                                    .overlay(
                                        LinearGradient(
                                            colors: [.clear, .black.opacity(0.35)],
                                            startPoint: .center, endPoint: .bottom
                                        )
                                        .clipShape(RoundedRectangle(cornerRadius: 16))
                                    )

                                // Title overlay
                                Text(steps[i].title)
                                    .font(.title2.bold())
                                    .foregroundStyle(.white)
                                    .shadow(radius: 4)
                                    .padding(.top, 10)
                            }

                            // Subtitle under the video
                            Text(steps[i].subtitle)
                                .font(.body)
                                .foregroundStyle(.gray)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 24)

                            Spacer()
                        }
                        .tag(i)
                        .padding(.top, 32)
                        .padding(.horizontal, 16)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .automatic))
            }
        }
        .onAppear {
            setupPlayersIfNeeded()
            playOnly(index: 0)
        }
        .onChange(of: page) { _, newValue in
            playOnly(index: newValue)
        }
        .onDisappear {
            teardownPlayers()
        }
    }

    private func setupPlayersIfNeeded() {
        guard players.isEmpty else { return }
        for step in steps {
            guard let url = Bundle.main.url(forResource: step.videoName, withExtension: "mp4") else { continue }

            let item = AVPlayerItem(url: url)
            // local files: no need for big buffers; still, keep stalling minimal
            item.preferredForwardBufferDuration = 0

            let player = AVQueuePlayer()
            player.isMuted = true
            player.automaticallyWaitsToMinimizeStalling = false
            player.actionAtItemEnd = .none

            let looper = AVPlayerLooper(player: player, templateItem: item)

            players.append(player)
            loopers.append(looper)
        }
    }

    private func playOnly(index i: Int) {
        for (idx, p) in players.enumerated() {
            if idx == i {
                // make sure it’s at start and running
                p.seek(to: .zero, toleranceBefore: .zero, toleranceAfter: .zero)
                p.play()
            } else {
                p.pause()
                p.seek(to: .zero, toleranceBefore: .zero, toleranceAfter: .zero)
            }
        }
    }

    private func teardownPlayers() {
        // Fully release decoders so reopen is clean
        for p in players {
            p.pause()
            p.removeAllItems()
            // break any residual references
            p.replaceCurrentItem(with: nil)
        }
        players.removeAll()
        loopers.removeAll()
    }
}
