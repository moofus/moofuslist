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
  @AppStorage("autoManualSwitch") private var autoManualSwitch = true // initially switch automatically
  @State var errorText = ""
  @State private var haveError = false
  @State private var selectedImageIdx = 0
  @Injected(\.moofuslistSource) private var source: MoofuslistSource
  @Bindable var viewModel: MoofuslistViewModel

  private let logger = Logger(subsystem: "com.moofus.moofuslist", category: "MoofuslistDetailView")
  @State var timedAction = TimedAction()

  var body: some View {
    ZStack {
      Color(.listBackground).ignoresSafeArea()

      if let activity = viewModel.selectedActivity {
        ScrollView {
          VStack(spacing: 0) {
            VStack {
              TabView(selection: $selectedImageIdx) {
                ForEach(0..<activity.imageNames.count, id: \.self) { idx in
                  Image(systemName: activity.imageNames[idx])
                    .fontSizeForegroundStyle(size: 80, color: .accent)
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
                    .fontSizeWeightForegroundStyle(size: 24, weight: .bold, color: .black)

                  HStack(spacing: 12) {
                    HStack(spacing: 4) {
                      Image(systemName: "star.fill")
                        .fontSizeForegroundStyle(size: 14, color: .orange)
                      Text("\(String(format: "%.1f", activity.rating))")
                        .font(.system(size: 14, weight: .semibold))
                    }

                    Text("(\(activity.reviews) reviews)")
                      .fontSizeForegroundStyle(size: 12, color: .gray)
                  }
                }

                Spacer()

                Button {
                  source.setIsFavorite(!activity.isFavorite, for: activity.id)
                } label: {
                  Image(systemName: activity.isFavorite ? "heart.fill" : "heart")
                    .fontSizeForegroundStyle(size: 24, color: activity.isFavorite ? .accent : .gray)
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
                    haveError = true
                    errorText = "Could not call phone number: \(activity.phoneNumber)"
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
                  .fontSizeWeightForegroundStyle(size: 16, weight: .semibold, color: .black)

                Text(activity.somethingInteresting)
                  .fontSizeForegroundStyle(size: 14, color: .gray)
                  .lineSpacing(2)
              }
            }
            .padding(20)
          }
        }
        .onAppear {
          selectedImageIdx = 0
        }

        if activity.imageNames.count > 1 {
          VStack {
            HStack {
              Spacer()
              Button {
                autoManualSwitch.toggle()
              } label: {
                if autoManualSwitch {
                  Text("auto")
                } else {
                  Text("manual")
                }
              }
              .padding()
            }
            Spacer()
          }
        }
      } else {
        Text("Select an activity")
      }
    }
    .alert("Error", isPresented: $haveError) {
      ErrorView(errorText: errorText)
    }
  }

  private func startTimedAction() {
    var starting = true

    timedAction.start(sleepTimeInSeconds: 3) {
      guard autoManualSwitch else {
        return
      }

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

  private func openInMaps(activity: MoofuslistActivity) {
    Task {
      let mapItem: MKMapItem
      if let item = activity.mapItem {
        mapItem = item
      } else {
        logger.error("Failed to mapItem for address=\(activity.address)") 
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
        .fontSizeWeightForegroundStyle(size: 16, weight: .semibold, color: .accent)
        .frame(width: 24)
      
      VStack(alignment: .leading, spacing: 4) {
        Text(title)
          .fontSizeWeightForegroundStyle(size: 12, weight: .medium, color: .gray)
        Text(value)
          .fontSizeWeightForegroundStyle(size: 14, weight: .semibold, color: .black)
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
