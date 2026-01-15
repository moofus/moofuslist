//
//  StringsExtensions.swift
//  Explorer
//
//  Created by Lamar Williams III on 1/10/26.
//

import Foundation

extension String {
  func validateTwoStringsSeparatedByComma() -> Bool {
    let components = self.components(separatedBy: ",")
      .map { $0.trimmingCharacters(in: .whitespaces) }
      .filter { !$0.isEmpty }
    return components.count == 2
  }
}
