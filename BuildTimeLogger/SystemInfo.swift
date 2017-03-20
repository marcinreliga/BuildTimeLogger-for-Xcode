//
//  SystemInfo.swift
//  BuildTimeLogger
//
//  Created by Marcin Religa on 20/03/2017.
//  Copyright © 2017 Marcin Religa. All rights reserved.
//

import Foundation

enum SystemInfoKey: String {
	case cpuType
	case cpuSpeed
	case machineModel
	case physicalMemory
}

struct SystemInfo {
	let cpuType: String
	let cpuSpeed: String
	let machineModel: String
	let physicalMemory: String
}
