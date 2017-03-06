//
//  BuildHistoryEntry.swift
//  BuildTimeLogger
//
//  Created by Marcin Religa on 01/03/2017.
//  Copyright © 2017 Marcin Religa. All rights reserved.
//

import Foundation

struct BuildHistoryEntry {
	let buildTime: Int
	let schemeName: String
	let date: Date

	var serialized: [String: Any] {
		return [
			"buildTime": buildTime,
			"schemeName": schemeName,
			"timestamp": date.timeIntervalSince1970
		]
	}
}
