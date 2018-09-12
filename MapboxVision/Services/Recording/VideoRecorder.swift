//
//  VideoRecorder.swift
//  cv-assist-ios
//
//  Created by Alexander Pristavko on 1/9/18.
//  Copyright © 2018 Mapbox. All rights reserved.
//

import Foundation
import AVFoundation

enum VideoRecorderError: LocalizedError {
    case notRecording
    case notReadyForData
    case recordingFailed
}

final class VideoRecorder {
    private let assetWriterInput: AVAssetWriterInput
    private var currentAssetWriter: AVAssetWriter?
    private(set) var isRecording = false
    private let settings: VideoSettings
    private var startTime: CMTime?
    private var currentTime: CMTime?
    
    private let writerQueue = DispatchQueue(label: "com.mapbox.VideoRecorder")

    init(settings: VideoSettings) {
        self.settings = settings
        
        let outputSettings: [String : Any] = [
            AVVideoWidthKey: settings.width,
            AVVideoHeightKey: settings.height,
            AVVideoCodecKey: settings.codec,
            AVVideoCompressionPropertiesKey: [
                AVVideoAverageBitRateKey: settings.bitRate
            ]
        ]

        assetWriterInput = AVAssetWriterInput(mediaType: .video, outputSettings: outputSettings)
        assetWriterInput.expectsMediaDataInRealTime = true
    }
    
    func startRecording(to path: String) {
        writerQueue.async {
            let outputURL = URL(fileURLWithPath: path)
            let assetWriter: AVAssetWriter
            do {
                assetWriter = try AVAssetWriter(outputURL: outputURL, fileType: self.settings.fileType)
            } catch {
                assertionFailure(error.localizedDescription)
                return
            }
            
            assetWriter.add(self.assetWriterInput)
            
            self.currentAssetWriter = assetWriter
            self.isRecording = true
        }
    }
    
    func stopRecording(completion: (() -> Void)?) {
        writerQueue.async { [weak self] in
            let cleanup = {
                self?.isRecording = false
                self?.currentAssetWriter = nil
                self?.startTime = nil
                completion?()
            }
            guard let writer = self?.currentAssetWriter, writer.status == .writing else {
                cleanup()
                return
            }
            
            guard let `self` = self else { return }
            self.assetWriterInput.markAsFinished()
            if let currentTime = self.currentTime {
                writer.endSession(atSourceTime: currentTime)
            }
            writer.finishWriting(completionHandler: cleanup)
        }
    }

    func handleFrame(_ sampleBuffer: CMSampleBuffer, completion: @escaping ((Result<Float64, VideoRecorderError>) -> Void)) {
        writerQueue.async { [weak self] in
            guard let `self` = self else { return }
            
            guard self.isRecording, let writer = self.currentAssetWriter else {
                completion(.error(.notRecording))
                return
            }

            switch writer.status {
            case .unknown:
                let lastSampleTime = CMSampleBufferGetPresentationTimeStamp(sampleBuffer)
                writer.startWriting()
                writer.startSession(atSourceTime: lastSampleTime)
                self.startTime = lastSampleTime
                
                self.append(sampleBuffer, completion: completion)
            case .writing:
                self.append(sampleBuffer, completion: completion)
            case .cancelled, .completed:
                assertionFailure("New frames shouldn't be to handle after recorder is cancelled or completed.")
                fallthrough
            case .failed:
                completion(.error(.recordingFailed))
            }
        }
    }
    
    private func append(_ sampleBuffer: CMSampleBuffer, completion: @escaping ((Result<Float64, VideoRecorderError>) -> Void)) {
        guard self.assetWriterInput.isReadyForMoreMediaData else {
            completion(.error(.notReadyForData))
            return
        }
        self.assetWriterInput.append(sampleBuffer)
        
        self.currentTime = CMSampleBufferGetPresentationTimeStamp(sampleBuffer)
        
        guard let startTime = self.startTime else {
            assertionFailure("VideoRecorder: start up time should has been already stored")
            completion(.error(.recordingFailed))
            return
        }
        let currentTime = CMSampleBufferGetPresentationTimeStamp(sampleBuffer)
        completion(.value(currentTime.millis(since: startTime)))
    }
}

fileprivate extension CMTime {
    func millis(since: CMTime) -> Float64 {
        let passed = CMTimeSubtract(self, since)
        return CMTimeGetSeconds(passed) * 1000
    }
}