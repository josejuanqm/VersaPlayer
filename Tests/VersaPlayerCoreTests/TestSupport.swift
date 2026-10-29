//
//  TestSupport.swift
//  VersaPlayer
//
//  Created by Jose Quintero on 10/28/26.
//

import AVFoundation
import CoreVideo
import Testing

enum TestClip {
    static func url(seconds: Int = 2) async throws -> URL {
        let url = FileManager.default.temporaryDirectory.appendingPathComponent("versaplayer-test-\(seconds)s.mov")
        if FileManager.default.fileExists(atPath: url.path) { return url }
        try await write(to: url, seconds: seconds)
        return url
    }

    private static func write(to url: URL, seconds: Int) async throws {
        let tempURL = url.deletingLastPathComponent().appendingPathComponent(UUID().uuidString + ".mov")
        let writer = try AVAssetWriter(outputURL: tempURL, fileType: .mov)
        let size = 64
        let input = AVAssetWriterInput(mediaType: .video, outputSettings: [
            AVVideoCodecKey: AVVideoCodecType.h264,
            AVVideoWidthKey: size,
            AVVideoHeightKey: size,
        ])
        input.expectsMediaDataInRealTime = false
        let adaptor = AVAssetWriterInputPixelBufferAdaptor(assetWriterInput: input, sourcePixelBufferAttributes: [
            kCVPixelBufferPixelFormatTypeKey as String: kCVPixelFormatType_32BGRA,
            kCVPixelBufferWidthKey as String: size,
            kCVPixelBufferHeightKey as String: size,
        ])
        writer.add(input)
        writer.startWriting()
        writer.startSession(atSourceTime: .zero)

        let fps: Int32 = 10
        for frame in 0..<(seconds * Int(fps)) {
            while !input.isReadyForMoreMediaData { try await Task.sleep(for: .milliseconds(5)) }
            var buffer: CVPixelBuffer?
            CVPixelBufferPoolCreatePixelBuffer(nil, adaptor.pixelBufferPool!, &buffer)
            let pixelBuffer = try #require(buffer)
            CVPixelBufferLockBaseAddress(pixelBuffer, [])
            memset(CVPixelBufferGetBaseAddress(pixelBuffer), Int32(frame * 10 % 255), CVPixelBufferGetDataSize(pixelBuffer))
            CVPixelBufferUnlockBaseAddress(pixelBuffer, [])
            adaptor.append(pixelBuffer, withPresentationTime: CMTime(value: CMTimeValue(frame), timescale: fps))
        }
        input.markAsFinished()
        await writer.finishWriting()
        if writer.status != .completed { throw writer.error ?? CocoaError(.fileWriteUnknown) }
        try? FileManager.default.moveItem(at: tempURL, to: url)
    }
}

struct TimeoutError: Error {}

@MainActor
func waitUntil(timeout: Duration = .seconds(10), _ condition: () -> Bool) async throws {
    let clock = ContinuousClock()
    let deadline = clock.now + timeout
    while !condition() {
        if clock.now > deadline { throw TimeoutError() }
        try await Task.sleep(for: .milliseconds(20))
    }
}

@MainActor
final class EventRecorder<Event: Sendable> {
    private(set) var events: [Event] = []
    private var task: Task<Void, Never>?

    init(_ stream: AsyncStream<Event>) {
        task = Task { [weak self] in
            for await event in stream { self?.events.append(event) }
        }
    }

    deinit { task?.cancel() }
}
