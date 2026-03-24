//
//  SoundEffectPlayer.swift
//  VibeCodedComponents
    

import AVFoundation

final class SoundEffectPlayer {
    static let shared = SoundEffectPlayer()
    private init() {
        preload()
    }

    private var players: [TrackType: AVAudioPlayer] = [:]

    func play(_ track: TrackType) {
        players[track]?.play()
    }

    private func preload() {
        for track in TrackType.allCases {
            guard let url = Bundle.main.url(forResource: track.name, withExtension: "wav"),
                  let player = try? AVAudioPlayer(contentsOf: url) else { continue }

            player.prepareToPlay()
            players[track] = player
        }
    }

    enum TrackType: CaseIterable, Hashable {
        static var allCases: [SoundEffectPlayer.TrackType] {
            [.success, .warning, .error, .tick, .buttonTap, .drop, .startup, .custom("crisp_tick")]
        }
        
        case success
        case warning
        case error
        case tick
        case buttonTap
        case drop
        case startup
        case custom(String)
        
        var name: String {
            switch self {
            case .success: return "soft_success"
            case .warning: return "minimal_warning"
            case .error: return "minimal_error"
            case .tick: return "minimal_tick"
            case .buttonTap: return "crisp_tick"
            case .drop: return "minimal_drop"
            case .startup: return "soft_startup"
            case .custom(let name): return name
            }
        }
    }
}


enum Sound {
    static func play(_ track: SoundEffectPlayer.TrackType) {
        SoundEffectPlayer.shared.play(track)
    }
}
