//
//  Protocols.swift
//  Flow_PhotoAlbum_Hoon
//
//  Created by hoonsbrand on 2023/01/03.
//

import Foundation

/// Reusable Cell Identifier를 보다 안전한 방법으로 사용하기 위한 프로토콜
protocol ReusableView {
    static var reuseIdentifier: String { get }
}
