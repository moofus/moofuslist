//
//  MoofuslistView.swift
//  Explorer
//
//  Created by Lamar Williams III on 12/21/25.
//

import MapKit
import SwiftUI

struct MoofuslistView: View {

  var body: some View {
    NavigationSplitView {
      VStack {
        Text("Activities & Places to Explore")
          .font(.title2)
          .navigationBarTitleDisplayMode(.inline)
          .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
              Text("Moofuslist")
                .font(.system(size: 40))
                .bold()
                .foregroundColor(.accent)
                .fixedSize()
            }
            .sharedBackgroundVisibility(.hidden)

            ToolbarItem {
              Image(systemName: "person.fill")
                .foregroundStyle(.accent)
            }
          }
          .frame(maxWidth: .infinity, alignment: .leading)

        ZStack {
          Map()
            .aspectRatio(1.0, contentMode: .fit)
            .clipShape(RoundedRectangle(cornerRadius: 30))
          FindActivitiesButton(cornerRadius: 40, displayOnLeft: true)
            .padding([.leading, .trailing])
        }

        Spacer()
      }
      .safeAreaPadding([.leading, .trailing])
    } detail: {
      Image(systemName: "globe")
        .imageScale(.large)
        .foregroundStyle(.tint)
      Text("Detail")
        .navigationTitle("Moofuslist")
    }
  }

  struct NavigationHeaderView: View {
    var body: some View {
      Text("Activities & Places to Explore")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
          ToolbarItem(placement: .navigationBarLeading) {
            Text("Explore")
              .font(.largeTitle)
              .bold()
              .foregroundColor(.accent)
              .fixedSize()
          }
          .sharedBackgroundVisibility(.hidden)

          ToolbarItem {
            Image(systemName: "person.fill")
              .foregroundStyle(.accent)
          }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
      Spacer()
    }
  }
}

#Preview {
  MoofuslistView()
}
