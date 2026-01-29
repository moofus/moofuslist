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
  enum SortOptions: String {
    case distance
    case rating
    case relevance
  }

  @Injected(\.moofuslistSource) var source: MoofuslistSource
  @Bindable var viewModel: MoofuslistViewModel
  @AppStorage("selectedSort") private var selectedSortRawValue: String = SortOptions.relevance.rawValue
  @State private var showSheet = false

  private var selectedSort: SortOptions {
    SortOptions(rawValue: selectedSortRawValue) ?? .relevance
  }

  private var sortedActivities: [MoofuslistViewModel.Activity] {
    switch selectedSort {
    case .distance: viewModel.activities.sorted { $0.distance < $1.distance }
    case .relevance: viewModel.activities
    case .rating: viewModel.activities.sorted { $0.rating > $1.rating }
    }
  }

  var body: some View {
    ZStack {
      Color(.listBackground).ignoresSafeArea()

      VStack(spacing: 0) {
        VStack(alignment: .leading, spacing: 16) {
          Text("Activities near \(viewModel.searchedCityState)")
            .fontSizeWeightForegroundStyle(size: 20, weight: .bold, color: .black)

          HStack(spacing: 10) {
            Menu {
              Button(SortOptions.relevance.rawValue) { selectedSortRawValue = SortOptions.relevance.rawValue }
              Button(SortOptions.rating.rawValue) { selectedSortRawValue = SortOptions.rating.rawValue }
              Button(SortOptions.distance.rawValue) { selectedSortRawValue = SortOptions.distance.rawValue }
            } label: {
              HStack {
                Image(systemName: "arrow.up.arrow.down")
                Text(selectedSort.rawValue)
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

            MapButtonView(showSheet: $showSheet, source: source)
          }
          .padding(20)
          .background(Color.white)

          ScrollView {
            VStack(spacing: 12) {
              ForEach(sortedActivities, id: \.id) { activity in
                MoofuslistCardView(activity: activity)
                  .onTapGesture {
                    source.selectActivity(id: activity.id)
                  }
              }
            }
            .padding(16)
          }
        }
        .sheet(isPresented: $showSheet) {
          ZStack(alignment: .topTrailing) {
            Map {
              ForEach(viewModel.activities, id: \.id) { activity in
                if let mapItem = activity.mapItem {
                  Marker(item: mapItem)
                    .tint(.accent)
                }
              }
            }

            Button {
              withAnimation { showSheet = false }
            } label: {
              Image(systemName: "xmark")
                .foregroundColor(.primary)
                .padding()
                .background(Color.white.opacity(0.8))
                .clipShape(Circle())
            }
            .padding()
          }
        }
        .presentationDetents([.medium, .large])
        .disabled(viewModel.loading)

      }
      .navigationBarTitleDisplayMode(.inline)

      if viewModel.loading {
        ZStack {
          Color(.systemGray6).ignoresSafeArea()

          RoundedRectangle(cornerRadius: 15)
            .fill(Color(.secondarySystemBackground))
            .shadow(radius: 10)

          ProgressView(value: Double(viewModel.activities.count) / 9.0) {
            Text("\(getPercent())% progress")
          }
          .foregroundStyle(Color.primary)
          .padding()
          .cornerRadius(6)
        }
        .padding()
        .frame(width: 180, height: 100)
      }
    }
  }

  private func getPercent() -> Int {
    viewModel.activities.count * 100 / 9
  }

  private struct MapButtonView: View {
    @Binding var showSheet: Bool
    var source: MoofuslistSource

    var body: some View {

      Button {
        Task {
          showSheet = true
          await source.loadMapItems()
        }
      } label: {
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
}

//#Preview("ContentView") {
//
//  @Previewable @State var activities = [
//    MoofuslistViewModel.Activity(
//      address: "address",
//      category: "category",
//      city: "City",
//      description: "description",
//      distance: 1.5,
//      imageNames: ["house"],
//      name: "name",
//      rating: 1.7,
//      reviews: 327,
//      somethingInteresting: "somethingInteresting",
//      state: "State"
//    ),
//    MoofuslistViewModel.Activity(
//      address: "address",
//      category: "category",
//      city: "City",
//      description: "description",
//      distance: 1.5,
//      imageNames: ["house"],
//      name: "name",
//      rating: 1.7,
//      reviews: 327,
//      somethingInteresting: "somethingInteresting",
//      state: "State"
//    )
//  ]
//
//  @Injected(\.moofuslistSource) var source: MoofuslistSource
//  @Injected(\.moofuslistViewModel) var viewModel: MoofuslistViewModel
//
//  MoofuslistContentView(source: source, viewModel: viewModel)
//}

//#Preview("ContentView2") {
//  @Previewable @State var activities = [
//    MoofuslistViewModel.Activity(
//      address: "address",
//      category: "category",
//      city: "City",
//      description: "description",
//      distance: 1.5,
//      imageNames: ["house"],
//      name: "name",
//      rating: 1.7,
//      reviews: 327,
//      somethingInteresting: "somethingInteresting",
//      state: "State"
//    ),
//    MoofuslistViewModel.Activity(
//      address: "address",
//      category: "category",
//      city: "City",
//      description: "description",
//      distance: 1.5,
//      imageNames: ["house"],
//      name: "name",
//      rating: 1.7,
//      reviews: 327,
//      somethingInteresting: "somethingInteresting",
//      state: "State"
//    )
//  ]
//
////  ContentView(activities: $activities, location: "Oakland")
//}
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

