//
//  MoofuslistView.swift
//  Explorer
//
//  Created by Lamar Williams III on 12/21/25.
//

import MapKit
import SwiftUI

struct MoofuslistView: View {
  @Environment(LocationManager.self) var locationManager
  //  @State var searchText = ""

  var body: some View {
    @Bindable var locationManager = locationManager

    NavigationSplitView {
      VStack {
        HeaderView()
        ZStack {
          Map()
            .aspectRatio(1.0, contentMode: .fit)
            .clipShape(RoundedRectangle(cornerRadius: 30))
          FindActivitiesButton(text: "Find Nearby Activities") {
            locationManager.started = true
          }
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
    .alert(isPresented: $locationManager.haveError, error: locationManager.error) { _ in
      Button("OK") {
        locationManager.stop()
      }
    } message: { error in
      Text(error.recoverySuggestion ?? "Try again later.")
    }
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

}

#Preview {
  MoofuslistView()
    .environment(LocationManager())
}
