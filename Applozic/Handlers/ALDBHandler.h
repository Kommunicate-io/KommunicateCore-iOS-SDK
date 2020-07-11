//
//  ALDBHandler.h
//  ChatApp
//
//  Created by Gaurav Nigam on 09/08/15.
//  Copyright (c) 2015 AppLogic. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "DB_CONTACT.h"

@class ALContact;
static NSString *const AL_SQLITE_FILE_NAME = @"AppLozic.sqlite";

@interface ALDBHandler : NSObject

@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;

@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;

@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

@property (strong, nonatomic) NSPersistentContainer *persistentContainer;

- (NSManagedObjectContext *)privateContext;

- (NSError *)saveContext;

+(ALDBHandler *) sharedInstance;

- (void)savePrivateAndMainContext:(NSManagedObjectContext*)context
                        completion:(void (^)(NSError*error))completion;
@end
