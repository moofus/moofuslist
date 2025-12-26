//
//  JunkView.swift
//  moofuslist
//
//  Created by Lamar Williams III on 12/24/25.
//

import SwiftUI

struct JunkView: View {
  @Environment(LocationManager.self) var locationManager
  @State private var test = false

  var body: some View {
    @Bindable var locationManager = locationManager

    VStack {
      GroupBox(label: Label("Settings", systemImage: "gear")) {
        Text("Option 1")
        Toggle("Location Services", isOn: $locationManager.started)
        Toggle("test", isOn: $test)
      }
      .font(.headline)
      .padding()
    }
    .alert(isPresented: $locationManager.haveError, error: locationManager.error) { _ in
      Button("OK") {
        locationManager.stop()
      }
    } message: { error in
      Text(error.recoverySuggestion ?? "Try again later.")
    }
  }
}

#Preview {
  JunkView()
    .environment(LocationManager())
}
