//
//  NetworkManager.swift
//  BuildTimeLogger
//
//  Created by Marcin Religa on 07/03/2017.
//  Copyright © 2017 Marcin Religa. All rights reserved.
//

import Foundation

final class NetworkManager {
	private let remoteStorageURL: URL

	init(remoteStorageURL: URL) {
		self.remoteStorageURL = remoteStorageURL
	}

	func sendData(username: String, timestamp: Int, buildTime: Int) {
		let semaphore = DispatchSemaphore(value: 0)

		var request = URLRequest(url: remoteStorageURL)
		request.httpMethod = "POST"
		let postString = formatPOSTString(data: ["username": username, "timestamp": timestamp, "buildTime": buildTime])
		request.httpBody = postString.data(using: .utf8)
		let task = URLSession.shared.dataTask(with: request) { data, response, error in
			guard let data = data, error == nil else {
				print("error: \(error)")
				return
			}

			let responseString = String(data: data, encoding: .utf8)
			print("responseString = \(responseString)")
			semaphore.signal()
		}
		task.resume()
		semaphore.wait();
	}

	func formatPOSTString(data: [String: Any]) -> String {
		var resultArr: [String] = []

		for (key, value) in data {
			resultArr.append("\"\(key)\": \"\(value)\"")
		}

		return "{ " + resultArr.joined(separator: ", ") + " }"
	}
}
