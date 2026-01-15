//
//  FindActivitiesButton.swift
//  Moofuslist
//
//  Created by Lamar Williams III on 12/21/25.
//

import SwiftUI

struct FindActivitiesButton: View {
  private var action: (() async -> ())?
  private var text: String // ljw hardcode? localize

  init(text: String,
       padding: Double = 16,
       action: (() -> ())? = nil
  ) {
    self.action = action
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
          .padding(10)
      } icon: {
        GPSPinView()
      }
      .padding(10)
    }
    .buttonStyle(.glassProminent)
  }
}

#Preview {
  FindActivitiesButton(text: "Find Nearby Activities")
}
