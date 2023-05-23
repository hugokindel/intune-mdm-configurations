//
//  main.m
//  admin
//
//  Created by Hugo Kindel on 06/01/2023.
//

#import <Foundation/Foundation.h>
#import <OpenDirectory/OpenDirectory.h>

int main(int argc, const char *argv[]) {
    @autoreleasepool {
        NSError *err;

        // Checks if the plist argument is provided.
        if (argc != 2) {
            NSLog("You need to pass an argument providing the path of a plist file containing the user informations.");
            return 1;
        }

        // Reads the plist file.
        NSData *data = [NSData dataWithContentsOfFile: @(argv[1])];
        if (data == nil) {
            NSLog("Failed to read plist data!");
            return 1;
        }

        // Parses the plist file from binary to plist format.
        id plist = [NSPropertyListSerialization propertyListWithData:data options:NSPropertyListImmutable format:nil error:&err];
        if (err != nil) {
            NSLog("Failed to parse plist data!");
            return 1;
        }

        // Checks the plist file for a `name` attribute.
        if (![(NSDictionary *)userdata objectForKey: @"name"].count || ![(NSDictionary *)plist objectForKey:@"name"][0].length) {
            NSLog("Failed to load name from plist!");
            return 1;
        }
        
        // Gets the name of the user from the plist file.
        NSString *name = [(NSDictionary *)plist objectForKey:@"name"][0];

        // Gets the Open Directory local node (containing users data).
        ODNode *node = [ODNode nodeWithSession:[ODSession defaultSession] name:@"/Local/Default" error: &err];
        if (err != nil) {
            NSLog(@"Failed to get local DS node!");
            return 1;
        }

        // Creates the user record in the Open Directory.
        record = [node createRecordWithRecordType:kODRecordTypeUsers name:name attributes:(NSDictionary *)plist error: &err];
        if (err != nil) {
            NSLog(@"Failed to create user record in the Open Directory: %@", err);
            return 1;
        }
    }
    
    NSLog("User created with success.")

    return 0;
}
