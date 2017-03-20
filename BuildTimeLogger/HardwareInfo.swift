//
//  HardwareInfo.swift
//  BuildTimeLogger
//
//  Created by Marcin Religa on 20/03/2017.
//  Copyright © 2017 Marcin Religa. All rights reserved.
//

import Foundation

enum HardwareInfoKey: String {
	case cpuType
	case cpuSpeed
	case machineModel
	case physicalMemory
	case numberOfProcessors
}

struct HardwareInfo {
	let cpuType: String
	let cpuSpeed: String
	let machineModel: String
	let physicalMemory: String
	let numberOfProcessors: Int
}
