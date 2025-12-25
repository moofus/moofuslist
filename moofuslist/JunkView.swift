//
//  JunkView.swift
//  moofuslist
//
//  Created by Lamar Williams III on 12/24/25.
//

import SwiftUI

struct JunkView: View {
  @Environment(LocationManager.self) var locationManager
  @State var test = false

    var body: some View {
      GroupBox(label: Label("Settings", systemImage: "gear")) {
        Text("Option 1")
        @Bindable var locationManager = locationManager
        Toggle("Location Services", isOn: $locationManager.started)
        Toggle("test", isOn: $test)
      }
      .padding()
      Group {
          Text("Item 1")
          Text("Item 2")
      }
      .font(.headline) // Applies to all items
      .foregroundColor(.blue)

    }
}

#Preview {
    JunkView()
}
