//
//  AudioPlayerComponent.swift
//  VibeCodedComponents
    

import SwiftUI
import AVFoundation


struct AudioPlayerComponent: View {
    let audioURL: URL?
    let title: String
    
    @StateObject private var playerViewModel = AudioPlayerViewModel()
    @State private var isDragging: Bool = false
    @State private var dragProgress: CGFloat = 0.0
    
    private let waveformMaxHeight: CGFloat = 28
    private let containerHeight: CGFloat = 48
    private let cardBackgroundColor = Color(red: 0.93, green: 0.93, blue: 0.96)
    
    
    var body: some View {
        VStack(spacing: 14) {
            // MARK: Header
            HStack(spacing: 8) {
                Button(action: {
                    playerViewModel.playPause()
                }) {
                    Image(systemName: playerViewModel.isPlaying ? "pause.fill" : "play.fill")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(Color(white: 0.15))
                        .frame(width: 24, height: 24, alignment: .leading)
                        .contentShape(Rectangle())
                }
                
                Text(title)
                    .font(.system(size: 15, weight: .medium)) // Slightly lighter, matched to GIF
                    .foregroundColor(Color(white: 0.15))
                
                Spacer()
                
                // Duration Text
                Text("\(Int(isDragging ? dragProgress * playerViewModel.duration : playerViewModel.currentTime))s")
                    .font(.system(size: 15, weight: .regular))
                    .foregroundColor(Color(white: 0.15))
                    .monospacedDigit()
            }
            .padding(.horizontal, 4)
            
            // MARK: Waveform & Drag Area
            ZStack(alignment: .leading) {
                // White background container
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .fill(Color.white)
                    .frame(height: containerHeight)
                
                GeometryReader { geo in
                    let width = geo.size.width
                    let activeProgress = isDragging ? dragProgress : playerViewModel.progress
                    
                    ZStack(alignment: .leading) {
                        // 1. Inactive Waveform (Light Gray)
                        WaveformView(samples: playerViewModel.samples, maxHeight: waveformMaxHeight)
                            .foregroundColor(Color(white: 0.85)) // Much lighter grey to match GIF
                        
                        // 2. Active Waveform (Dark Gray, masked by progress)
                        WaveformView(samples: playerViewModel.samples, maxHeight: waveformMaxHeight)
                            .foregroundColor(Color(white: 0.5)) // Medium/Dark grey active state
                            .mask(alignment: .leading) {
                                Rectangle()
                                    .frame(width: max(0, width * activeProgress))
                            }
                        
                        // 3. Playhead Indicator
                        PlayheadIndicator(lineHeight: containerHeight) // +8 so the line drops below the white box
                            // Add the subtle drop shadow seen in the GIF
                            .shadow(color: Color.black.opacity(0.12), radius: 4, x: 0, y: 2)
                            // 44pt wide hit target
                            .frame(width: 44, height: containerHeight + 16)
                            .contentShape(Rectangle())
                            .offset(x: max(0, min(width * activeProgress, width)) - 22)
                            // Align vertically so the line sticks out the bottom properly
                            .offset(y: 2)
                            .gesture(
                                DragGesture(minimumDistance: 0)
                                    .onChanged { value in
                                        isDragging = true
                                        dragProgress = max(0, min(1, value.location.x / width))
                                    }
                                    .onEnded { _ in
                                        isDragging = false
                                        playerViewModel.seek(to: dragProgress)
                                    }
                            )
                    }
                }
                .frame(height: containerHeight)
            }
        }
        .padding(.horizontal, 16)
        .padding(.top, 16)
        .padding(.bottom, 16)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(cardBackgroundColor)
        )
        .frame(width: 320)
        .onAppear {
            playerViewModel.loadAudio(url: audioURL)
        }
        .onDisappear {
            playerViewModel.stop()
        }
        .sensoryFeedback(.selection, trigger: dragProgress)
    }
}

// MARK: - Playhead Indicator
fileprivate struct PlayheadIndicator: View {
    var lineHeight: CGFloat
    
    var body: some View {
        VStack(spacing: 0) {
            // The top handle (Wider, flatter shield shape)
            Path { path in
                let w: CGFloat = 14
                let h: CGFloat = 14
                
                path.move(to: CGPoint(x: 0, y: 0))
                path.addLine(to: CGPoint(x: w, y: 0))
                // Straight down for 60% of height
                path.addLine(to: CGPoint(x: w, y: h * 0.6))
                // Point to center bottom
                path.addLine(to: CGPoint(x: w * 0.5, y: h))
                // Back up to left side
                path.addLine(to: CGPoint(x: 0, y: h * 0.6))
                path.closeSubpath()
            }
            .fill(Color(white: 0.15))
            .frame(width: 14, height: 14)
            .offset(y: -4)
            
            // The vertical line (Extends below)
            Rectangle()
                .fill(Color(white: 0.15))
                .frame(width: 2, height: lineHeight)
        }
    }
}

// MARK: - Waveform View
fileprivate struct WaveformView: View {
    var samples: [CGFloat]
    var maxHeight: CGFloat
    
    var body: some View {
        HStack(alignment: .center, spacing: 2.5) { // Tighter spacing
            ForEach(Array(samples.enumerated()), id: \.offset) { index, amplitude in
                Capsule()
                    .frame(width: 2.5, height: max(4, min(amplitude * maxHeight, maxHeight)))
            }
        }
        .frame(maxWidth: .infinity, alignment: .center)
        // Adjust padding to sit nicely inside the white box
        .padding(.horizontal, 10)
    }
}

// MARK: - View Model (Playback & Analysis)
fileprivate class AudioPlayerViewModel: NSObject, ObservableObject, AVAudioPlayerDelegate {
    @Published var samples: [CGFloat] = []
    @Published var duration: TimeInterval = 0
    @Published var currentTime: TimeInterval = 0
    @Published var isPlaying: Bool = false
    
    var progress: CGFloat {
        guard duration > 0 else { return 0 }
        return CGFloat(currentTime / duration)
    }
    
    private var audioPlayer: AVAudioPlayer?
    private var displayLink: CADisplayLink?
    
    func loadAudio(url: URL?) {
        guard let url = url else {
            generateMockData()
            return
        }
        
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer?.delegate = self
            audioPlayer?.prepareToPlay()
            duration = audioPlayer?.duration ?? 0
            
            extractSamples(url: url)
        } catch {
            print("Failed to load audio: \(error)")
            generateMockData()
        }
    }
    
    func playPause() {
        guard let player = audioPlayer else {
            toggleMockPlayback()
            return
        }
        
        if player.isPlaying {
            player.pause()
            isPlaying = false
            stopDisplayLink()
        } else {
            player.play()
            isPlaying = true
            startDisplayLink()
        }
    }
    
    func seek(to progress: CGFloat) {
        let newTime = TimeInterval(progress) * duration
        currentTime = newTime
        audioPlayer?.currentTime = newTime
    }
    
    func stop() {
        audioPlayer?.stop()
        stopDisplayLink()
    }
    
    private func startDisplayLink() {
        displayLink = CADisplayLink(target: self, selector: #selector(updateTime))
        displayLink?.add(to: .main, forMode: .common)
    }
    
    private func stopDisplayLink() {
        displayLink?.invalidate()
        displayLink = nil
    }
    
    @objc private func updateTime() {
        guard let player = audioPlayer else {
            if isPlaying {
                currentTime += 1.0 / 60.0
                if currentTime >= duration {
                    currentTime = 0
                    isPlaying = false
                    stopDisplayLink()
                }
            }
            return
        }
        
        if player.isPlaying {
            currentTime = player.currentTime
        }
    }
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        isPlaying = false
        currentTime = 0
        stopDisplayLink()
    }
    
    private func extractSamples(url: URL) {
        DispatchQueue.global(qos: .userInitiated).async {
            do {
                let file = try AVAudioFile(forReading: url)
                let format = file.processingFormat
                let audioFrameCount = UInt32(file.length)
                
                guard let buffer = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: audioFrameCount) else { return }
                try file.read(into: buffer)
                
                guard let channelData = buffer.floatChannelData else { return }
                let channelDataValue = channelData.pointee
                let frameLength = Int(buffer.frameLength)
                
                let targetSamples = 55 // Increased density to match GIF
                let chunkSize = frameLength / targetSamples
                var processedSamples: [CGFloat] = []
                
                for i in 0..<targetSamples {
                    let start = i * chunkSize
                    let end = min(start + chunkSize, frameLength)
                    
                    var peak: Float = 0
                    for j in start..<end {
                        let amplitude = abs(channelDataValue[j])
                        if amplitude > peak {
                            peak = amplitude
                        }
                    }
                    processedSamples.append(CGFloat(peak))
                }
                
                let maxSample = processedSamples.max() ?? 1.0
                let normalizedSamples = processedSamples.map { $0 / (maxSample > 0 ? maxSample : 1.0) }
                
                DispatchQueue.main.async {
                    self.samples = normalizedSamples
                }
            } catch {
                print("Error extracting samples: \(error)")
            }
        }
    }
    
    private func generateMockData() {
        self.duration = 36.0
        self.samples = (0..<55).map { _ in CGFloat.random(in: 0.1...1.0) }
    }
    
    private func toggleMockPlayback() {
        isPlaying.toggle()
        if isPlaying {
            startDisplayLink()
        } else {
            stopDisplayLink()
        }
    }
}


struct AudioPlayerComponentPreview: View {
    let audioURL: URL? = Bundle.main.url(forResource: "sample-audio", withExtension: "mp3")
    var body: some View {
        AudioPlayerComponent(audioURL: audioURL, title: "Mom.mp3")
    }
}
