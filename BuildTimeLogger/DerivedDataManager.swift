// The MIT License (MIT)
//
// Copyright (c) 2016 Robert Gummesson
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.

//
//  DerivedDataManager.swift
//  BuildTimeAnalyzer
//

import Foundation

class DerivedDataManager {
    
    static func derivedData() -> [File] {
        let url = URL(fileURLWithPath: UserSettings.derivedDataLocation)
        
        let folders = DerivedDataManager.listFolders(at: url)
        let fileManager = FileManager.default
        
        return folders.flatMap{ (url) -> File? in
            if !url.lastPathComponent.contains("ModuleCache"),
                let properties = try? fileManager.attributesOfItem(atPath: url.path),
                let modificationDate = properties[FileAttributeKey.modificationDate] as? Date {
                return File(date: modificationDate, url: url)
            }
            return nil
        }.sorted{ $0.date > $1.date }
    }
    
    static func listFolders(at url: URL) -> [URL] {
        let fileManager = FileManager.default
        let keys = [URLResourceKey.nameKey, URLResourceKey.isDirectoryKey]
        let options: FileManager.DirectoryEnumerationOptions = [.skipsHiddenFiles, .skipsPackageDescendants, .skipsSubdirectoryDescendants]
        
        guard let enumerator = fileManager.enumerator(at: url, includingPropertiesForKeys: keys, options: options, errorHandler: nil) else { return [] }
        
        return enumerator.map{ $0 as! URL }
    }
}
