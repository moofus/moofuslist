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
  @Injected(\.appCoordinator) var appCoordinator: AppCoordinator
  @State private var searchText: String = ""
  @Injected(\.moofuslistSource) var source: MoofuslistSource
  @Injected(\.moofuslistViewModel) var viewModel: MoofuslistViewModel

  var body: some View {
    @Bindable var appCoordinator = appCoordinator
    @Bindable var viewModel = viewModel

    NavigationSplitView(preferredCompactColumn: $appCoordinator.splitViewColum) {
      VStack {
        MoofuslistHeaderView()

        MoofuslistMapView(item: viewModel.mapItem, position: $viewModel.mapPosition)

        FindActivitiesButton(text: "Search Current Location", padding: 5) {
          searchText = ""
          source.searchCurrentLocation()
        }

        if viewModel.processing {
          ProgressView()
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
