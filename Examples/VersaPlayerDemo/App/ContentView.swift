//
//  ContentView.swift
//  VersaPlayerDemo
//
//  Created by Jose Quintero on 10/28/26.
//

import SwiftUI
import VersaPlayer

private let sample = URL(string: "https://devstreaming-cdn.apple.com/videos/streaming/examples/img_bipbop_adv_example_fmp4/master.m3u8")!

struct ContentView: View {
    @State private var model = VersaPlayerModel()
    @State private var log: [String] = []
    @State private var isFullscreen = false
    @State private var customControls = false
    @State private var largeCaptions = false

    var body: some View {
        content
            .task {
                let events = model.events
                model.add(NowPlayingPlugin())
                model.load(VersaPlayerItem(url: sample, metadata: .init(title: "BipBop", subtitle: "Apple HLS sample")))
                for await event in events {
                    log.insert(String(describing: event), at: 0)
                    log = Array(log.prefix(30))
                }
            }
    }

    @ViewBuilder
    private var content: some View {
        #if os(tvOS)
        VersaVideoPlayer(model: model)
            .ignoresSafeArea()
        #else
        VStack(spacing: 0) {
            player
                .aspectRatio(16 / 9, contentMode: .fit)
            settings
        }
        #if os(iOS)
        .fullScreenCover(isPresented: $isFullscreen) {
            VersaVideoPlayer(model: model)
                .onFullscreenRequest(isFullscreen: true) { isFullscreen = false }
                .ignoresSafeArea()
        }
        #endif
        #endif
    }

    @ViewBuilder
    private var player: some View {
        if customControls {
            VersaVideoPlayer(model: model) { MinimalControls() }
        } else {
            VersaVideoPlayer(model: model)
                .onFullscreenRequest(isFullscreen: false) { isFullscreen = true }
        }
    }

    private var settings: some View {
        Form {
            Section {
                Toggle("Custom controls", isOn: $customControls)
                Toggle("Large yellow captions", isOn: $largeCaptions)
                    .onChange(of: largeCaptions) { _, enabled in
                        model.setCaptionStyle(enabled ? .largeYellow : nil)
                    }
            }
            Section("Status") {
                LabeledContent("Status", value: String(describing: model.status))
                LabeledContent("Tracks", value: "\(model.tracks(of: .audio).count) audio, \(model.tracks(of: .legible).count) subtitles")
            }
            Section("Events") {
                ForEach(Array(log.enumerated()), id: \.offset) { _, entry in
                    Text(entry).font(.caption.monospaced())
                }
            }
        }
        .formStyle(.grouped)
    }
}

private struct MinimalControls: View {
    var body: some View {
        VStack {
            Spacer()
            HStack(spacing: 12) {
                PlayPauseButton()
                Scrubber()
                TimeLabel(.remaining)
                    .font(.caption)
                TrackPicker(.legible)
            }
            .padding(12)
            .background(.ultraThinMaterial, in: .capsule)
            .padding()
        }
        .buttonStyle(.plain)
    }
}

private extension CaptionStyle {
    static var largeYellow: CaptionStyle {
        var style = CaptionStyle()
        style.foregroundColor = .init(red: 1, green: 0.85, blue: 0)
        style.relativeFontSize = 150
        style.edgeStyle = .dropShadow
        return style
    }
}

#Preview {
    ContentView()
}
