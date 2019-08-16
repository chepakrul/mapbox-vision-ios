import Foundation
import MapboxVisionNative

private let visionVideoSettings: VideoSettings = .lowQuality

struct BaseDependencies {
    let native: VisionManagerBaseNativeProtocol
}

struct VisionDependencies {
    let native: VisionManagerNativeProtocol
    let synchronizer: Synchronizable
    let recorder: SessionRecorderProtocol
    let dataProvider: DataProvider
    let deviceInfo: DeviceInfoProvidable

    static func `default`() -> VisionDependencies {
        guard let reachability = Reachability() else {
            fatalError("Reachability failed to initialize")
        }

        let eventsManager = EventsManager()
        let deviceInfo = DeviceInfoProvider()

        let recordArchiver = RecordArchiver()
        let recordSyncDependencies = RecordSynchronizer.Dependencies(
            networkClient: eventsManager,
            deviceInfo: deviceInfo,
            archiver: recordArchiver,
            fileManager: FileManager.default
        )
        let recordSynchronizer = RecordSynchronizer(recordSyncDependencies)

        let syncDependencies = ManagedSynchronizer.Dependencies(
            base: recordSynchronizer,
            reachability: reachability
        )
        let synchronizer = ManagedSynchronizer(dependencies: syncDependencies)

        let recordCoordinator = RecordCoordinator()

        let platform = Platform(dependencies: Platform.Dependencies(
            recordCoordinator: recordCoordinator,
            eventsManager: eventsManager
        ))

        let native = VisionManagerNative.create(withPlatform: platform)

        let recorder = SessionRecorder(dependencies: SessionRecorder.Dependencies(
            recorder: recordCoordinator,
            sessionManager: SessionManager(),
            videoSettings: visionVideoSettings,
            getSeconds: native.getSeconds,
            startSavingSession: native.startSavingSession,
            stopSavingSession: native.stopSavingSession
        ))

        let dataProvider = RealtimeDataProvider(dependencies: RealtimeDataProvider.Dependencies(
            native: native,
            motionManager: MotionManager(),
            locationManager: LocationManager()
        ))

        return VisionDependencies(native: native,
                                  synchronizer: synchronizer,
                                  recorder: recorder,
                                  dataProvider: dataProvider,
                                  deviceInfo: deviceInfo)
    }
}

struct ReplayDependencies {
    let native: VisionReplayManagerNative
    let player: VideoPlayable

    static func `default`(recordPath: String) throws -> ReplayDependencies {
        guard let videoPath = RecordingPath(existing: recordPath, settings: .lowQuality)?.videoPath else {
            throw CocoaError(.fileNoSuchFile)
        }
        let player = try VideoPlayer(path: videoPath)

        let eventsManager = EventsManager()

        let platform = Platform(dependencies: Platform.Dependencies(
            recordCoordinator: nil,
            eventsManager: eventsManager
        ))

        let native = VisionReplayManagerNative.create(withPlatform: platform, recordPath: recordPath)

        return ReplayDependencies(native: native, player: player)
    }
}
