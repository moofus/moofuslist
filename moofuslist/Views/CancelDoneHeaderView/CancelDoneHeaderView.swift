//
//  CancelDoneHeaderView.swift
//  moofuslist
//
//  Created by Lamar Williams III on 4/18/25.
//

import SwiftUI

struct CancelDoneHeaderView: View {
  let cancelAction: () -> Void
  let doneAction: () -> Void

  var body: some View {
    HStack {
      Button("Cancel", role: .cancel) {
        cancelAction()
      }

      Spacer()

      Button("Done") {
        doneAction()
      }
    }
    .padding()
  }
}

#Preview {
  CancelDoneHeaderView(cancelAction: {}, doneAction: {})
}
