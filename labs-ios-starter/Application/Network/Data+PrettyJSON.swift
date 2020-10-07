// Copyright © 2020 Shawn James. All rights reserved.
// Data+PrettyJSON.swift

import Foundation

extension Data {
    /// DebugPrint formatted JSON to the console.
    func debugPrintJSON() {
        guard
            let object = try? JSONSerialization.jsonObject(with: self, options: []),
            let data = try? JSONSerialization.data(withJSONObject: object, options: [.prettyPrinted]),
            let formattedJSON = NSString(data: data, encoding: String.Encoding.utf8.rawValue)
        else {
            print("debugPrintJSON() failed"); return
        }

        debugPrint(formattedJSON)
    }
}
