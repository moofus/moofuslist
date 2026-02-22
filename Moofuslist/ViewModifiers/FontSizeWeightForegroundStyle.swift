//
//  FontSizeWeightForegroundStyle.swift
//  moofuslist
//
//  Created by Lamar Williams III on 1/29/26.
//

import SwiftUI

struct FontSizeWeightForegroundStyle: ViewModifier {
  let size: Double
  let weight: Font.Weight
  let color: Color

  func body(content: Content) -> some View {
    content
      .font(.system(size: size, weight: weight))
      .foregroundStyle(color)
  }
}

extension View {
  func fontSizeWeightForegroundStyle(size: Double, weight: Font.Weight, color: Color) -> some View {
    modifier(FontSizeWeightForegroundStyle(size: size, weight: weight, color: color))
  }
}
