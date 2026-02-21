//
//  MoofuslistContentView.swift
//  Moofuslist
//
//  Created by Lamar Williams III on 1/4/26.
//

import FactoryKit
@preconcurrency import MapKit
import SwiftUI

struct MoofuslistContentView: View {
  enum SortOptions: String {
    case distance
    case rating
    case relevance
  }

  @AppStorage("selectedSort") private var selectedSortRawValue: String = SortOptions.relevance.rawValue
  @State private var showSheet = false
  @Injected(\.moofuslistSource) var source: MoofuslistSource
  @Bindable var viewModel: MoofuslistViewModel

  private var selectedSort: SortOptions {
    SortOptions(rawValue: selectedSortRawValue) ?? .relevance
  }

  private var sortedActivities: [MoofuslistActivity] {
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
          Text(viewModel.contentTitle)
            .fontSizeWeightForegroundStyle(size: 20, weight: .bold, color: .black)
            .padding(.leading, 16)

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
                    source.selectActivity(for: activity.id)
                  }
              }
            }
            .padding(16)
          }
        }
        .sheet(isPresented: $showSheet) {
          ZStack(alignment: .topTrailing) {
            Map {
              ForEach(Array(viewModel.mapItems.keys), id: \.self) { key in
                if let mapItem = viewModel.mapItems[key] {
                  Marker(item: mapItem)
                    .tint(.accent)
                }
              }
            }
            .onAppear {
              source.loadMapItems()
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
        VStack(spacing: 14) {
          ProgressView(value: Double(viewModel.activities.count) / Double(AIManager.maxNumOfActivities)) {
            Text("\(getPercent())% progress")
          }
          .foregroundStyle(Color.primary)
          .padding()
          .cornerRadius(6)

          Text("Apple Intelligence loading is slow")
            .font(.footnote)
        }
        .padding()
        .frame(width: 260, height: 100)
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 15, style: .continuous))
      }
    }
  }

  private func getPercent() -> Int {
    viewModel.activities.count * 100 / AIManager.maxNumOfActivities
  }
}

private struct MapButtonView: View {
  @Binding var showSheet: Bool
  var source: MoofuslistSource

  var body: some View {

    Button {
      Task {
        showSheet = true
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

#if DEBUG
#Preview("ContentView") {
  @Injected(\.moofuslistViewModel) var viewModel: MoofuslistViewModel
  var testhooks = MoofuslistViewModel.TestHooks(viewModel: viewModel)
  testhooks.activities = globalActivities
  testhooks.contentTitle = "Activities near San Franscisco"
  return MoofuslistContentView(viewModel: viewModel)
}
#endif // DEBUG
