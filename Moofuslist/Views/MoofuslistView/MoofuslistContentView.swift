//
//  MoofuslistContentView.swift
//  Moofuslist
//
//  Created by Lamar Williams III on 1/4/26.
//

import FactoryKit
@preconcurrency import MapKit
import SwiftUI

private enum SortOptions: String {
  case distance
  case rating
  case relevance
}

struct MoofuslistContentView: View {
  @AppStorage("selectedSort") private var selectedSortText: String = SortOptions.relevance.rawValue
  @State private var showSheet = false
  @Injected(\.moofuslistSource) var source: MoofuslistSource
  @Bindable var viewModel: MoofuslistViewModel

  private var selectedSortOption: SortOptions {
    SortOptions(rawValue: selectedSortText) ?? .relevance
  }

  private var sortedActivities: [MoofuslistActivity] {
    switch selectedSortOption {
    case .distance: viewModel.activities.sorted { $0.distance < $1.distance }
    case .relevance: viewModel.activities
    case .rating: viewModel.activities.sorted { $0.rating > $1.rating }
    }
  }

  var body: some View {
    ZStack {
      VStack(spacing: 0) {
        VStack(alignment: .leading) {
          HeaderView(
            selectedSortText: $selectedSortText,
            showSheet: $showSheet,
            source: source,
            viewModel: viewModel
          )

          ScrollView {
            VStack(spacing: 12) {
              ForEach(sortedActivities, id: \.id) { activity in
                MoofuslistCardView(activity: activity)
                  .onTapGesture {
                    source.selectActivity(for: activity.id)
                  }
              }
            }
            .padding([.bottom, .leading, .trailing ], 16)
          }
        }
        .sheet(isPresented: $showSheet) {
          MapSheetView(showSheet: $showSheet, source: source, viewModel: viewModel)
        }
        .presentationDetents([.medium, .large])
        .disabled(viewModel.loading)
      }
      .background(Color.listBackground)
      .navigationBarTitleDisplayMode(.inline)

      if viewModel.loading {
        LoadingView(source: source, viewModel: viewModel)
      }
    }
  }
}

private struct HeaderView: View {
  @Binding var selectedSortText: String
  @Binding var showSheet: Bool
  var source: MoofuslistSource
  @Bindable var viewModel: MoofuslistViewModel

  var body: some View {
    VStack(spacing: 16) {
      Text(viewModel.contentTitle)
        .fontSizeWeightForegroundStyle(size: 20, weight: .bold, color: .black)
        .frame(maxWidth: .infinity)
        .padding(.top, 0)

      HStack(spacing: 10) {
        FilterMenuView(selectedSortText: $selectedSortText)

        Spacer()

        MapButtonView(showSheet: $showSheet, source: source)
      }
    }
    .padding(.top, 0)
    .padding([.leading, .trailing], 20)
    .padding([.bottom ], 18)
    .background(Color.white)
  }
}

private struct FilterMenuView: View {
  @Binding var selectedSortText: String

  var body: some View {
    Menu {
      Button(SortOptions.relevance.rawValue) { selectedSortText = SortOptions.relevance.rawValue }
      Button(SortOptions.rating.rawValue) { selectedSortText = SortOptions.rating.rawValue }
      Button(SortOptions.distance.rawValue) { selectedSortText = SortOptions.distance.rawValue }
    } label: {
      HStack {
        Image(systemName: "arrow.up.arrow.down")
        Text(selectedSortText)
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

private struct LoadingView: View {
  var source: MoofuslistSource
  @Bindable var viewModel: MoofuslistViewModel

  var body: some View {
    VStack(spacing: 14) {
      ProgressView(value: Double(viewModel.activities.count) / Double(AIManager.maxNumOfActivities + 1)) {
        Text("\(getPercent())% progress")
      }
      .foregroundStyle(Color.primary)
      .padding()
      .cornerRadius(6)

      VStack {
        Text("Apple Intelligence loading is slow")
        Button(role: .cancel) {
          source.cancelLoading()
        }
        .font(.footnote)
        .buttonStyle(.glassProminent)
      }
    }
    .padding()
    .frame(width: 260, height: 200)
    .background(Color(.secondarySystemBackground))
    .clipShape(RoundedRectangle(cornerRadius: 15, style: .continuous))
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

struct MapSheetView: View {
  @Binding var showSheet: Bool
  var source: MoofuslistSource
  @Bindable var viewModel: MoofuslistViewModel

  var body: some View {
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
    }  }
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
