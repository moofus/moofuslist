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
  let item: MKMapItem?
  let action: (() -> ())?

  init(displayButton: Bool, item: MKMapItem?, action: (() -> Void)?) {
    self.displayButton = displayButton
    self.item = item
    self.action = action
  }


  var body: some View {
    Map {
      if let item {
        Marker(item: item)
      }
    }
    .aspectRatio(1.0, contentMode: .fit)
    .clipShape(RoundedRectangle(cornerRadius: 30))
    .mapControlVisibility(.hidden)
    .overlay {
      if displayButton {
        FindActivitiesButton(text: "Search Current Location") {
          action?()
        }
      }
    }
  }
}
