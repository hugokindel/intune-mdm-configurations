//
//  main.swift
//  admin
//
//  Created by Hugo Kindel on 09/01/2023.
//

import Foundation
import OpenDirectory

// Checks if the plist argument is provided.
if CommandLine.argc < 2 {
    print("You need to pass an argument providing the path of a plist file containing the user informations.")
    exit(1)
}

// Reads the plist file.
guard let data = try? Data(contentsOf: URL(fileURLWithPath: CommandLine.arguments[1])) else {
    print("Failed to read plist file!")
    exit(1)
}

// Parses the plist file from binary to plist format.
guard let plist = try? PropertyListSerialization.propertyList(from: data, options: [], format: nil) as? [String: Any] else {
    print("Failed to parse plist data!")
    exit(1)
}

// Checks the plist file for a `name` attribute.
guard plist.keys.contains("name") && !(plist["name"] as? [String])!.isEmpty else {
    print("Failed to load name from plist!")
    exit(1)
}

// Gets the name of the user from the plist file.
let name = (plist["name"] as! [String])[0]

// Gets the Open Directory local node (containing users data).
guard let node = try? ODNode(session: ODSession.default(), name: "/Local/Default") else {
    print("Failed to get local DS node!")
    exit(1)
}

// Creates the user record in the Open Directory.
do {
    try node.createRecord(withRecordType: kODRecordTypeUsers, name: name, attributes: plist)
} catch {
    print("Failed to create user record in the Open Directory: \(error)")
    exit(1)
}

print("User created with success.")
