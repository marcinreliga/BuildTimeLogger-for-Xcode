//
//  BuildTimeLoggerApp.swift
//  BuildTimeLogger
//
//  Created by Marcin Religa on 01/03/2017.
//  Copyright © 2017 Marcin Religa. All rights reserved.
//

import Foundation

final class BuildTimeLoggerApp {
	private let buildHistoryDatabase: BuildHistoryDatabase
	private let notificationManager: NotificationManager
	private let dataParser: DataParser
	private let xcodeDatabaseManager: XcodeDatabaseManager

	init(buildHistoryDatabase: BuildHistoryDatabase = BuildHistoryDatabase(),
	     notificationManager: NotificationManager = NotificationManager(),
	     dataParser: DataParser = DataParser(),
	     xcodeDatabaseManager: XcodeDatabaseManager = XcodeDatabaseManager()) {
		self.buildHistoryDatabase = buildHistoryDatabase
		self.notificationManager = notificationManager
		self.dataParser = dataParser
		self.xcodeDatabaseManager = xcodeDatabaseManager
	}

	func run() {
		guard let latestBuildData = xcodeDatabaseManager.latestBuildData else {
			return
		}

		let updatedBuildHistoryData: [BuildHistoryEntry]

		if var buildHistoryData = buildHistoryDatabase.read() {
			buildHistoryData.append(latestBuildData.buildHistoryEntry)
			updatedBuildHistoryData = buildHistoryData
		} else {
			updatedBuildHistoryData = [latestBuildData.buildHistoryEntry]
		}

		buildHistoryDatabase.save(history: updatedBuildHistoryData)

		let totalTime = totalBuildsTimeToday(for: updatedBuildHistoryData)

		let latestBuildTimeFormatted = TimeFormatter.format(time: latestBuildData.buildTime)
		let totalBuildsTimeTodayFormatted = TimeFormatter.format(time: totalTime)

		notificationManager.showNotification(message: "current build time: \t\t\(latestBuildTimeFormatted)\ntotal build time today: \t\(totalBuildsTimeTodayFormatted)")

		if CommandLine.arguments.count > 1, let remoteStorageURL = URL(string: CommandLine.arguments[1]) {
			let networkManager = NetworkManager(remoteStorageURL: remoteStorageURL)
			networkManager.sendData(username: NSUserName(), timestamp: Int(NSDate().timeIntervalSince1970), buildTime: latestBuildData.buildTime)

			if CommandLine.arguments.count == 3 {
				networkManager.fetchData { [weak self] result in
					switch result {
					case .success(let data):
						self?.dataParser.parse(data: data)
					case .failure:
						print("error")
					}
				}
			}
		}
	}

	func totalBuildsTimeToday(for buildHistoryData: [BuildHistoryEntry]) -> Int {
		return buildHistoryData.filter({
			Calendar.current.isDateInToday($0.date)
		}).reduce(0, {
			//print("saved build time: \($1.schemeName) \($1.buildTime), t: \($1.date)")
			return $0 + $1.buildTime
		})
	}
}
