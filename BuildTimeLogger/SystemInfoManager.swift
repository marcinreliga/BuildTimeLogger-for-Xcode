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
	case numberOfProcessors = "number_processors"
	case spdevtoolsVersion = "spdevtools_version"
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

		if let plistDictionary = plistData as? [[String: AnyObject]],
			let hardwareInfo = readHardwareInfo(in: plistDictionary),
			let devToolsInfo = readDevToolsInfo(in: plistDictionary) {
			return SystemInfo(hardware: hardwareInfo, devTools: devToolsInfo)
		}
		
		return nil
	}

	private func readHardwareInfo(in dictionary: [[String: AnyObject]]) -> HardwareInfo? {
		for plistEntry in dictionary {
			guard let items = plistEntry[SystemInfoNativeKey.items.rawValue] as? [[String: AnyObject]] else {
				continue
			}

			guard let cpuType = items.first?[SystemInfoNativeKey.cpuType.rawValue] as? String,
				let cpuSpeed = items.first?[SystemInfoNativeKey.currentProcessorSpeed.rawValue] as? String,
				let machineModel = items.first?[SystemInfoNativeKey.machineModel.rawValue] as? String,
				let physicalMemory = items.first?[SystemInfoNativeKey.physicalMemory.rawValue] as? String,
				let numberOfProcessors = items.first?[SystemInfoNativeKey.numberOfProcessors.rawValue] as? Int else {
				continue
			}

			let systemInfo = HardwareInfo(cpuType: cpuType, cpuSpeed: cpuSpeed, machineModel: machineModel, physicalMemory: physicalMemory, numberOfProcessors: numberOfProcessors)

			return systemInfo
		}

		return nil
	}

	private func readDevToolsInfo(in dictionary: [[String: AnyObject]]) -> DevToolsInfo? {
		for plistEntry in dictionary {
			guard let items = plistEntry[SystemInfoNativeKey.items.rawValue] as? [[String: AnyObject]] else {
				continue
			}

			guard let version = items.first?[SystemInfoNativeKey.spdevtoolsVersion.rawValue] as? String else {
				continue
			}

			let devToolsInfo = DevToolsInfo(version: version)

			return devToolsInfo
		}

		return nil
	}
}
