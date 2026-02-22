//
//  GPSPinView.swift
//  Moofuslist
//
//  Created by Lamar Williams III on 12/21/25.
//

import SwiftUI

struct GPSPinView: View {
  var body: some View {
    ZStack {
      Image(systemName: "drop.fill")
        .imageScale(.large)
        .rotationEffect(.degrees(180))
        .foregroundStyle(.white)
      Image(systemName: "circle.fill")
        .offset(x: 0, y: -3)
        .font(.system(size: 6))
        .foregroundStyle(.accent)
    }
  }
}

#Preview {
  GPSPinView()
    .background(Color.accentColor)
}
