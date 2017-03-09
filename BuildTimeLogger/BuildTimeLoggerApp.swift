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

	private var buildHistory: [BuildHistoryEntry]?

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
		switch CommandLine.arguments.count {
		case 2:
			print("Updating local build history...")
			updateBuildHistory()
			showNotification()

			guard let buildHistory = buildHistory, let latestBuildData = buildHistory.last else {
				return
			}

			print("Storing data remotely...")
			if let remoteStorageURL = URL(string: CommandLine.arguments[1]) {
				storeDataRemotely(buildData: latestBuildData, atURL: remoteStorageURL)
			}
		case 3:
			print("Fetching remote data...")
			if let remoteStorageURL = URL(string: CommandLine.arguments[1]) {
				fetchRemoteData(atURL: remoteStorageURL)
			}
		default:
			print("Updating local build history...")
			updateBuildHistory()
			showNotification()
		}
	}

	private func fetchRemoteData(atURL url: URL) {
		let networkManager = NetworkManager(remoteStorageURL: url)
		networkManager.fetchData { [weak self] result in
			switch result {
			case .success(let data):
				self?.dataParser.parse(data: data)
			case .failure:
				print("error")
			}
		}
	}

	private func storeDataRemotely(buildData: BuildHistoryEntry, atURL url: URL) {
		let networkManager = NetworkManager(remoteStorageURL: url)
		networkManager.sendData(username: NSUserName(), timestamp: Int(NSDate().timeIntervalSince1970), buildTime: buildData.buildTime)
	}

	private func showNotification() {
		guard let buildHistory = buildHistory, let latestBuildData = buildHistory.last else {
			return
		}

		let totalTime = dataParser.totalBuildsTime(for: dataParser.buildEntriesFromToday(in: buildHistory))

		let latestBuildTimeFormatted = TimeFormatter.format(time: latestBuildData.buildTime)
		let totalBuildsTimeTodayFormatted = TimeFormatter.format(time: totalTime)

		notificationManager.showNotification(message: "current build time: \t\t\(latestBuildTimeFormatted)\ntotal build time today: \t\(totalBuildsTimeTodayFormatted)")
	}

	private func updateBuildHistory() {
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
		buildHistory = updatedBuildHistoryData
	}
}
