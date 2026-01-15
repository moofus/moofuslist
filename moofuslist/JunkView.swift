//
//  JunkView.swift
//  moofuslist
//
//  Created by Lamar Williams III on 12/24/25.
//

import MapKit
import SwiftUI

struct JunkView: View {
  @State var mapItem: MKMapItem?

  var body: some View {

    Map {
      if let mapItem {
        Marker(item: mapItem)
      }
    }
    .task {
      let request = MKGeocodingRequest(
        addressString: "Stockton, CA"
//        addressString: "1 Ferry Building, San Francisco"
      )
      do {
        let str = LocalizedStringKey("the string")
        let _ = try await print("count=\(request?.mapItems.count)")
        mapItem = try await request?.mapItems.first
        print("address \(mapItem?.address)")
        print("addressRepresentations \(mapItem?.addressRepresentations)")
        print("location \(mapItem?.location)")
      } catch {
        print("Error geocoding location: \(error)")
      }
    }
  }
}

#Preview {
  JunkView()
}
