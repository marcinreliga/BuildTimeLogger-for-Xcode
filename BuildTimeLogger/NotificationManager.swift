//
//  NotificationManager.swift
//  BuildTimeLogger
//
//  Created by Marcin Religa on 08/03/2017.
//  Copyright © 2017 Marcin Religa. All rights reserved.
//

import Foundation

struct NotificationManager {
	func showNotification(message: String) {
		// Apparetly can't display notification from console app using NSUserNotificationCenter, so using command line instead.
		Process.launchedProcess(launchPath: "/usr/bin/osascript", arguments: ["-e", "display notification \"\(message)\" with title \"Build time logger\""])
	}
}
