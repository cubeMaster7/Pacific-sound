//
//  RealmModel.swift
//  firstApp
//
//  Created by Paul James on 31.10.2023.
//

import Foundation
import RealmSwift

class RealmModel: Object {
    @Persisted var name: String = ""
    @Persisted var image: String = ""
    @Persisted var sound: String = ""
    @Persisted var isFavorite: Bool = false
}
