//
//  AudioTrack.swift
//  RWFramework
//
//  Created by Taylor Snead on 7/17/18.
//  Copyright © 2018 Roundware. All rights reserved.
//

import Foundation

/// An AudioTrack has a set of parameters determining how its audio is played.
/// Assets are provided by the Playlist, so they must match any geometric parameters.
/// There can be an arbitrary number of audio tracks playing at once
/// When one needs an asset, it simply grabs the next available matching one from the Playlist.
class AudioTrack: NSObject, STKAudioPlayerDelegate {
    let playlist: Playlist
    let id: Int
    let volume: ClosedRange<Float>
    let duration: ClosedRange<Float>
    let deadAir: ClosedRange<Float>
    let fadeInTime: ClosedRange<Float>
    let fadeOutTime: ClosedRange<Float>
    let repeatRecordings: Bool
    private let player = STKAudioPlayer(options: {
        var opts = STKAudioPlayerOptions()
        opts.enableVolumeMixer = true
        return opts
    }())
    private var currentAsset: Asset? = nil
    private var fadeTimer: Timer? = nil
    
    init(
        playlist: Playlist,
        id: Int,
        volume: ClosedRange<Float>,
        duration: ClosedRange<Float>,
        deadAir: ClosedRange<Float>,
        fadeInTime: ClosedRange<Float>,
        fadeOutTime: ClosedRange<Float>,
        repeatRecordings: Bool
    ) {
        self.playlist = playlist
        self.id = id
        self.volume = volume
        self.duration = duration
        self.deadAir = deadAir
        self.fadeInTime = fadeInTime
        self.fadeOutTime = fadeOutTime
        self.repeatRecordings = repeatRecordings
    }
    
    
    static func fromJson(_ pl: Playlist, _ data: Data) throws -> [AudioTrack] {
        let json = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.mutableContainers)
        
        let items = json as! [AnyObject]
        return items.map { obj in
            let it = obj as! [String: AnyObject]
            return AudioTrack(
                playlist: pl,
                id: it["id"] as! Int,
                volume: (it["minvolume"] as! Float)...(it["maxvolume"] as! Float),
                duration: (it["minduration"] as! Float)...(it["maxduration"] as! Float),
                deadAir: (it["mindeadair"] as! Float)...(it["maxdeadair"] as! Float),
                fadeInTime: (it["minfadeintime"] as! NSNumber).floatValue...(it["maxfadeintime"] as! NSNumber).floatValue,
                fadeOutTime: (it["minfadeouttime"] as! NSNumber).floatValue...(it["maxfadeouttime"] as! NSNumber).floatValue,
                repeatRecordings: it["repeatrecordings"] as! Bool
            )
        }
    }
    
    
    func audioPlayer(_ audioPlayer: STKAudioPlayer, didStartPlayingQueueItemId queueItemId: NSObject) {
        
    }
    
    func audioPlayer(_ audioPlayer: STKAudioPlayer, didFinishBufferingSourceWithQueueItemId queueItemId: NSObject) {
        
    }
    
    func audioPlayer(_ audioPlayer: STKAudioPlayer, stateChanged state: STKAudioPlayerState, previousState: STKAudioPlayerState) {
        
    }
    
    func audioPlayer(_ audioPlayer: STKAudioPlayer, didFinishPlayingQueueItemId queueItemId: NSObject, with stopReason: STKAudioPlayerStopReason, andProgress progress: Double, andDuration duration: Double) {
        //        audioPlayer.play(playlist.next())
        playNext(premature: false)
    }
    
    func audioPlayer(_ audioPlayer: STKAudioPlayer, unexpectedError errorCode: STKAudioPlayerErrorCode) {
        
    }
    
    
    /// Plays the next optimal asset nearby.
    /// @arg premature True if skipping the current asset, rather than fading at the end of it.
    func playNext(premature: Bool = true) {
        // Stop any timer set to fade at the natural end of an asset
        fadeTimer?.invalidate()
        
        queueNext()
        let interval = 0.05 // seconds
        if #available(iOS 10.0, *) {
            fadeTimer = Timer.scheduledTimer(withTimeInterval: interval, repeats: true) { timer in
                if self.player.volume > 0.0 {
                    self.player.volume -= Float(interval) / self.fadeInTime.lowerBound
                } else {
                    self.player.volume = 0.0
                    self.fadeTimer?.invalidate()
                    self.fadeTimer = nil
                    self.fadeInNext(premature: premature)
                }
            }
        } else {
            // Fallback on earlier versions
        }
    }
    
    private func fadeInNext(premature: Bool) {
        if (player.pendingQueueCount > 0 || !premature) {
            player.playNext()
        }
        let interval = 0.05 // seconds
        if #available(iOS 10.0, *) {
            fadeTimer = Timer.scheduledTimer(withTimeInterval: interval, repeats: true) { timer in
                if self.player.volume < self.volume.upperBound {
                    self.player.volume += Float(interval) / self.fadeInTime.lowerBound
                } else {
                    self.player.volume = self.volume.upperBound
                    self.fadeTimer?.invalidate()
                    self.fadeTimer = Timer.scheduledTimer(
                        withTimeInterval: self.player.duration - Double(self.fadeInTime.lowerBound),
                        repeats: false
                    ) { timer in
                        self.playNext(premature: false)
                    }
                }
            }
        } else {
            // Fallback on earlier versions
        }
    }
    
    
    private func queueNext() {
        if let next = playlist.next() {
            player.queue(next.file)
            //            currentAsset = next
        }
    }
    
    func pause() {
        player.pause()
    }
    
    func resume() {
        player.resume()
    }
}
