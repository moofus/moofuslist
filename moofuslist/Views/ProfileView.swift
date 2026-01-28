//
//  ProfileView.swift
//  moofuslist
//
//  Created by Lamar Williams III on 1/28/26.
//

import SwiftUI

struct ProfileView: View {
    let themeColor = Color(red: 255/255, green: 129/255, blue: 66/255)

    var body: some View {
        ZStack {
            Color(red: 0.98, green: 0.98, blue: 0.99).ignoresSafeArea()

            VStack(spacing: 0) {
                // Profile Header
                VStack(spacing: 16) {
                    Circle()
                        .fill(themeColor.opacity(0.2))
                        .overlay(
                            Image(systemName: "person.fill")
                                .font(.system(size: 40))
                                .foregroundColor(themeColor)
                        )
                        .frame(width: 80, height: 80)

                    VStack(spacing: 4) {
                        Text("Sarah Johnson")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(.black)
                        Text("San Francisco, CA")
                            .font(.system(size: 14))
                            .foregroundColor(.gray)
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
    let themeColor = Color(red: 255/255, green: 129/255, blue: 66/255)

    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundColor(themeColor)
            Text(count)
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(.black)
            Text(label)
                .font(.system(size: 12))
                .foregroundColor(.gray)
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
    let themeColor = Color(red: 255/255, green: 129/255, blue: 66/255)

    var body: some View {
        HStack {
            Image(systemName: icon)
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(themeColor)
                .frame(width: 24)

            Text(label)
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(.black)

            Spacer()

            if let value = value {
                Text(value)
                    .font(.system(size: 14))
                    .foregroundColor(.gray)
            }

            Image(systemName: "chevron.right")
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(.gray)
        }
        .padding(16)
        .background(Color.white)
        .cornerRadius(12)
    }
}

