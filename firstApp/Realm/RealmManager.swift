//
//  RealmManager.swift
//  firstApp
//
//  Created by Paul James on 31.10.2023.
//

import Foundation
import RealmSwift


class RealmManager {
    
    static let shared = RealmManager()
    
    private init() {
        
    }
    
    let localRealm = try! Realm()
    
    
    func saveModel(model: RealmModel) {
        try! localRealm.write{
            localRealm.add(model)
        }
    }
    
    func deleteModel(model: RealmModel){
        try! localRealm.write{
            localRealm.delete(model)
        }
    }
}
