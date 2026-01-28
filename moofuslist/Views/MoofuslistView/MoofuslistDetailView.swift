//
//  MoofuslistDetailView.swift
//  Moofuslist
//
//  Created by Lamar Williams III on 1/12/26.
//

import FactoryKit
import os
import SwiftUI
import MapKit

struct MoofuslistDetailView: View {
  @State var selectedImageIdx = 0
  @Injected(\.moofuslistSource) var source: MoofuslistSource
  @Bindable var viewModel: MoofuslistViewModel


  private let logger = Logger(subsystem: "com.moofus.moofuslist", category: "MoofuslistDetailView")
  @State var timedAction = TimedAction()

  var body: some View {
    let _ = print("ljw \(Date()) \(#file):\(#function):\(#line)")
    
    ZStack {
      Color(.listBackground).ignoresSafeArea()

      if let activity = viewModel.selectedActivity {
        ScrollView {
          VStack(spacing: 0) {
            VStack {
              TabView(selection: $selectedImageIdx) {
                ForEach(0..<activity.imageNames.count, id: \.self) { idx in
                  Image(systemName: activity.imageNames[idx])
                    .font(.system(size: 80))
                    .foregroundColor(.accent)
                    .tag(idx)
                }
              }
              .background(Color(red: 1, green: 0.9, blue: 0.8))
              .tabViewStyle(.page)
              .frame(height: 250)
              .frame(maxWidth: .infinity)
              .task {
                startTimedAction()
              }
            }

            VStack(alignment: .leading, spacing: 20) {
              HStack {
                VStack(alignment: .leading, spacing: 8) {
                  Text(activity.name)
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(.black)

                  HStack(spacing: 12) {
                    HStack(spacing: 4) {
                      Image(systemName: "star.fill")
                        .font(.system(size: 14))
                        .foregroundColor(.orange)
                      Text("\(String(format: "%.1f", activity.rating))")
                        .font(.system(size: 14, weight: .semibold))
                    }

                    Text("(\(activity.reviews) reviews)")
                      .font(.system(size: 12))
                      .foregroundColor(.gray)
                  }
                }

                Spacer()

                Button {
                  source.changeFavorite(id: activity.id)
                } label: {
                  let _ = print("ljw id=\(activity.id) isFavorite=\(activity.isFavorite) \(Date()) \(#file):\(#function):\(#line)")
                  Image(systemName: activity.isFavorite ? "heart.fill" : "heart")
                    .font(.system(size: 24))
                    .foregroundColor(activity.isFavorite ? .accent : .gray)
                }
              }

              // Info Cards
              VStack(spacing: 12) {
                InfoRow(icon: "location.fill", title: "Address", value: activity.address)
                InfoRow(icon: "mappin.circle.fill", title: "Distance", value: "\(String(format: "%.1f", activity.distance)) miles away")
                InfoRow(icon: "tag.fill", title: "Category", value: activity.category)
              }

              // Action Buttons
              VStack(spacing: 12) {
                Button {
                  if let url = URL(string: "tel://\(activity.phoneNumber)"),
                     UIApplication.shared.canOpenURL(url) {
                      UIApplication.shared.open(url)
                  } else {
                    // TODO: handle error
                  }
                } label: {
                  HStack {
                    Image(systemName: "phone.fill")
                    Text("Call")
                  }
                  .font(.system(size: 16, weight: .semibold))
                  .frame(maxWidth: .infinity)
                  .padding(12)
                  .background(.accent)
                  .foregroundColor(.white)
                  .cornerRadius(12)
                }

                Button(action: {
                  openInMaps(activity: activity)
                }) {
                  HStack {
                    Image(systemName: "map.fill")
                    Text("Get Directions")
                  }
                  .font(.system(size: 16, weight: .semibold))
                  .frame(maxWidth: .infinity)
                  .padding(12)
                  .background(Color.white)
                  .foregroundColor(.accent)
                  .cornerRadius(12)
                  .overlay(
                    RoundedRectangle(cornerRadius: 12)
                      .stroke(.accent, lineWidth: 1.5)
                  )
                }
              }

              // Description
              VStack(alignment: .leading, spacing: 8) {
                Text("About")
                  .font(.system(size: 16, weight: .semibold))
                  .foregroundColor(.black)

                Text(activity.somethingInteresting)
                  .font(.system(size: 14))
                  .foregroundColor(.gray)
                  .lineSpacing(2)
              }
            }
            .padding(20)
          }
        }
      } else {
        Text("Select an activity")
      }
    }
  }

  private func startTimedAction() {
    var starting = true

    timedAction.start(sleepTimeInSeconds: 3) {
      guard let activity = viewModel.selectedActivity, activity.imageNames.count > 1 else {
        return
      }

      withAnimation {
        if starting {
          starting = false
          selectedImageIdx = 0
        } else {
          if (selectedImageIdx + 1) < activity.imageNames.count {
            selectedImageIdx += 1
          } else {
            selectedImageIdx = 0
          }
        }
      }
    }
  }

  private func openInMaps(activity: MoofuslistViewModel.Activity) {
    Task {
      let mapItem: MKMapItem
      if let item = activity.mapItem {
        mapItem = item
      } else if let item = await source.mapItemFrom(address: activity.address) {
        mapItem = item
      } else {
        logger.error("Failed to mapItem") // TODO: handle
        assertionFailure()
        return
      }
      mapItem.name = activity.name
      mapItem.openInMaps(launchOptions: [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving])
    }
  }
}

// MARK: - Info Row
struct InfoRow: View {
  let icon: String
  let title: String
  let value: String
  
  var body: some View {
    HStack(spacing: 12) {
      Image(systemName: icon)
        .font(.system(size: 16, weight: .semibold))
        .foregroundColor(.accent)
        .frame(width: 24)
      
      VStack(alignment: .leading, spacing: 4) {
        Text(title)
          .font(.system(size: 12, weight: .medium))
          .foregroundColor(.gray)
        Text(value)
          .font(.system(size: 14, weight: .semibold))
          .foregroundColor(.black)
      }
      
      Spacer()
    }
    .padding(12)
    .background(Color.white)
    .cornerRadius(12)
  }
}

//#Preview {
//  @Previewable @State var activity: MoofuslistViewModel.Activity? =
//  MoofuslistViewModel.Activity(
//    address: "address",
//    category: "category",
//    city: "City",
//    description: "description",
//    distance: 1.5,
//    imageNames: ["house"],
//    name: "name",
//    rating: 1.7,
//    reviews: 327,
//    somethingInteresting: "somethingInteresting",
//    state: "State"
//  )
//  
//  NavigationStack {
//    MoofuslistDetailView(activity: $activity)
//  }
//}
