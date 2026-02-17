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
  @Environment(\.scenePhase) private var scenePhase
  @Injected(\.moofuslistViewModel) var viewModel: MoofuslistViewModel

  var body: some View {
    @Bindable var moofuslistCoordinator = moofuslistCoordinator
    @Bindable var viewModel = viewModel

    NavigationSplitView(preferredCompactColumn: $moofuslistCoordinator.splitViewColum) {
      MoofuslistSideBarView(viewModel: viewModel)
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

#Preview {
  MoofuslistView()
}
