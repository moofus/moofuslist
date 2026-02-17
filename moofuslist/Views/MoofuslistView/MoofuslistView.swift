//
//  MoofuslistView.swift
//  Moofuslist
//
//  Created by Lamar Williams III on 12/21/25.
//

import FactoryKit
import MapKit
import SwiftUI

struct MoofuslistView: View {
  @Injected(\.moofuslistCoordinator) var moofuslistCoordinator: MoofuslistCoordinator
  @State private var searchText: String = ""
  @Environment(\.scenePhase) private var scenePhase
  @Injected(\.moofuslistSource) var source: MoofuslistSource
  @Injected(\.moofuslistViewModel) var viewModel: MoofuslistViewModel

  var body: some View {
    @Bindable var moofuslistCoordinator = moofuslistCoordinator
    @Bindable var viewModel = viewModel

    NavigationSplitView(preferredCompactColumn: $moofuslistCoordinator.splitViewColum) {
      VStack {
        MoofuslistHeaderView()

        MoofuslistMapView(item: viewModel.mapItem, position: $viewModel.mapPosition)

        GPSPinButton(text: "Search Current Location", padding: 5) {
          searchText = ""
          source.searchCurrentLocation()
        }

        if viewModel.processing {
          ProgressView()
        }

        if viewModel.haveFavorites {
          Button {
            source.displayFavorites()
          } label: {
            Text("Favorites")
              .padding()
          }
          .buttonStyle(.glassProminent)
          .padding()
        }

        Spacer()

        Label {
          Text("Using Apple Intelligence")
            .font(.footnote)
        } icon: {
          Image(systemName: "sparkles")
            .foregroundStyle(.accent)
        }
      }
      .searchable(text: $searchText, prompt: "Search City, State, or Zip")
      .onSubmit(of: .search) {
        source.searchCityState(searchText)
      }
      .safeAreaPadding([.leading, .trailing])
    } content: {
      MoofuslistContentView(viewModel: viewModel)
    } detail: {
      MoofuslistDetailView(viewModel: viewModel)
    }
    .disabled(viewModel.processing)
    .alert("\"City, State\" is invalid!", isPresented: $viewModel.inputError) {
      Button("OK") {}
    }
    .alert(viewModel.errorDescription, isPresented: $viewModel.haveError, presenting: viewModel) {  viewModel in
      Button("OK") {}
    } message: { error in
      Text(viewModel.errorRecoverySuggestion)
    }
    .onChange(of: scenePhase, initial: true) { oldPhase, newPhase in
      switch newPhase {
      case .active:
        print("\(Date()) ljw App is active from \(oldPhase)")
      case .background:
        print("\(Date()) App entered background from \(oldPhase)")
      case .inactive:
        print("\(Date()) ljw App is inactive from \(oldPhase)") // TODO: cancel loading, remove old favorites
      @unknown default:
        print("\(Date()) ljw Unknown scene phase from \(oldPhase)")
      }
    }
  }
}

extension MoofuslistView {
  struct MoofuslistHeaderView: View {
    @State private var displayProfile = false

    var body: some View {
      VStack(spacing: 10) {
        Text("Moofuslist")
          .font(.system(size: 42, weight: .bold, design: .serif))
          .foregroundColor(.accent)

        Text("Where will you explore today?")
          .font(.headline)
          .foregroundColor(.secondary)
      }
      .sheet(isPresented: $displayProfile) {
        ProfileView()
      }
      .toolbar {
        ToolbarItem {
          Button {
            displayProfile = true
          } label: {
            Image(systemName: "person.fill")
              .foregroundStyle(.accent)
          }
        }
      }
      .toolbarTitleDisplayMode(.inline)
    }
  }
}

#Preview {
  MoofuslistView()
}
