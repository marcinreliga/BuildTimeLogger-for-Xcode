//
//  XcodeDatabase+BuildHistoryEntry.swift
//  BuildTimeLogger
//
//  Created by Marcin Religa on 01/03/2017.
//  Copyright © 2017 Marcin Religa. All rights reserved.
//

import Foundation

extension XcodeDatabase {
	var buildHistoryEntry: BuildHistoryEntry {
		return BuildHistoryEntry(buildTime: buildTime, schemeName: schemeName, date: Date())
	}
}
