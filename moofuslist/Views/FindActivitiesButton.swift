//
//  FindActivitiesButton.swift
//  Explorer
//
//  Created by Lamar Williams III on 12/21/25.
//

import SwiftUI

struct FindActivitiesButton: View {
  private var action: (() -> ())?
  private var text: String

  init(text: String,
       padding: Double = 16,
       action: (() -> ())? = nil
  ) {
    self.action = action
    self.text = text
  }

  var body: some View {
    Button {
      action?()
    } label: {
      Label {
        Text(text)
          .font(.title3)
          .padding(.all, 10)
      } icon: {
        GPSPinView()
      }
      .padding(.all, 10)
    }
    .buttonStyle(.glassProminent)
  }
}

#Preview {
  FindActivitiesButton(text: "Find Nearby Activities")
}
