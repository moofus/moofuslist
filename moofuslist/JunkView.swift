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

import SwiftUI

struct BlinkingImageView: View {
  @State private var isVisible: Bool
  let blink: Bool
  let durationValue: Double
  let systemName: String

  init(blink: Bool, duration durationValue: Double = 0.5, isVisible: Bool = true, systemName: String) {
    self.blink = blink
    self.durationValue = durationValue
    self.isVisible = isVisible
    self.systemName = systemName
  }

  var body: some View {
    Image(systemName: systemName)
      .font(.system(size: 24))
      .foregroundColor(.accent)
      .opacity(isVisible ? 1 : 0)
      .animation(
        .linear(duration: duration).repeatForever(autoreverses: true),
        value: isVisible
      )
      .onAppear {
        isVisible.toggle()
      }
  }

  private var duration: Double {
    blink ? 0.5 : Double.infinity
  }
}

#Preview("BlinkingImageView") {
  BlinkingImageView(blink: true, systemName: "sparkles")
  BlinkingImageView(blink: false, systemName: "lightbulb.max.fill")
}
