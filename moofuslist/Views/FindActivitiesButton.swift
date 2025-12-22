//
//  FindActivitiesButton.swift
//  Explorer
//
//  Created by Lamar Williams III on 12/21/25.
//

import SwiftUI

struct FindActivitiesButton: View {
  private var cornerRadius: Double
  private var displayOnLeft: Bool
  private var displayOnRight: Bool

  init(cornerRadius: Double = 10.0, displayOnLeft: Bool = false, displayOnRight: Bool = false) {
    self.cornerRadius = cornerRadius
    self.displayOnLeft = displayOnLeft
    self.displayOnRight = displayOnRight
  }

  var body: some View {
    Button {
      print("button ")
    } label: {
      HStack {
        Color.clear
          .overlay {
            HStack {
              Spacer()
              if displayOnLeft {
                GPSPinView()
              }
            }
          }

        Text("Find Nearby Activities")
          .font(.title3)
          .fixedSize(horizontal: true, vertical: false)

        Color.clear
          .overlay {
            HStack {
              if displayOnRight{
                GPSPinView()
              }
              Spacer()
            }
          }
      }
      .padding(.all, 16)
    }
    .padding([.leading, .trailing])
//    .buttonStyle(.borderedProminent)
    .buttonStyle(.glassProminent)
    .buttonBorderShape(.roundedRectangle(radius: cornerRadius))
    .fixedSize(horizontal: false, vertical: true)
    .tint(.accent)
  }
}

#Preview {
    FindActivitiesButton()
}
