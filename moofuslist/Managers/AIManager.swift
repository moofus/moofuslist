//
//  AIManager.swift
//  Moofuslist
//
//  Created by Lamar Williams III on 12/31/25.
//

import CoreLocation
import Foundation
import FoundationModels
import MapKit
import os

actor AIManager {
  enum Error: LocalizedError {
    case appleIntelligenceNotEnabled
    case deviceNotEligible
    case exceededContextWindowSize
    case guardrailViolation
    case location
    case model(String)
    case modelNotReady
    case unknown(String)

    var failureReason: String? {
      switch self {
      case .appleIntelligenceNotEnabled: "Apple Intelligence is not enabled in Settings."
      case .deviceNotEligible: "Apple Intelligence is not available on this device."
      case .exceededContextWindowSize: "Context Windows Length of 4096 tokens has been exceeded."
      case .guardrailViolation: "Content in the prompt or the response is bad."
      case .location: "Moofuslist can't access your location. Do you have Parental Controls enabled?"
      case .model(let errorString): "Apple Intelligence is unavailable: \(errorString)"
      case .modelNotReady: "Apple Intelligence is not ready."
      case .unknown(let errorString): errorString
      }
    }

    var errorDescription: String? {
      "Can't get location."
    }

    var recoverySuggestion: String? {
      switch self {
      case .appleIntelligenceNotEnabled: "Apple Intelligence is not enabled in Settings."
      case .deviceNotEligible: "Apple Intelligence is not available on this device."
      case .exceededContextWindowSize: "Create a new session."
      case .guardrailViolation: "Use a different prompt"
      case .location: "Moofuslist can't access your location. Do you have Parental Controls enabled?"
      case .model: "Apple Intelligence is unavailable"
      case .modelNotReady: "Apple Intelligence is not ready, try again later."
      case .unknown(let errorString): errorString
      }
    }
  }

  enum Message {
    case begin
    case end
    case error(LocalizedError)
    case loading([Activity])
  }

  @Generable(description: "A container for a list of activities")
  struct Activities {
    @Guide(description: "A list of activities to do", .count(6...10))
    let activities: [Activity]
  }

  @Generable(description: "A single activity to do")
  struct Activity: Hashable {
    @Guide(description: "Name for this item")
    let name: String
    @Guide(description: "Address for this item")
    let address: String
    @Guide(description: "City for this item")
    let city: String
    @Guide(description: "State for this item")
    let state: String
    @Guide(description: "The category for this item")
    let category: String
    @Guide(description: "The rating for this item")
    let rating: Double
    @Guide(description: "The number of reviews for the rating for this item")
    let reviews: Int
    @Guide(description: "The distance in miles")
    let distance: Double
    @Guide(description: "The phone number for this item")
    let phoneNumber: String
    @Guide(description: "A short description about of this place")
    let description: String
    @Guide(description: "Something interesting about this place")
    let somethingInteresting: String

    func lowercased() -> Activity {
      return Activity(
        name: name,
        address: address,
        city: city,
        state: state,
        category: category.lowercased(),
        rating: rating,
        reviews: reviews,
        distance: distance,
        phoneNumber: phoneNumber,
        description: description,
        somethingInteresting: somethingInteresting
      )
    }
  }

  let logger = Logger(subsystem: "com.moofus.moofuslist", category: "AIManager")

  let instructions =
  """
  Your job is to find activities to do and places to go.
  Always include a short description, and something interesting about the activity or place.
  Include a rating and the number of reviews for the rating.
  Include the phone number.
  """
  let continuation: AsyncStream<Message>.Continuation
  let stream: AsyncStream<Message>

  init() {
    (stream, continuation) = AsyncStream<Message>.makeStream()
  }
}

// MARK: - Public Methods
extension AIManager {
  func findActivities(cityState: String) async throws {
    try isModelAvailable()

    let newInstructions = instructions + "\n Always include the distance to \(cityState)"
    let session = LanguageModelSession(instructions: newInstructions)
    let text = "Generate a list of things to do near \(cityState)"
    do {
      let stream = session.streamResponse(to: text, generating: Activities.self)
      var beginSent = false

      for try await partial in stream {
        var activities = [Activity]()
        if let partialActivies = partial.content.activities {
          for idx in 0..<partialActivies.count {
            if let activity = partialToFull(activity: partialActivies[idx]) {
              activities.append(activity)
            }
          }
        }
        if !beginSent {
          continuation.yield(.begin)
          beginSent = true
        }
        if !activities.isEmpty {
          continuation.yield(.loading(activities))
        }
      }
      continuation.yield(.end)
    } catch LanguageModelSession.GenerationError.guardrailViolation(let error) {
      print("guardrailViolation Error")
      print(error)
      assertionFailure()
      continuation.yield(.error(Error.guardrailViolation))
    } catch LanguageModelSession.GenerationError.exceededContextWindowSize(let error) {
      print("exceededContextWindowSize Error")
      print(error)
      assertionFailure()
      continuation.yield(.error(Error.exceededContextWindowSize))
    } catch {
      print("Error")
      print(error.localizedDescription)
      continuation.yield(.error(Error.unknown(error.localizedDescription)))
    }
  }
}

// MARK: - Private Methods
extension AIManager {
  private func partialToFull(activity: Activity.PartiallyGenerated) -> Activity? {
    guard let name = activity.name?.lowercased() ?? activity.name,
          let address = activity.address,
          let city = activity.city,
          let state = activity.state,
          let category = activity.category?.lowercased() ?? activity.category,
          let rating = activity.rating,
          let reviews = activity.reviews,
          let distance = activity.distance,
          let phoneNumber = activity.phoneNumber,
          let description = activity.description?.lowercased() ?? activity.description,
          let somethingInteresting = activity.somethingInteresting else {
      return nil
    }
    return Activity(
      name: name,
      address: address,
      city: city,
      state: state,
      category: category,
      rating: rating,
      reviews: reviews,
      distance: distance,
      phoneNumber: phoneNumber,
      description: description,
      somethingInteresting: somethingInteresting
    )
  }

  private func isModelAvailable() throws {
    switch SystemLanguageModel.default.availability {
    case .available: logger.info("Foundation Models is available and ready to go!")
    case .unavailable(.deviceNotEligible): throw Error.deviceNotEligible
    case .unavailable(.appleIntelligenceNotEnabled): throw Error.appleIntelligenceNotEnabled
    case .unavailable(.modelNotReady): throw Error.modelNotReady
    case .unavailable(let other): throw Error.model("\(other)")
    }
  }
}
