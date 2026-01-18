//
//  MoofuslistDetailView.swift
//  Moofuslist
//
//  Created by Lamar Williams III on 1/12/26.
//

import FactoryKit
import os
import SwiftUI

struct MoofuslistDetailView: View {
  typealias Activity = MoofuslistViewModel.Activity

  @State private var selectedIdx = 0
  @State private var isFavorite = false
  @State private var timedActionSelectedImage = false

  let activity: Activity?
  private let logger = Logger(subsystem: "com.moofus.moofuslist", category: "MoofuslistDetailView")
  private let timedAction = TimedAction()

  var body: some View {
    ZStack {
      Color(.listBackground).ignoresSafeArea()

      ScrollView {
        VStack(spacing: 0) {
          VStack {
            if let activity {
              TabView(selection: $selectedIdx) {
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
              .onAppear {
                handleTabViewOnAppear()
              }
              .onChange(of: selectedIdx) {
                handleSelectedIdxOnChange()
              }
            }
          }

          VStack(alignment: .leading, spacing: 20) {
            HStack {
              VStack(alignment: .leading, spacing: 8) {
                if let activity {
                  Text(activity.name)
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(.black)
                }

                HStack(spacing: 12) {
                  HStack(spacing: 4) {
                    Image(systemName: "star.fill")
                      .font(.system(size: 14))
                      .foregroundColor(.orange)
                    Text("\(String(format: "%.1f", activity?.rating ?? 0.0))")
                      .font(.system(size: 14, weight: .semibold))
                  }

                  Text("(\(activity?.reviews ?? 0) reviews)")
                    .font(.system(size: 12))
                    .foregroundColor(.gray)
                }
              }

              Spacer()

              Button(action: { isFavorite.toggle() }) {
                Image(systemName: isFavorite ? "heart.fill" : "heart")
                  .font(.system(size: 24))
                  .foregroundColor(isFavorite ? .accent : .gray)
              }
            }

            // Info Cards
            VStack(spacing: 12) {
              if let activity {
                InfoRow(icon: "location.fill", title: "Address", value: activity.address)
                InfoRow(icon: "mappin.circle.fill", title: "Distance", value: "\(String(format: "%.1f", activity.distance)) miles away")
                InfoRow(icon: "tag.fill", title: "Category", value: activity.category)
              }
            }

            // Action Buttons
            VStack(spacing: 12) {
              Button(action: { }) {
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

              Button(action: { }) {
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

              Text(activity?.somethingInteresting ?? "")
                .font(.system(size: 14))
                .foregroundColor(.gray)
                .lineSpacing(2)
            }
          }
          .padding(20)
        }
      }
    }
    .navigationBarTitleDisplayMode(.inline)
    .navigationBarBackButtonHidden(true)
    .toolbar {
        ToolbarItem(placement: .topBarLeading) {
            Button {
              timedAction.stop()
              selectedIdx = 0
              timedActionSelectedImage = false
              @Injected(\.appCoordinator) var appCoordinator: AppCoordinator
              appCoordinator.navigate(to: .content)
            } label: {
                HStack {
                  Image(systemName: "chevron.backward")
                      .fontWeight(.semibold)
                }
            }
        }
    }
  }

  private func handleTabViewOnAppear() {
    guard let activity else {
      assertionFailure()
      logger.error("No activity")
      return
    }
    guard activity.imageNames.count > 1 else {
      return
    }

    var starting = true
    timedAction.start(sleepTimeInSeconds: 3) {
      withAnimation {
        if starting {
          starting = false
          selectedIdx = 1
        } else {
          if (selectedIdx + 1) >= activity.imageNames.count {
            selectedIdx = 0
          } else {
            selectedIdx += 1
          }
        }
        timedActionSelectedImage = true
      }
    } errorHandler: { error in
      selectedIdx = 0
    }
  }

   private func handleSelectedIdxOnChange() {
    if !timedActionSelectedImage {
      timedAction.stop()
    }
    timedActionSelectedImage = false
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

#Preview {
  @Previewable @State var activity =
  MoofuslistViewModel.Activity(
    address: "address",
    category: "category",
    city: "City",
    description: "description",
    distance: 1.5,
    imageNames: ["house"],
    name: "name",
    rating: 1.7,
    reviews: 327,
    somethingInteresting: "somethingInteresting",
    state: "State"
  )

  NavigationStack {
    MoofuslistDetailView(activity: activity)
  }
}
