//
//  MoofuslistMapView.swift
//  Moofuslist
//
//  Created by Lamar Williams III on 1/4/26.
//


import FactoryKit
import MapKit
import SwiftUI

struct MoofuslistMapView: View {
  let displayButton: Bool
  var item: MKMapItem?
  @Binding var position: MapCameraPosition
  let action: (() -> ())?

  var body: some View {
    VStack {
      Map(position: $position) {
        if let item {
          Marker(item: item)
        }
      }
      .aspectRatio(1.0, contentMode: .fit)
      .clipShape(RoundedRectangle(cornerRadius: 30))
      .mapControlVisibility(.hidden)

      if displayButton {
        FindActivitiesButton(text: "Search Current Location", padding: 5) {
          action?()
        }
      }
    }
  }
}


#Preview {
  MoofuslistMapView(displayButton: true, item: nil, position: .constant(.automatic), action: nil)
}
