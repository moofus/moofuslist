//
//  File.swift
//  moofuslist
//
//  Created by Lamar Williams III on 1/29/26.
//

import Foundation
import SwiftUI

struct FontSizeForegroundStyle: ViewModifier {
  let size: Double
  let color: Color

  func body(content: Content) -> some View {
    content
      .font(.system(size: size))
      .foregroundStyle(color)
  }
}

extension View {
  func fontSizeForegroundStyle(size: Double, color: Color) -> some View {
      modifier(FontSizeForegroundStyle(size: size, color: color))
  }
}
