//
//  ProfileView.swift
//  moofuslist
//
//  Created by Lamar Williams III on 1/28/26.
//

import SwiftUI

struct ProfileView: View {
    var body: some View {
        ZStack {
            Color(red: 0.98, green: 0.98, blue: 0.99).ignoresSafeArea()

            VStack(spacing: 0) {
                // Profile Header
                VStack(spacing: 16) {
                    Circle()
                    .fill(.accent.opacity(0.2))
                        .overlay(
                            Image(systemName: "person.fill")
                              .fontSizeForegroundStyle(size: 40, color: .accent)
                        )
                        .frame(width: 80, height: 80)

                    VStack(spacing: 4) {
                        Text("Sarah Johnson")
                        .fontSizeWeightForegroundStyle(size: 20, weight: .bold, color: .black)
                        Text("San Francisco, CA")
                        .fontSizeForegroundStyle(size: 14, color: .gray)
                    }
                }
                .padding(24)
                .background(Color.white)

                ScrollView {
                    VStack(spacing: 16) {
                        // Stats
                        HStack(spacing: 16) {
                            StatCard(icon: "heart.fill", count: "12", label: "Favorites")
                            StatCard(icon: "mappin.circle.fill", count: "28", label: "Visited")
                            StatCard(icon: "star.fill", count: "4.7", label: "Avg Rating")
                        }
                        .padding(16)

                        // Settings Section
                        VStack(spacing: 12) {
                            ProfileButton(icon: "location.fill", label: "Saved Locations", value: "3")
                            ProfileButton(icon: "bell.fill", label: "Notifications", value: "On")
                            ProfileButton(icon: "gearshape.fill", label: "Settings", value: nil)
                            ProfileButton(icon: "questionmark.circle.fill", label: "Help & Support", value: nil)
                            ProfileButton(icon: "arrow.right.square.fill", label: "Logout", value: nil)
                        }
                        .padding(16)
                    }
                }
            }
        }
    }
}

// MARK: - Stat Card
struct StatCard: View {
    let icon: String
    let count: String
    let label: String

    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
            .fontSizeForegroundStyle(size: 20, color: .accent)
            Text(count)
            .fontSizeWeightForegroundStyle(size: 18, weight: .bold, color: .black)
            Text(label)
            .fontSizeForegroundStyle(size: 12, color: .gray)
        }
        .frame(maxWidth: .infinity)
        .padding(16)
        .background(Color.white)
        .cornerRadius(12)
    }
}

// MARK: - Profile Button
struct ProfileButton: View {
    let icon: String
    let label: String
    let value: String?

    var body: some View {
        HStack {
          Image(systemName: icon)
            .fontSizeWeightForegroundStyle(size: 16, weight: .semibold, color: .accent)
            .frame(width: 24)

            Text(label)
            .fontSizeWeightForegroundStyle(size: 16, weight: .medium, color: .black)

            Spacer()

            if let value = value {
                Text(value)
                .fontSizeForegroundStyle(size: 14, color: .gray)
            }

            Image(systemName: "chevron.right")
            .fontSizeWeightForegroundStyle(size: 14, weight: .semibold, color: .gray)
        }
        .padding(16)
        .background(Color.white)
        .cornerRadius(12)
    }
}



#Preview {
    ProfileView()
}
