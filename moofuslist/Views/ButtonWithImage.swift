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
  @State private var textValue: String = ""

  init(text: String,
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
      print("ljw action")
    } label: {
      HStack {
        Image(systemName: systemName)
        TextField(text, text: $textValue)
      }
      .font(.title3)
      .padding(.all, 10)
      .fixedSize()
    }
    .buttonStyle(.glass)
  }
}

#Preview {
  ButtonWithImage(text: "Search City, State or Zip...", systemName: "magnifyingglass")
}
