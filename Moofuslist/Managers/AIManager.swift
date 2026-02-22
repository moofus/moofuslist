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
  static let maxNumOfActivities = 10

  var cancelStreamLoop = false
  let continuation: AsyncStream<Message>.Continuation
  let instructions =
  """
  Your job is to find activities to do and places to go.
  Include a short description.
  Include something interesting about the activity or the place.
  Include a rating and the number of reviews for the rating.
  Include the phone number.
  """
  let logger = Logger(subsystem: "com.moofus.moofuslist", category: "AIManager")
  let stream: AsyncStream<Message>

  init() {
    (stream, continuation) = AsyncStream<Message>.makeStream()
  }
}

// MARK: - Enums
extension AIManager {
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
}

// MARK: - Generables
extension AIManager {
  @Generable(description: "A container for a list of activities")
  struct Activities {
    @Guide(description: "A list of activities to do", .count(6...maxNumOfActivities))
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
}

// MARK: - Public Methods
extension AIManager {
  func cancelLoading() {
    cancelStreamLoop = true
  }

  func findActivities(cityState: String) async throws {
    try isModelAvailable()

    let newInstructions = instructions + "\n Always include the distance to \(cityState)"
    let session = LanguageModelSession(instructions: newInstructions)
    let text = "Generate a list of things to do near \(cityState)"
    do {
      let stream = session.streamResponse(to: text, generating: Activities.self)
      var beginSent = false
      cancelStreamLoop = false

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
        if cancelStreamLoop {
          cancelStreamLoop = false
          logger.info("loading canceled")
          break
        }
      }
      continuation.yield(.end)
    } catch LanguageModelSession.GenerationError.guardrailViolation {
      logger.error("guardrailViolation Error")
      assertionFailure()
      continuation.yield(.error(Error.guardrailViolation))
    } catch LanguageModelSession.GenerationError.exceededContextWindowSize {
      logger.error("exceededContextWindowSize Error")
      assertionFailure()
      continuation.yield(.error(Error.exceededContextWindowSize))
    } catch {
      logger.error("\(error)")
      assertionFailure()
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

#if DEBUG
extension AIManager {

  func testHooks() -> TestHooks {
    TestHooks(aiManager: self)
  }

  struct TestHooks {
    let aiManager: AIManager

    init(aiManager: AIManager) {
      self.aiManager = aiManager
    }

    var cancelStreamLoop: Bool {
      get async {
        await aiManager.cancelStreamLoop
      }
    }

    func isModelAvailable() async throws {
      try await aiManager.isModelAvailable()
    }
  }
}
#endif

/*
typealias Activity = AIManager.Activity

// swiftlint:disable line_length
let mockActivities: [AIManager.Activity] = [
  Activity(name: "white rock lake", address: "White Rock Lake Park, Alamogordo, NM 88311", city: "Alamogordo", state: "New Mexico", category: "recreational area", rating: 4.3, reviews: 250, distance: 125.0, phoneNumber: "(575) 523-5200", description: "white rock lake is a popular spot for boating, fishing, and picnicking, surrounded by scenic views and hiking trails.", somethingInteresting: "The lake is part of a man-made reservoir, created by the White Rock Dam, and is a hub for outdoor recreation in the region."),

  Activity(name: "las cruces botanic garden", address: "2250 N Sierra Vista Dr, Las Cruces, NM 88005", city: "Las Cruces", state: "New Mexico", category: "botanical garden", rating: 4.4, reviews: 220, distance: 130.0, phoneNumber: "(575) 522-2400", description: "the las cruces botanic garden features a diverse collection of plants from around the world, offering beautiful gardens and educational programs.", somethingInteresting: "The garden is home to a wide variety of plant species, including desert flora and tropical plants, creating a unique ecosystem."),

  Activity(name: "chaco culture national historical park", address: "2400 Chaco Culture Way, Aztec, NM 87101", city: "Aztec", state: "New Mexico", category: "historical site", rating: 4.6, reviews: 180, distance: 180.0, phoneNumber: "(575) 522-2400", description: "chaco culture national historical park showcases ancient cliff dwellings and ruins built by the ancestral puebloans, reflecting their sophisticated architectural skills.", somethingInteresting: "The park includes the well-preserved structures of Pueblo Bonito, one of the largest and most significant archaeological sites in the Southwest."),

  Activity(name: "roswell international ufo museum and research center", address: "14110 4th St SW, Roswell, NM 88201", city: "Roswell", state: "New Mexico", category: "museum", rating: 4.5, reviews: 350, distance: 200.0, phoneNumber: "(575) 988-4200", description: "the museum is dedicated to the study and exhibition of ufos and extraterrestrial phenomena, featuring a vast collection of artifacts and exhibits.", somethingInteresting: "Roswell is famous for the 1947 UFO incident, and the museum plays a central role in this ongoing mystery."),

  Activity(name: "taos pueblo", address: "480 Pueblo Rd, Taos, NM 87846", city: "Taos", state: "New Mexico", category: "cultural landmark", rating: 4.9, reviews: 200, distance: 150.0, phoneNumber: "(575) 751-1880", description: "taos pueblo is a living native american community with a rich history dating back over 900 years. visitors can explore the historic dwellings and learn about the pueblo culture.", somethingInteresting: "The pueblo is one of the oldest continuously inhabited communities in the United States, with a history that predates European settlement."),

  Activity(name: "carlsbad caverns national park", address: "24005 Cavern Rd, Carlsbad, NM 88220", city: "Carlsbad", state: "New Mexico", category: "national park", rating: 4.7, reviews: 300, distance: 175.0, phoneNumber: "(575) 522-2400", description: "carlsbad caverns is home to the big room, the largest known cave chamber in the world. visitors can explore the stunning underground formations and guided tours.", somethingInteresting: "The park features more than 200 miles of mapped cave passages, with the Big Room being the centerpiece attraction."),

  Activity(name: "white sands national park", address: "17070 White Sands Rd, Alamogordo, NM 88311", city: "Alamogordo", state: "New Mexico", category: "national park", rating: 4.8, reviews: 150, distance: 125.0, phoneNumber: "(575) 523-5200", description: "white sands national park is known for its stunning gypsum sand dunes, which can be seen from space. visitors can hike, sand sledding, and enjoy breathtaking views.", somethingInteresting: "The park\'s dunes are made of gypsum, which is the same mineral that makes up drywall, giving them a unique texture and color.")
]
// swiftlint:enable line_length
*/
