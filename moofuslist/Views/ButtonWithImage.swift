//
//  ButtonWithImage.swift
//  moofuslist
//
//  Created by Lamar Williams III on 12/23/25.
//

import SwiftUI

struct ButtonWithImage: View {
  private var action: (() -> ())?
  private var systemName: String
  private var text: String

  init(text: String,
       foregroundStyle: Color = .white,
       systemName: String,
       action: (() -> ())? = nil
  ) {
    self.action = action
    self.systemName = systemName
    self.text = text
  }

  var body: some View {
    Button {
      action?()
    } label: {
        Label(text, systemImage: systemName)
          .font(.title3)
          .foregroundStyle(.gray)
          .padding(.all, 10)
    }
    .buttonStyle(.glass)
  }
}

#Preview {
  ButtonWithImage(text: "Search City, State or Zip...", systemName: "magnifyingglass")
}
