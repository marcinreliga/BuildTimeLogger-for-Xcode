//
//  BuildHistoryDatabase.swift
//  BuildTimeLogger
//
//  Created by Marcin Religa on 01/03/2017.
//  Copyright © 2017 Marcin Religa. All rights reserved.
//

import Foundation

enum BuildHistoryDatabaseKey: String {
	case buildHistory
}

struct BuildHistoryDatabase {
	func save(history: [BuildHistoryEntry]) {
		let historySerialized = history.map({ $0.serialized })
		UserDefaults.standard.set(historySerialized, forKey: BuildHistoryDatabaseKey.buildHistory.rawValue)
	}

	func read() -> [BuildHistoryEntry]? {
		guard let buildHistorySerialized = UserDefaults.standard.object(forKey: BuildHistoryDatabaseKey.buildHistory.rawValue) as? [[String: Any]] else {
			return nil
		}

		let buildHistory: [BuildHistoryEntry] = buildHistorySerialized.flatMap({
			if let buildTime = $0[BuildHistoryEntryKey.buildTime.rawValue] as? Int,
				let schemeName = $0[BuildHistoryEntryKey.schemeName.rawValue] as? String,
				let timestamp = $0[BuildHistoryEntryKey.timestamp.rawValue] as? TimeInterval {

				// TODO: Old entries in user defaults don't have username, so this stays as not required here.
				let username = $0[BuildHistoryEntryKey.username.rawValue] as? String ?? "unknown"
				return BuildHistoryEntry(buildTime: buildTime, schemeName: schemeName, date: Date(timeIntervalSince1970: timestamp), username: username)
			}

			return nil
		})

		return buildHistory
	}
}
