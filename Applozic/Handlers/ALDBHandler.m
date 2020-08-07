//
//  ALDBHandler.m
//  ChatApp
//
//  Created by Gaurav Nigam on 09/08/15.
//  Copyright (c) 2015 AppLogic. All rights reserved.
//

#import "ALDBHandler.h"
#import "DB_CONTACT.h"
#import "ALContact.h"
#import "ALUtilityClass.h"
#import "ALApplozicSettings.h"

@implementation ALDBHandler

dispatch_queue_t dispatchGlobalQueue;

+(ALDBHandler *) sharedInstance
{
    static ALDBHandler *sharedMyManager = nil;
    
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        
        sharedMyManager = [[self alloc] init];
        
    });
    
    return sharedMyManager;
}

- (id)init {
    if (self = [super init]) {


    }
    return self;
}


@synthesize managedObjectContext = _managedObjectContext;

@synthesize managedObjectModel = _managedObjectModel;

@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;

- (NSManagedObjectModel *)managedObjectModel {
    
    // The managed object model for the application. It is a fatal error for the application not to be able to find and load its model.
    
    if (_managedObjectModel != nil) {
        
        return _managedObjectModel;
        
    }
    
    NSURL *modelURL = [[NSBundle bundleForClass:[self class]]URLForResource:@"AppLozic" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    
    return _managedObjectModel;
}

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {

    @synchronized (self) {
        // The persistent store coordinator for the application. This implementation creates and return a coordinator, having added the store for the application to it.

        if (_persistentStoreCoordinator != nil) {

            return _persistentStoreCoordinator;

        }

        // Create the coordinator and store
        _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];

        NSURL *storeURL =  [ALUtilityClass getApplicationDirectoryWithFilePath:AL_SQLITE_FILE_NAME];

        NSURL *groupURL = [ALUtilityClass getAppsGroupDirectoryWithFilePath:AL_SQLITE_FILE_NAME];

        NSError *error = nil;
        NSPersistentStore  *sourceStore  = nil;
        NSPersistentStore  *destinationStore  = nil;
        NSDictionary *options = @{
            NSInferMappingModelAutomaticallyOption: [NSNumber numberWithBool:YES],
            NSMigratePersistentStoresAutomaticallyOption: [NSNumber numberWithBool:YES]
        };

        if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:options error:&error]){
            ALSLog(ALLoggerSeverityError, @"Failed to setup the persistentStoreCoordinator %@, %@", error, [error userInfo]);
            return nil;
        } else {
            sourceStore = [_persistentStoreCoordinator persistentStoreForURL:storeURL];
            if (sourceStore != nil && groupURL){
                // Perform the migration

                destinationStore = [_persistentStoreCoordinator migratePersistentStore:sourceStore toURL:groupURL options:options withType:NSSQLiteStoreType error:&error];
                if (destinationStore == nil){
                    ALSLog(ALLoggerSeverityError, @"Failed to migratePersistentStore");
                    return nil;
                } else {

                    NSFileCoordinator *coord = [[NSFileCoordinator alloc]initWithFilePresenter:nil];
                    [coord coordinateWritingItemAtURL:storeURL options:0 error:nil byAccessor:^(NSURL *url)
                     {
                        NSError *error;
                        [[NSFileManager defaultManager] removeItemAtURL:url error:&error];
                        if(error){
                            ALSLog(ALLoggerSeverityError, @"Failed to Delete the data base file %@, %@", error, [error userInfo]);
                        }

                    }];

                }
            }
        }

    }

    return _persistentStoreCoordinator;
}


- (NSManagedObjectContext *)managedObjectContext {
    
    // Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.)
    
    if (_managedObjectContext != nil) {
        
        return _managedObjectContext;
        
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    
    if (!coordinator) {
        
        return nil;
        
    }
    
    _managedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
    
    [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    [_managedObjectContext setMergePolicy:NSMergeByPropertyObjectTrumpMergePolicy];
    return _managedObjectContext;
}

#pragma mark - Core Data Saving support

- (NSError *)saveContext {
    NSError *error = nil;
    @try {
        if (self.managedObjectContext) {
            if ([self.managedObjectContext hasChanges] && ![self.managedObjectContext save:&error]) {
                ALSLog(ALLoggerSeverityError, @"Unresolved error %@, %@", error, [error userInfo]);
                return error;
            }
        } else {
            NSError * managedObjectContexterror = [NSError errorWithDomain:@"Applozic"
                                                                      code:1
                                                                  userInfo:@{NSLocalizedDescriptionKey : @"Managed Object Context is nil"}];

            return managedObjectContexterror;
        }
    } @catch (NSException *exception) {
        error = [NSError errorWithDomain:@"Applozic"
                                    code:1
                                userInfo:@{NSLocalizedDescriptionKey : exception.reason}];
        ALSLog(ALLoggerSeverityError, @"Unresolved NSException in db save %@, %@", exception.reason, [exception userInfo]);
    } @finally {
        return error;
    }
}

-(BOOL) isProtectedDataAvailable {
    __block BOOL protectedDataAvailable = NO;
    if ([NSThread isMainThread])
    {
        protectedDataAvailable = [[UIApplication sharedApplication] isProtectedDataAvailable];
    }
    else
    {
        dispatch_sync(dispatch_get_main_queue(), ^{

            protectedDataAvailable = [[UIApplication sharedApplication] isProtectedDataAvailable];
        });
    }
    return protectedDataAvailable;
}

- (void) savePrivateAndMainContext:(NSManagedObjectContext*)context
                        completion:(void (^)(NSError*error))completion {
    @try {
        NSError* error;
        if (!context) {
            error = [NSError errorWithDomain:@"Applozic" code:1 userInfo:@{NSLocalizedDescriptionKey : @"Private context is nil"}];
            completion(error);
            return;
        }
        if (context.hasChanges && [context save:&error]) {
            if (!self.managedObjectContext) {
                error = [NSError errorWithDomain:@"Applozic" code:1 userInfo:@{NSLocalizedDescriptionKey : @"Managed object context is nil"}];
                completion(error);
                return;
            }
            [self.managedObjectContext performBlock:^ {
                NSError *parentContextError = [self saveContext];
                completion(parentContextError);
            }];
        } else {
            if (error) {
                ALSLog(ALLoggerSeverityError, @"DB ERROR in savePrivateAndMainContext :%@",error);
                [context rollback];
            }
            completion(error);
        }
    } @catch (NSException *exception) {
        ALSLog(ALLoggerSeverityError, @"Unresolved NSException in db savePrivateAndMainContext %@, %@", exception.reason, [exception userInfo]);
    }
}

- (NSManagedObjectContext *)privateContext {
    NSManagedObjectContext *privateManagedObjectContext = nil;
    if (self.managedObjectContext) {
        privateManagedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
        [privateManagedObjectContext setParentContext:self.managedObjectContext];
    }
    return privateManagedObjectContext;
}

-(NSArray *)executeFetchRequest:(NSFetchRequest *)fetchrequest withError: (NSError **)fetchError {
    NSArray * fetchResultArray = nil;
    if (self.managedObjectContext) {
        fetchResultArray = [self.managedObjectContext executeFetchRequest:fetchrequest
                                                                    error:fetchError];
    }
    return fetchResultArray;
}

-(NSEntityDescription *)entityDescriptionWithEntityForName:(NSString *)name {
    if (self.managedObjectContext) {
        return [NSEntityDescription entityForName:name inManagedObjectContext:self.managedObjectContext];
    }
    return nil;
}

-(NSUInteger)countForFetchRequest:(NSFetchRequest *)fetchrequest {

    if (self.managedObjectContext) {
        NSError *fetchError = nil;
        NSUInteger fetchCount = [self.managedObjectContext countForFetchRequest:fetchrequest error:&fetchError];
        if (fetchError) {
            return 0;
        }
        return fetchCount;
    }
    return 0;
}

-(NSManagedObject*)existingObjectWithID:(NSManagedObjectID *)objectID {
    NSManagedObject* managedObject = nil;
    if (self.managedObjectContext) {
        NSError *managedObjectError = nil;
        managedObject = [self.managedObjectContext existingObjectWithID:objectID
                                                                  error:&managedObjectError];
        if (managedObjectError) {
            ALSLog(ALLoggerSeverityError, @"Error while fetching NSManagedObject %@", managedObjectError);
            return nil;
        }
    }
    return managedObject;
}

-(NSManagedObject *)insertNewObjectForEntityForName:(NSString *) entityName {
    if (self.managedObjectContext) {
        return [NSEntityDescription insertNewObjectForEntityForName:entityName inManagedObjectContext:self.managedObjectContext];
    }
    return nil;
}

-(void)deleteObject:(NSManagedObject *) managedObject {
    if (self.managedObjectContext) {
        [self.managedObjectContext deleteObject:managedObject];
    }
}
-(NSManagedObject *)insertNewObjectForEntityForName:(NSString *)entityName withManagedObjectContext:(NSManagedObjectContext *) context {
    if (context) {
        return [NSEntityDescription insertNewObjectForEntityForName:entityName inManagedObjectContext:context];
    }
    return nil;
}

-(NSBatchUpdateResult *)executeRequestForNSBatchUpdateResult:(NSBatchUpdateRequest *)updateRequest withError:(NSError **)fetchError {
    NSBatchUpdateResult *batchUpdateResult = nil;
    if (self.managedObjectContext) {
        batchUpdateResult = (NSBatchUpdateResult *)[self.managedObjectContext executeRequest:updateRequest error:fetchError];
    }
    return batchUpdateResult;
}

@end
