//
//  MoofuslistView.swift
//  Explorer
//
//  Created by Lamar Williams III on 12/21/25.
//

import FactoryKit
import MapKit
import SwiftUI

struct MoofuslistView: View {
  @Injected(\.moofuslistSource) var source: MoofuslistSource
  @Injected(\.moofuslistViewModel) var viewModel: MoofuslistViewModel

  @State var item: MKMapItem?
  @State private var isPerformingTask = false

  var body: some View {
    NavigationSplitView {
      VStack {
        HeaderView()
        ZStack {
          Map() {
            if let item {
              Marker(item: item)
            }
          }
          .aspectRatio(1.0, contentMode: .fit)
          .clipShape(RoundedRectangle(cornerRadius: 30))
//          .mapControlVisibility(.hidden)
          FindActivitiesButton(text: "Find Nearby Activities") {
            Task {
              isPerformingTask = true
              await source.findActivities()
              isPerformingTask = false
            }
          }
          .disabled(isPerformingTask)
        }

        ButtonWithImage(text: "Search City, State, or Zip...", systemName: "magnifyingglass") {
          print("pushed search")
        }
        .padding(.top)

        Spacer()
      }
      .safeAreaPadding([.leading, .trailing])
    } detail: {
      Image(systemName: "globe")
        .imageScale(.large)
        .foregroundStyle(.tint)
      Text("Detail")
        .navigationTitle("Moofuslist")
    }
//    .alert(isPresented: $locationManager.haveError, error: locationManager.error) { _ in
//      Button("OK") {
//        locationManager.stop()
//      }
//    } message: { error in
//      Text(error.recoverySuggestion ?? "Try again later.")
//    }
  }

  struct HeaderView: View {
    var body: some View {
      Text("Activities & Places to Explore")
        .font(.title2)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
          ToolbarItem(placement: .navigationBarLeading) {
            Text("Moofuslist")
              .font(.system(size: 40))
              .bold()
              .foregroundColor(.accent)
              .fixedSize()
          }
          .sharedBackgroundVisibility(.hidden)

          ToolbarItem {
            Button {
              print("pushed profile")
            } label: {
              Image(systemName: "person.fill")
                .foregroundStyle(.accent)
            }
          }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
  }

  private func item(from location: CLLocation) async -> MKMapItem? {
    if let request = MKReverseGeocodingRequest(location: location) {
        let mapitems = try? await request.mapItems
        if let mapitem = mapitems?.first {
          return mapitem
        }
    }
    return nil
  }
}

#Preview {
  MoofuslistView()
}
