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

    let _ = print("isProcessing=\(viewModel.isProcessing)")

    NavigationSplitView(preferredCompactColumn: $appCoordinator.splitViewColum) {
      VStack {
        MoofuslistHeaderView()

        MoofuslistMapView(displayButton: !viewModel.isProcessing, item: viewModel.mapItem, position: $viewModel.mapPosition) {
          source.searchCurrentLocation()
        }

        Spacer()

        Label {
          Text("Using Apple Intelligent")
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
      let _ = print("ljw \(Date()) \(#file):\(#function):\(#line)")
      MoofuslistContentView(source: source, viewModel: viewModel)
    } detail: {
      let _ = print("ljw \(Date()) \(#file):\(#function):\(#line)")
      if let idx = viewModel.selectedIdx {
        MoofuslistDetailView(activity: $viewModel.activities[idx])
      } else {
        EmptyView()
      }
    }
    .disabled(viewModel.isProcessing)
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
    var body: some View {

      VStack(spacing: 10) {
        Text("Moofuslist")
          .font(.system(size: 42, weight: .bold, design: .serif))
          .foregroundColor(.accent)

        Text("Where will you explore today?")
          .font(.headline)
          .foregroundColor(.secondary)
      }
      .toolbar {
        ToolbarItem {
          Button {
            print("pushed profile")
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
