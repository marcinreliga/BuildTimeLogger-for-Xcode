//
//  NetworkManager.swift
//  BuildTimeLogger
//
//  Created by Marcin Religa on 07/03/2017.
//  Copyright © 2017 Marcin Religa. All rights reserved.
//

import Foundation

enum NetworkError: Error {
	case didFailToFetchData
}

final class NetworkManager {
	private let remoteStorageURL: URL

	init(remoteStorageURL: URL) {
		self.remoteStorageURL = remoteStorageURL
	}

	// TODO: use single BuildHistoryEntry object as an argument.
	func sendData(username: String, timestamp: Int, buildTime: Int, schemeName: String, systemInfo: SystemInfo?) {
		let semaphore = DispatchSemaphore(value: 0)

		var request = URLRequest(url: remoteStorageURL)
		request.httpMethod = "POST"
		var data: [String: Any] = [
			BuildHistoryEntryKey.username.rawValue: username,
			BuildHistoryEntryKey.timestamp.rawValue: timestamp,
			BuildHistoryEntryKey.buildTime.rawValue: buildTime,
			BuildHistoryEntryKey.schemeName.rawValue: schemeName
		]

		if let systemInfo = systemInfo {
			data[SystemInfoKey.cpuType.rawValue] = systemInfo.cpuType
			data[SystemInfoKey.cpuSpeed.rawValue] = systemInfo.cpuSpeed
			data[SystemInfoKey.machineModel.rawValue] = systemInfo.machineModel
			data[SystemInfoKey.physicalMemory.rawValue] = systemInfo.physicalMemory
		}

		let postString = formatPOSTString(data: data)
		request.httpBody = postString.data(using: .utf8)
		let task = URLSession.shared.dataTask(with: request) { data, response, error in
			if let error = error {
				print("error: \(error)")
			}

			semaphore.signal()
		}
		task.resume()
		semaphore.wait();
	}

	func fetchData(completion: @escaping (Result<Data, NetworkError>) -> Void) {
		let semaphore = DispatchSemaphore(value: 0)

		var request = URLRequest(url: remoteStorageURL)
		request.httpMethod = "GET"
		let task = URLSession.shared.dataTask(with: request) { data, response, error in
			guard let data = data, error == nil else {
				completion(.failure(NetworkError.didFailToFetchData))
				return
			}

			completion(.success(data))
			semaphore.signal()
		}
		task.resume()
		semaphore.wait();
	}

	private func formatPOSTString(data: [String: Any]) -> String {
		var resultArr: [String] = []

		for (key, value) in data {
			resultArr.append("\"\(key)\": \"\(value)\"")
		}

		return "{ " + resultArr.joined(separator: ", ") + " }"
	}
}
