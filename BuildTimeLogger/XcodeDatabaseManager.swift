//
//  XcodeDatabaseManager.swift
//  BuildTimeLogger
//
//  Created by Marcin Religa on 08/03/2017.
//  Copyright © 2017 Marcin Religa. All rights reserved.
//

import Foundation

struct XcodeDatabaseManager {
	var latestBuildData: XcodeDatabase? {
		let dataSource = DerivedDataManager.derivedData().flatMap{
			XcodeDatabase(fromPath: $0.url.appendingPathComponent("Logs/Build/Cache.db").path)
			}.sorted(by: { $0.modificationDate > $1.modificationDate })

//		for db in dataSource {
//			print("date: \(db.modificationDate), scheme: \(db.schemeName)")
//		}

		// TODO: check for correct build.
		guard let latestBuildDatabase = dataSource.first else {
			return nil
		}

		return latestBuildDatabase
	}
}
