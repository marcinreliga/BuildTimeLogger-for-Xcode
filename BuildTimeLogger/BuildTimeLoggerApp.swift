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

	init(buildHistoryDatabase: BuildHistoryDatabase = BuildHistoryDatabase(),
	     notificationManager: NotificationManager = NotificationManager()) {
		self.buildHistoryDatabase = buildHistoryDatabase
		self.notificationManager = notificationManager
	}

	func format(time: Int) -> String {
		let minutes = time / 60
		let seconds = time % 60

		return "\(minutes)m \(seconds)s"
	}

	func run() {
		guard let latestBuildData = latestBuildData else {
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

		let latestBuildTimeFormatted = format(time: latestBuildData.buildTime)
		let totalBuildsTimeTodayFormatted = format(time: totalTime)

		print("current build time: \(latestBuildData.schemeName): \(latestBuildTimeFormatted)")
		print("total build time today: \(totalBuildsTimeTodayFormatted)")

		//UserDefaults.standard.removeObject(forKey: "buildHistory")

		notificationManager.showNotification(message: "current build time: \t\t\(latestBuildTimeFormatted)\ntotal build time today: \t\(totalBuildsTimeTodayFormatted)")

		if CommandLine.arguments.count == 2, let remoteStorageURL = URL(string: CommandLine.arguments[1]) {
			let networkManager = NetworkManager(remoteStorageURL: remoteStorageURL)
			networkManager.sendData(username: NSUserName(), timestamp: Int(NSDate().timeIntervalSince1970), buildTime: latestBuildData.buildTime)
		}
	}

	var latestBuildData: XcodeDatabase? {
		let dataSource = DerivedDataManager.derivedData().flatMap{
			XcodeDatabase(fromPath: $0.url.appendingPathComponent("Logs/Build/Cache.db").path)
			}.sorted(by: { $0.modificationDate > $1.modificationDate })

		for db in dataSource {
			print("date: \(db.modificationDate), scheme: \(db.schemeName)")
		}

		// TODO: check for correct build.
		guard let latestBuildDatabase = dataSource.first else {
			return nil
		}

		return latestBuildDatabase
	}

	func totalBuildsTimeToday(for buildHistoryData: [BuildHistoryEntry]) -> Int {
		return buildHistoryData.filter({
			Calendar.current.isDateInToday($0.date)
		}).reduce(0, {
			print("saved build time: \($1.schemeName) \($1.buildTime), t: \($1.date)")
			return $0 + $1.buildTime
		})
	}
}
