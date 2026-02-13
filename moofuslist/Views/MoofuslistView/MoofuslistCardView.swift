//
//  ActivityCardView.swift
//  Moofuslist
//
//  Created by Lamar Williams III on 1/7/26.
//


import FactoryKit
import MapKit
import SwiftUI

struct MoofuslistCardView: View {
  let activity: MoofuslistActivity

  @Injected(\.moofuslistSource) var source: MoofuslistSource

  var body: some View {
    VStack(alignment: .leading, spacing: 12) {
      HStack(spacing: 12) {
        Image(systemName: activity.imageNames[0])
          .fontSizeForegroundStyle(size: 32, color: .accent)
          .frame(width: 60, height: 60)
          .background(Color(red: 1, green: 0.9, blue: 0.8))
          .cornerRadius(12)

        VStack(alignment: .leading, spacing: 4) {
          Text(activity.name)
            .fontSizeWeightForegroundStyle(size: 16, weight: .semibold, color: .black)

          HStack(spacing: 8) {
            Image(systemName: "star.fill")
              .fontSizeForegroundStyle(size: 12, color: .orange)
            Text("\(String(format: "%.1f", activity.rating)) (\(activity.reviews))")
              .fontSizeWeightForegroundStyle(size: 12, weight: .medium, color: .gray)
          }

          HStack(spacing: 8) {
            Image(systemName: "location.fill")
              .fontSizeForegroundStyle(size: 10, color: .gray)
            Text("\(String(format: "%.1f", activity.distance)) mi away")
              .fontSizeForegroundStyle(size: 12, color: .gray)
          }
        }

        Spacer()

        Button {
          source.setFavorite(id: activity.id, value: !activity.isFavorite)
        } label: {
          Image(systemName: activity.isFavorite ? "heart.fill" : "heart")
            .fontSizeForegroundStyle(size: 18, color: activity.isFavorite ? .accent : .gray)
        }
      }

      Text(activity.address)
        .fontSizeForegroundStyle(size: 12, color: .gray)
    }
    .padding(12)
    .background(Color.white)
    .cornerRadius(12)
  }
}


