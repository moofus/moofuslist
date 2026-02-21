//
//  FindActivitiesButton.swift
//  Moofuslist
//
//  Created by Lamar Williams III on 12/21/25.
//

import SwiftUI

struct GPSPinButton: View {
  private let action: (() async -> Void)?
  private let padding: Double
  private let text: String

  init(text: String, padding: Double = 16, action: (() -> Void)? = nil) {
    self.action = action
    self.padding = padding
    self.text = text
  }

  var body: some View {
    Button {
      Task {
        await action?()
      }
    } label: {
      Label {
        Text(text)
          .font(.title3)
          .padding(padding)
      } icon: {
        GPSPinView()
      }
    }
    .buttonStyle(.glassProminent)
  }
}

#Preview {
  GPSPinButton(text: "Find Nearby Activities", padding: 5)
}
