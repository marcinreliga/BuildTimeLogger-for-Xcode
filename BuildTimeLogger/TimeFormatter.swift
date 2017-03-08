//
//  TimeFormatter.swift
//  BuildTimeLogger
//
//  Created by Marcin Religa on 08/03/2017.
//  Copyright © 2017 Marcin Religa. All rights reserved.
//

import Foundation

struct TimeFormatter {
	static func format(time: Int) -> String {
		let minutes = time / 60
		let seconds = time % 60

		return "\(minutes)m \(seconds)s"
	}
}
