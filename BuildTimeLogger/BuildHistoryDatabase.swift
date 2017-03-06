//
//  BuildHistoryDatabase.swift
//  BuildTimeLogger
//
//  Created by Marcin Religa on 01/03/2017.
//  Copyright © 2017 Marcin Religa. All rights reserved.
//

import Foundation

struct BuildHistoryDatabase {
	func save(history: [BuildHistoryEntry]) {
		let historySerialized = history.map({ $0.serialized })
		UserDefaults.standard.set(historySerialized, forKey: "buildHistory")
	}

	func read() -> [BuildHistoryEntry]? {
		guard let buildHistorySerialized = UserDefaults.standard.object(forKey: "buildHistory") as? [[String: Any]] else {
			return nil
		}

		let buildHistory: [BuildHistoryEntry] = buildHistorySerialized.flatMap({
			if let buildTime = $0["buildTime"] as? Int,
				let schemeName = $0["schemeName"] as? String,
				let timestamp = $0["timestamp"] as? TimeInterval {
				return BuildHistoryEntry(buildTime: buildTime, schemeName: schemeName, date: Date(timeIntervalSince1970: timestamp))
			}

			return nil
		})

		return buildHistory
	}
}
