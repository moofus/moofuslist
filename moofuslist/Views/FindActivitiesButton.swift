//
//  FindActivitiesButton.swift
//  Moofuslist
//
//  Created by Lamar Williams III on 12/21/25.
//

import SwiftUI

struct FindActivitiesButton: View {
  private let action: (() async -> ())?
  private let padding: Double
  private let text: String // ljw hardcode? localize

  init(text: String,
       padding: Double = 16,
       action: (() -> ())? = nil
  ) {
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
  FindActivitiesButton(text: "Find Nearby Activities", padding: 5)
}
