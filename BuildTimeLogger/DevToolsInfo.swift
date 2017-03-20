//
//  DevToolsInfo.swift
//  BuildTimeLogger
//
//  Created by Marcin Religa on 20/03/2017.
//  Copyright © 2017 Marcin Religa. All rights reserved.
//

import Foundation

enum DevToolsInfoKey: String {
	case devToolsVersion
}

struct DevToolsInfo {
	let version: String
}
