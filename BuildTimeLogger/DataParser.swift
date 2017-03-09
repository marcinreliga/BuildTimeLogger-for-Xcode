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
		guard let responseJSON = parseResponse(data: data) else {
			return
		}

		let buildHistory = parse(json: responseJSON)

		let allUsernames = Set(buildHistory.flatMap({ $0.username }))

		for username in allUsernames {
			let entries = buildHistory.filter({
				// TODO: Change username to be non-optional.
				if let u = $0.username, u == username  {
					return true
				}
				return false
			})

			let buildTimeToday = totalBuildsTime(for: buildEntriesFromToday(in: entries))
			let buildTime = totalBuildsTime(for: entries)

			let buildTimeTodayFormatted = TimeFormatter.format(time: buildTimeToday)
			let totalBuildsTimeFormatted = TimeFormatter.format(time: buildTime)

			print("username: \(username), totalBuildsTimeToday: \(buildTimeTodayFormatted)")
			print("username: \(username), totalBuildsTime: \(totalBuildsTimeFormatted)\n")
		}
	}

	func buildEntriesFromToday(in buildHistoryData: [BuildHistoryEntry]) -> [BuildHistoryEntry] {
		return buildHistoryData.filter({
			Calendar.current.isDateInToday($0.date)
		})
	}

	func totalBuildsTime(for buildHistoryData: [BuildHistoryEntry]) -> Int {
		return buildHistoryData.reduce(0, {
			return $0 + $1.buildTime
		})
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

	private func parse(json: [String: Any]) -> [BuildHistoryEntry] {
		return json.flatMap({
			guard let record = $0.value as? [String: String] else {
				return nil
			}

			guard let username = record["username"], let timestampStr = record["timestamp"], let timestamp = TimeInterval(timestampStr), let buildTimeStr = record["buildTime"], let buildTime = Int(buildTimeStr) else {
				return nil
			}

			return BuildHistoryEntry(buildTime: buildTime, schemeName: "", date: Date(timeIntervalSince1970: timestamp), username: username)
		})
	}
}
