//  Created by Dominik Hauser on 14.05.23.
//  Copyright © 2023 dasdom. All rights reserved.
//


import AVFoundation
import Foundation

// The maximum number of audio buffers in flight. Setting to two allows one
// buffer to be played while the next is being written.
private let kInFlightAudioBuffers: Int = 2

// The number of audio samples per buffer. A lower value reduces latency for
// changes but requires more processing but increases the risk of being unable
// to fill the buffers in time. A setting of 1024 represents about 23ms of
// samples.
private let kSamplesPerBuffer: AVAudioFrameCount = 1024

// The single FM synthesizer instance.
public class Synth {

  // The audio engine manages the sound system.
  private let engine: AVAudioEngine = AVAudioEngine()

  // The player node schedules the playback of the audio buffers.
  private let playerNode: AVAudioPlayerNode = AVAudioPlayerNode()

  // Use standard non-interleaved PCM audio.
  let audioFormat = AVAudioFormat(standardFormatWithSampleRate: 44100.0, channels: 2)

  // A circular queue of audio buffers.
  private var audioBuffers: [AVAudioPCMBuffer] = [AVAudioPCMBuffer]()

  // The index of the next buffer to fill.
  private var bufferIndex: Int = 0

  // The dispatch queue to render audio samples.
  private let audioQueue: DispatchQueue = DispatchQueue(label: "FMSynthesizerQueue", qos: .background)

  // A semaphore to gate the number of buffers processed.
  private let audioSemaphore: DispatchSemaphore = DispatchSemaphore(value: kInFlightAudioBuffers)

  static let shared = Synth()

  init() {
    // Create a pool of audio buffers.
    for _ in 0..<kInFlightAudioBuffers {
      if let audioFormat = audioFormat,
         let audioBuffer = AVAudioPCMBuffer(pcmFormat: audioFormat, frameCapacity: kSamplesPerBuffer) {
        audioBuffers.append(audioBuffer)
      }

      // Attach and connect the player node.
      engine.attach(playerNode)
      engine.connect(playerNode, to: engine.mainMixerNode, format: audioFormat)

      do {
        try engine.start()
      } catch {
        NSLog("Error starting audio engine: \(error)")
      }

      NotificationCenter.default.addObserver(self, selector: Selector(("audioEngineConfigurationChange:")), name: NSNotification.Name.AVAudioEngineConfigurationChange, object: engine)
    }
  }

  func play(carrierFrequency: Float32, modulatorFrequency: Float32, modulatorAmplitude: Float32) {
    guard let audioFormat = audioFormat else {
      return
    }
    let unitVelocity = Float32(2.0 * Double.pi / audioFormat.sampleRate)
    let carrierVelocity = carrierFrequency * unitVelocity
    let modulatorVelocity = modulatorFrequency * unitVelocity
    audioQueue.async {
      var sampleTime: Float32 = 0
      while true {
        // Wait for a buffer to become available.
        self.audioSemaphore.wait()

        // Fill the buffer with new samples.
        let audioBuffer = self.audioBuffers[self.bufferIndex]
        guard let leftChannel = audioBuffer.floatChannelData?[0],
              let rightChannel = audioBuffer.floatChannelData?[1] else {
          return
        }
        for sampleIndex in 0..<Int(kSamplesPerBuffer) {
          let sample = sin(carrierVelocity * sampleTime + modulatorAmplitude * sin(modulatorVelocity * sampleTime))
          leftChannel[sampleIndex] = sample
          rightChannel[sampleIndex] = sample
          sampleTime += 1
        }
        audioBuffer.frameLength = kSamplesPerBuffer

        // Schedule the buffer for playback and release it for reuse after
        // playback has finished.
        self.playerNode.scheduleBuffer(audioBuffer) {
          self.audioSemaphore.signal()
          return
        }

        self.bufferIndex = (self.bufferIndex + 1) % self.audioBuffers.count
      }
    }

    playerNode.pan = 0.8
    playerNode.play()
  }

  func audioEngineConfigurationChange(notification: NSNotification) -> Void {
    NSLog("Audio engine configuration change: \(notification)")
  }

}
