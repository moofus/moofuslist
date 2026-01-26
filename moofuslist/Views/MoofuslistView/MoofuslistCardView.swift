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
  @Binding var activity: MoofuslistViewModel.Activity
  var source: MoofuslistSource

  var body: some View {
    VStack(alignment: .leading, spacing: 12) {
      HStack(spacing: 12) {
        Image(systemName: activity.imageNames[0])
          .font(.system(size: 32))
          .foregroundColor(.accent)
          .frame(width: 60, height: 60)
          .background(Color(red: 1, green: 0.9, blue: 0.8))
          .cornerRadius(12)

        VStack(alignment: .leading, spacing: 4) {
          Text(activity.name)
            .font(.system(size: 16, weight: .semibold))
            .foregroundColor(.black)

          HStack(spacing: 8) {
            Image(systemName: "star.fill")
              .font(.system(size: 12))
              .foregroundColor(.orange)
            Text("\(String(format: "%.1f", activity.rating)) (\(activity.reviews))")
              .font(.system(size: 12, weight: .medium))
              .foregroundColor(.gray)
          }

          HStack(spacing: 8) {
            Image(systemName: "location.fill")
              .font(.system(size: 10))
              .foregroundColor(.gray)
            Text("\(String(format: "%.1f", activity.distance)) mi away")
              .font(.system(size: 12))
              .foregroundColor(.gray)
          }
        }

        Spacer()

        Button {
          activity.isFavorite.toggle()
          source.favoriteChanged(activity: activity)
        } label: {
          Image(systemName: activity.isFavorite ? "heart.fill" : "heart")
            .font(.system(size: 18))
            .foregroundColor(activity.isFavorite ? .accent : .gray)
        }
      }

      Text(activity.address)
        .font(.system(size: 12))
        .foregroundColor(.gray)
    }
    .padding(12)
    .background(Color.white)
    .cornerRadius(12)
  }
}


