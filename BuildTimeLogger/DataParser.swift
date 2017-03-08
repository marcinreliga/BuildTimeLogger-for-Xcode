//
//  DataParser.swift
//  BuildTimeLogger
//
//  Created by Marcin Religa on 08/03/2017.
//  Copyright © 2017 Marcin Religa. All rights reserved.
//

import Foundation

struct DataParser {
	func parse(data: Data) {
		if let responseJSON = parseResponse(data: data) {
			var buildHistory: [BuildHistoryEntry] = []
			for entry in responseJSON {
				if let record = entry.value as? [String: String] {
					if let username = record["username"], let timestampStr = record["timestamp"], let timestamp = TimeInterval(timestampStr), let buildTimeStr = record["buildTime"], let buildTime = Int(buildTimeStr) {
						let buildHistoryEntry = BuildHistoryEntry(buildTime: buildTime, schemeName: "", date: Date(timeIntervalSince1970: timestamp), username: username)
						buildHistory.append(buildHistoryEntry)
					}
				}
			}

			let usernames = Set(buildHistory.flatMap({ $0.username }))

			for username in usernames {
				let entries = buildHistory.filter({
					if let u = $0.username, u == username  {
						return true
					}
					return false
				})

				let totalBuildsTime = entries.reduce(0, {
					return $0 + $1.buildTime
				})

				let totalBuildsTimeFormatted = TimeFormatter.format(time: totalBuildsTime)
				print("username: \(username), totalBuildsTime: \(totalBuildsTimeFormatted)")
			}
		}
	}

	private func parseResponse(data: Data) -> [String: Any]? {
		do {
			let json = try JSONSerialization.jsonObject(with: data, options: [])

			if let responseData = json as? [String: Any] {
				return responseData
			}
		} catch {
			print("JSON parsing error")
		}

		return nil
	}
}
