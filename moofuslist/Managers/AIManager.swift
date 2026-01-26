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
    case location
    case model(String)
    case modelNotReady

    var failureReason: String? {
      switch self {
      case .appleIntelligenceNotEnabled: "Apple Intelligence is not enabled in Settings."
      case .deviceNotEligible: "Apple Intelligence is not available on this device."
      case .location: "Moofuslist can't access your location. Do you have Parental Controls enabled?"
      case .model(let errorString): "Apple Intelligence is unavailable: \(errorString)"
      case .modelNotReady: "Apple Intelligence is not ready."
      }
    }

    var errorDescription: String? {
      "Can't get location."
    }

    var recoverySuggestion: String? {
      switch self {
      case .appleIntelligenceNotEnabled: "Apple Intelligence is not enabled in Settings."
      case .deviceNotEligible: "Apple Intelligence is not available on this device."
      case .location: "Moofuslist can't access your location. Do you have Parental Controls enabled?"
      case .model: "Apple Intelligence is unavailable"
      case .modelNotReady: "Apple Intelligence is not ready, try again later."
      }
    }
  }

  enum Message {
    case begin
    case end
    case error(String)
    case loading([Activity])
  }

  @Generable(description: "A container for a list of activities")
  struct Activities {
 //   @Guide(description: "A list of activities to do", .count(6...10))
    @Guide(description: "A list of activities to do", .count(2...3))
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

  let instructions = """
                  Your job is to find activities to do and places to go.
                  
                  Always include a short description, and something interesting about the activity or place.
                  Include a rating and the number of reviews for the rating.
                  Include the phone number.
                  """
  let continuation: AsyncStream<Message>.Continuation
  let stream: AsyncStream<Message>

  init() {
    (stream, continuation) = AsyncStream.makeStream(of: Message.self)
  }
}

// MARK: - Public Methods
extension AIManager {
  func findActivities(cityState: String) async throws {
    try isModelAvailable()

    let newInstructions = self.instructions + " Always include the distance from \(cityState)" // ljw
    let session = LanguageModelSession(instructions: newInstructions)
    let text = "Generate a list of things to do near \(cityState)"
    do {
      let stream = session.streamResponse(to: text, generating: Activities.self) // Streaming partial generations
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
    }
    catch LanguageModelSession.GenerationError.guardrailViolation(let error) {
      print("guardrailViolation Error")
      print(error)
      //    addMessage(
      //      """
      //      The system’s safety guardrails are triggered by content in a prompt or the response generated by the model.
      //      """,
      //      isFromUser: false
      //    )
    }
    catch LanguageModelSession.GenerationError.exceededContextWindowSize(let error) {
      print("exceededContextWindowSize Error")
      print(error)
      //    addMessage(
      //      "Context Windows Length of 4096 tokens has been exceeded.",
      //      isFromUser: false,
      //    )
    }
    catch {
      print("Error")
      print(error.localizedDescription) // ljw
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

/*
 To find places for a specific activity like fishing in an iOS Swift app, you should use the MapKit framework and its MKLocalSearch functionality to query points of interest (POIs) based on the user's current location.
 Core Steps to Implement
 Import MapKit & CoreLocation: Needed for map display and user positioning.
 Request User Location: Use CLLocationManager to get the current coordinates.
 Perform MKLocalSearch: Use a natural language query like "fishing spot" or "boat ramp" within a defined region around the user.
 Display Results: Annotate the map with pins (MKMarkerAnnotationView) for found locations.
 Swift Code Example (SwiftUI)
 This example demonstrates searching for "fishing" near the user's current location:
 swift
 import SwiftUI
 import MapKit

 struct FishingSpotFinder: View {
     @State private var region = MKCoordinateRegion(
         center: CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194),
         span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
     )
     @State private var searchResults: [MKMapItem] = []

     var body: some View {
         Map(coordinateRegion: $region, annotationItems: searchResults) { item in
             MapMarker(coordinate: item.placemark.coordinate)
         }
         .onAppear {
             searchForFishingSpots()
         }
     }

     func searchForFishingSpots() {
         let request = MKLocalSearch.Request()
         // Keyword search for the activity
         request.naturalLanguageQuery = "fishing"
         request.region = region

         let search = MKLocalSearch(request: request)
         search.start { response, error in
             guard let response = response else {
                 print("Error: \(error?.localizedDescription ?? "Unknown error")")
                 return
             }
             searchResults = response.mapItems
         }
     }
 }
 Techniques to Improve Accuracy
 Refine the Query: Instead of just "fishing," use specific terms like "boat ramp," "fishing pier," or "lake" to find specialized locations.
 Filter by Region: Set the MKLocalSearch.Request.region to the visible area of the map to prevent results from being too far away.
 Use MKLocalSearchCompleter: Implement this to provide auto-complete suggestions as the user types.
 Third-Party APIs: For more specialized data (like water depth or species), consider integrating APIs from services like Fishbrain or Google Places, which offer specific filters for activity-based searches.
 */


/*
 func generateImages() async throws {
   print("ljw \(Date()) \(#file):\(#function):\(#line)")
   do {
     print("ljw \(Date()) \(#file):\(#function):\(#line)")
     let creator = try await ImageCreator()
     print("ljw \(Date()) \(#file):\(#function):\(#line)")
     let generatedImages = creator.images(
//        for: [.text("A cat wearing mittens.")],
//        for: [.text("A beach in Hawaii")],
       for: [.text("An american football game")],
//        style: .illustration,
//        style: .animation,
       style: .sketch,
       limit: 1
     )

     for try await generatedImage in generatedImages {
       print("ljw \(Date()) \(#file):\(#function):\(#line)")
       images.append(generatedImage.cgImage)
     }
   } catch {
 print("ljw \(Date()) \(#file):\(#function):\(#line)")
 print("error=\(error)")
 assertionFailure() // ljw
   }
   print("ljw \(Date()) \(#file):\(#function):\(#line)")
 }

 */

