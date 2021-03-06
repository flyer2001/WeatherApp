//
//  DataBase.swift
//  weatherApp
//
//  Created by Sergey Popyvanov on 11.12.2019.
//  Copyright © 2019 Sergey Popyvanov. All rights reserved.
//

import Foundation
import RealmSwift
import Realm

let maximumCacheCount = 5  //максимальное количество хранимых в базе запросов

enum RealmFile : String {
    case file = "file.realm"
}

class DataBase {
    
    static let shared = DataBase()

    let realm : Realm
    
    
    static var fileManager: FileManager = {
        return FileManager.default
    }()
    
    static var documentDirectoryURL: URL = {
        return fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
    }()
    
    public static func openRealm(_ file: RealmFile) -> Realm {
        var realm: Realm? = nil
        let realmURL = documentDirectoryURL.appendingPathComponent(file.rawValue, isDirectory: false)
        let configuration = realmConfiguration(fileURL: realmURL)
        do {
            realm = try Realm(configuration: configuration)
        } catch let error as NSError {
            print(error)
            removeOldFilesFromRealmAtURL(realmURL: realmURL)
            realm = try! Realm(configuration: realmConfiguration(fileURL: realmURL))
        }
       
        return realm!
    }
    
    init() {
        self.realm = Self.openRealm(.file)
    }
    
    private static func realmConfiguration(fileURL: URL) -> Realm.Configuration {
        let result = Realm.Configuration(
            fileURL: fileURL,
            inMemoryIdentifier: nil,
            encryptionKey: nil,
            readOnly: false,
            schemaVersion: 59,
            migrationBlock: nil,
            deleteRealmIfMigrationNeeded: false,
            objectTypes: nil)
        
        return result
    }

    //CRUD операции
    func getDataFromDB<T: Object> (ofType: T.Type) -> Results<T>{
        return DataBase.shared.realm.objects(T.self)
    }

    func delete<T: Object>(_ data: T.Type, filter: String) {
        let dayForecastToDelete = DataBase.shared.realm.objects(T.self).filter(filter)
        DataBase.shared.realm.beginWrite()
        DataBase.shared.realm.delete(dayForecastToDelete)
        try! DataBase.shared.realm.commitWrite()
    }
    
    func update(_ data: Object) {
        DataBase.shared.realm.beginWrite()
        DataBase.shared.realm.add(data, update: .all)
        try! DataBase.shared.realm.commitWrite()
    }
    
    private static  func removeOldFilesFromRealmAtURL(realmURL: URL) {
        let directory = realmURL.deletingLastPathComponent()
        let fileName = realmURL.deletingPathExtension().lastPathComponent
        do {
            let existFiles = try fileManager.contentsOfDirectory(
                at: directory,
                includingPropertiesForKeys: nil)
                .filter({
                    return $0.lastPathComponent.hasPrefix(fileName as String)
                })
            for oldFile in existFiles {
                try fileManager.removeItem(at: oldFile)
            }
        }
        catch let error as NSError {
            print(error)
        }
    }
}

