//
//  ErrorView.swift
//  moofuslist
//
//  Created by Lamar Williams III on 12/25/25.
//

import SwiftUI

struct ErrorView: View {
  @State var errorText: String
  private(set) var action: (() -> ())? = nil

  var body: some View {
    GroupBox {
      HStack {
        Image(systemName: "exclamationmark.triangle")
          .resizable()
          .frame(width: 50, height: 50)
        Text(errorText)
      }
      if let action {
        Button {
          action()
        } label: {
          Text("OK")
        }
      }
    }
    .padding(20)
    .cornerRadius(1)
  }
}

#Preview {
  ErrorView(errorText: "Some error")
}
