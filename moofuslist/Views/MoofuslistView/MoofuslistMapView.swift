//
//  MoofuslistMapView.swift
//  Moofuslist
//
//  Created by Lamar Williams III on 1/4/26.
//

import MapKit
import SwiftUI

struct MoofuslistMapView: View {
  var item: MKMapItem?
  @Binding var position: MapCameraPosition

  var body: some View {
    Map(position: $position) {
      if let item {
        Marker(item: item)
      }
    }
    .aspectRatio(1.0, contentMode: .fit)
    .clipShape(RoundedRectangle(cornerRadius: 30))
    .mapControlVisibility(.hidden)
  }
}

#Preview {
    @Previewable @State var position: MapCameraPosition = .region(
        MKCoordinateRegion(
            center: .init(latitude: 37.334, longitude: -122.009),
            span: .init(latitudeDelta: 0.01, longitudeDelta: 0.01)
        )
    )

    MoofuslistMapView(item: nil, position: $position)
        .padding()
}
