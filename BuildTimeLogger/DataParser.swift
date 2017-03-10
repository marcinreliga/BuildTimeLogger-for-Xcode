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
			let entries = buildHistory.filter({ $0.username == username })

			let buildTimeTotalToday = totalBuildTime(for: buildEntriesFromToday(in: entries))
			let buildTimeTotal = totalBuildTime(for: entries)

			let buildTimeTotalTodayFormatted = TimeFormatter.format(time: buildTimeTotalToday)
			let buildTimeTotalFormatted = TimeFormatter.format(time: buildTimeTotal)

			print("username: \(username)\nbuild time today: \(buildTimeTotalTodayFormatted)\ntotal build time: \(buildTimeTotalFormatted)\n")
		}
	}

	func buildEntriesFromToday(in buildHistoryData: [BuildHistoryEntry]) -> [BuildHistoryEntry] {
		return buildHistoryData.filter({
			Calendar.current.isDateInToday($0.date)
		})
	}

	func totalBuildTime(for buildHistoryData: [BuildHistoryEntry]) -> Int {
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

			guard let username = record[BuildHistoryEntryKey.username.rawValue],
				let timestampStr = record[BuildHistoryEntryKey.timestamp.rawValue],
				let timestamp = TimeInterval(timestampStr),
				let buildTimeStr = record[BuildHistoryEntryKey.buildTime.rawValue],
				let buildTime = Int(buildTimeStr) else {
				return nil
			}

			// TODO: This needs to stay non required here for now, as it's a newly added param and doesn't exist in older records.
			let schemeName = record[BuildHistoryEntryKey.schemeName.rawValue] ?? ""
			return BuildHistoryEntry(buildTime: buildTime, schemeName: schemeName, date: Date(timeIntervalSince1970: timestamp), username: username)
		})
	}
}
