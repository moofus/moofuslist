//
//  MoofuslistContentView.swift
//  Moofuslist
//
//  Created by Lamar Williams III on 1/4/26.
//

import FactoryKit
import MapKit
import SwiftUI

struct MoofuslistContentView: View {
  var source: MoofuslistSource
  @Bindable var viewModel: MoofuslistViewModel
  @State private var selectedSort = "Relevance"

  var body: some View {
    ZStack {
      Color(.listBackground).ignoresSafeArea()

      VStack(spacing: 0) {
        // Header
        let _ = print("ljw \(Date()) \(#file):\(#function):\(#line)")
        VStack(alignment: .leading, spacing: 16) {
          Text("Results near \(viewModel.searchedCityState)")
            .font(.system(size: 20, weight: .bold))
            .foregroundColor(.black)

          HStack(spacing: 10) {
            Menu {
              Button("Relevance") { selectedSort = "Relevance" }
              Button("Rating") { selectedSort = "Rating" }
              Button("Distance") { selectedSort = "Distance" }
            } label: {
              HStack {
                Image(systemName: "arrow.up.arrow.down")
                Text(selectedSort)
                  .font(.system(size: 14, weight: .medium))
              }
              .foregroundColor(.accent)
              .padding(8)
              .background(Color.white)
              .cornerRadius(8)
              .overlay(
                RoundedRectangle(cornerRadius: 8)
                  .stroke(.accent.opacity(0.3), lineWidth: 1)
              )
            }

            Spacer()

            Button(action: { }) {
              HStack {
                Image(systemName: "map")
                Text("Map")
                  .font(.system(size: 14, weight: .medium))
              }
              .foregroundColor(.accent)
              .padding(8)
              .background(Color.white)
              .cornerRadius(8)
              .overlay(
                RoundedRectangle(cornerRadius: 8)
                  .stroke(.accent.opacity(0.3), lineWidth: 1)
              )
            }
          }
        }
        .padding(20)
        .background(Color.white)

        ScrollView {
          VStack(spacing: 12) {
            ForEach(viewModel.activities.indices, id: \.self) { idx in
              MoofuslistCardView(activity: $viewModel.activities[idx])
                .onTapGesture {
                  source.select(idx: idx)
                }
            }
          }
          .padding(16)
        }
      }
      .disabled(viewModel.loading)

      if viewModel.loading {
        ProgressView() // ljw
      }
    }
    .navigationBarTitleDisplayMode(.inline)
  }
}

#Preview("ContentView") {

  @Previewable @State var activities = [
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
    ),
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
  ]

  @Injected(\.moofuslistSource) var source: MoofuslistSource
  @Injected(\.moofuslistViewModel) var viewModel: MoofuslistViewModel

  MoofuslistContentView(source: source, viewModel: viewModel)
}

#Preview("ContentView2") {
  @Previewable @State var activities = [
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
    ),
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
  ]

//  ContentView(activities: $activities, location: "Oakland")
}
/*
 //    let activities = [
 //        Activity(name: "Downtown Pizza Co.", category: "Restaurants", rating: 4.8, distance: 0.3, address: "123 Main St", image: "fork.knife", reviews: 245, isFavorite: false),
 //        Activity(name: "Central Park Trails", category: "Parks", rating: 4.6, distance: 0.5, address: "Park Avenue", image: "tree.fill", reviews: 189, isFavorite: false),
 //        Activity(name: "Modern Art Gallery", category: "Museums", rating: 4.7, distance: 1.2, address: "456 Art Blvd", image: "building.2.fill", reviews: 156, isFavorite: false),
 //        Activity(name: "Comedy Club Live", category: "Entertainment", rating: 4.5, distance: 0.8, address: "789 Fun St", image: "popcorn.fill", reviews: 203, isFavorite: false),
 //        Activity(name: "Vintage Market Hall", category: "Shopping", rating: 4.4, distance: 1.1, address: "Shopping District", image: "bag.fill", reviews: 178, isFavorite: false),
 //        Activity(name: "The Rooftop Bar", category: "Nightlife", rating: 4.6, distance: 0.6, address: "Downtown Heights", image: "moon.stars.fill", reviews: 312, isFavorite: false),
 //    ]

 */


