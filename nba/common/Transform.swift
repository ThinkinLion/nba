//
//  Transform.swift
//  nba
//
//  Created by 1100690 on 4/18/24.
//

import Foundation
import SwiftUI

struct Transform {
  /*
   이 함수는 teamId의 마지막 숫자를 가져와서 각 자리수에 더한 후 1의 자리 숫자만을 사용하여 변환합니다. 만약 teamId가 비어 있거나 마지막 숫자를 가져올 수 없다면 입력된 teamId를 그대로 반환합니다.
   ex)
   1610 6127 37 >> 8387 3894 04
   1610 6127 38 >> 9498 4905 16
   1610 6127 66 >> 7376 2793 22
   */
  static func transformTeamId(_ teamId: String) -> String {
      // teamId의 마지막 숫자를 가져옵니다.
      guard let lastDigit = teamId.last, let lastDigitValue = Int(String(lastDigit)) else {
          // teamId가 비어있거나 마지막 숫자를 가져올 수 없으면 원래의 teamId를 반환합니다.
          return teamId
      }

      // teamId의 각 자리수에 마지막 숫자를 더한 후, 1의 자리 숫자만을 사용합니다.
      let transformedDigits = teamId.map { char -> Character in
          guard let digit = Int(String(char)) else { return char }
          let transformedDigit = (digit + lastDigitValue) % 10
          return Character(String(transformedDigit))
      }

      // 변환된 숫자들을 문자열로 결합하여 반환합니다.
      return String(transformedDigits)
  }

  static func randomColors(_ index: Int) -> [Color] {
      guard index >= 0, index < 10 else { return [Color("#EBC67C"), Color("#E4B25A")] }
      return [
          [Color("#EBC67C"), Color("#E4B25A")], //yellow
          [Color("#EC723D"), Color("#E24627")], //orange-red
          [Color("#9CD788"), Color("#75BD67")], //green
          [Color("#EC723D"), Color("#E24627")], //orange-red
          [Color("#93D9F2"), Color("#62C0E2")], //sky
          
          [Color("#A7E3BF"), Color("#74C893")], //green2
          [Color("#4981DE"), Color("#2E479F")], //blue
          [Color("#EF9781"), Color("#ED816F")], //red
          [Color("#F4B474"), Color("#EF974B")], //orange
          [Color("#A79CF6"), Color("#7E6BF3")], //violet
      ][index]
  }
}
