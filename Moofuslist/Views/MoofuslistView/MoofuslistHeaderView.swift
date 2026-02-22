//
//  MoofuslistHeaderView.swift
//  moofuslist
//
//  Created by Lamar Williams III on 2/17/26.
//

import FactoryKit
import MapKit
import SwiftUI

struct MoofuslistHeaderView: View {
  @State private var displayProfile = false

  var body: some View {
    VStack(spacing: 10) {
      Text("Moofuslist")
        .font(.system(size: 42, weight: .bold, design: .serif))
        .foregroundColor(.accent)

      Text("Where will you explore today?")
        .font(.headline)
        .foregroundColor(.secondary)
    }
    .sheet(isPresented: $displayProfile) {
      ProfileView()
    }
    .toolbar {
      ToolbarItem {
        Button {
          displayProfile = true
        } label: {
          Image(systemName: "person.fill")
            .foregroundStyle(.accent)
        }
      }
    }
    .toolbarTitleDisplayMode(.inline)
  }
}

#Preview {
  NavigationStack {
    MoofuslistHeaderView()
  }
}
