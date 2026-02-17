//
//  SideBarView.swift
//  moofuslist
//
//  Created by Lamar Williams III on 2/17/26.
//

import FactoryKit
import MapKit
import SwiftUI

struct MoofuslistSideBarView: View {
    @State private var searchText: String = ""
    @Injected(\.moofuslistSource) var source: MoofuslistSource
    @Bindable var viewModel: MoofuslistViewModel

    var body: some View {
      ScrollView {
        VStack {
          MoofuslistHeaderView()

          MoofuslistMapView(item: viewModel.mapItem, position: $viewModel.mapPosition)
            .padding()
            .frame(minWidth: 300, maxWidth: 400, minHeight: 300, maxHeight: 400)

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
      }
      .searchable(text: $searchText, prompt: "Search City, State, or Zip")
      .onSubmit(of: .search) {
        source.searchCityState(searchText)
      }

    }
  }
