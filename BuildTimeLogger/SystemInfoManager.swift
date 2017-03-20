//
//  SystemInfoManager.swift
//  BuildTimeLogger
//
//  Created by Marcin Religa on 20/03/2017.
//  Copyright © 2017 Marcin Religa. All rights reserved.
//

import Foundation

enum SystemInfoNativeKey: String {
	case items = "_items"
	case cpuType = "cpu_type"
	case currentProcessorSpeed = "current_processor_speed"
	case machineModel = "machine_model"
	case physicalMemory = "physical_memory"
}

class SystemInfoManager {
	func read() -> SystemInfo? {
		let task = Process()
		task.launchPath = "/usr/sbin/system_profiler"
		task.arguments = ["SPHardwareDataType", "SPDeveloperToolsDataType", "-xml"]

		let pipe = Pipe()
		task.standardOutput = pipe
		task.standardError = pipe
		task.launch()
		let data = pipe.fileHandleForReading.readDataToEndOfFile()

		task.waitUntilExit()

		var propertyListFormat =  PropertyListSerialization.PropertyListFormat.xml
		guard let plistData = try? PropertyListSerialization.propertyList(from: data, options: .mutableContainersAndLeaves, format: &propertyListFormat) as? [AnyObject] else {
			return nil
		}

		if let plistDictionary = plistData as? [[String: AnyObject]] {
			for plistEntry in plistDictionary {
				guard let items = plistEntry[SystemInfoNativeKey.items.rawValue] as? [[String: AnyObject]] else {
					continue
				}

				guard let cpuType = items.first?[SystemInfoNativeKey.cpuType.rawValue] as? String,
					let cpuSpeed = items.first?[SystemInfoNativeKey.currentProcessorSpeed.rawValue] as? String,
					let machineModel = items.first?[SystemInfoNativeKey.machineModel.rawValue] as? String,
					let physicalMemory = items.first?[SystemInfoNativeKey.physicalMemory.rawValue] as? String else {
						continue
				}

				let systemInfo = SystemInfo(cpuType: cpuType, cpuSpeed: cpuSpeed, machineModel: machineModel, physicalMemory: physicalMemory)

				return systemInfo
			}
		}
		
		return nil
	}
}
