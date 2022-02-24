//
//  ALDBHandler.m
//  ChatApp
//
//  Created by Gaurav Nigam on 09/08/15.
//  Copyright (c) 2015 AppLogic. All rights reserved.
//

#import "ALDBHandler.h"
#import "ALUtilityClass.h"
#import "ALApplozicSettings.h"
#import "ALLogger.h"

@implementation ALDBHandler

+ (ALDBHandler *)sharedInstance {
    static ALDBHandler *sharedMyManager = nil;
    
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        
        sharedMyManager = [[self alloc] init];
        
    });
    
    return sharedMyManager;
}

- (id)init {
    if (self = [super init]) {
        _persistentContainer = self.persistentContainer;
    }
    return self;
}

@synthesize managedObjectModel = _managedObjectModel;

@synthesize persistentContainer = _persistentContainer;

- (NSManagedObjectModel *)managedObjectModel {
    
    // The managed object model for the application. It is a fatal error for the application not to be able to find and load its model.
    
    if (_managedObjectModel != nil) {
        
        return _managedObjectModel;
        
    }

    NSBundle *bundle = [self getBundle];
    NSURL *modelURL = [bundle URLForResource:@"AppLozic" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];

    return _managedObjectModel;
}

- (NSPersistentContainer *)persistentContainer {
    @synchronized (self) {
        NSURL *storeURL = [ALUtilityClass getApplicationDirectoryWithFilePath:AL_SQLITE_FILE_NAME];
        NSURL *groupStoreURL = [ALUtilityClass getAppsGroupDirectoryWithFilePath:AL_SQLITE_FILE_NAME];

        // Add the fall back for store URL in case of Group Store URL is not there.
        NSURL *persistentStoreURL = nil;
        if (groupStoreURL) {
            persistentStoreURL = groupStoreURL;
        } else {
            persistentStoreURL = storeURL;
        }

        if (_persistentContainer == nil) {
            NSPersistentContainer *container = [[NSPersistentContainer alloc] initWithName:@"AppLozic" managedObjectModel:self.managedObjectModel];

            // Check if we already have a store saved in the default app location.
            BOOL hasDefaultAppLocation = [[NSFileManager defaultManager] fileExistsAtPath:storeURL.path];

            // Check if the store needs migration.
            BOOL storeNeedsMigration = hasDefaultAppLocation
            && groupStoreURL
            && ![storeURL.absoluteString isEqualToString:groupStoreURL.absoluteString];

            NSPersistentStoreDescription *persistentStoreDescription = nil;
            // Check if the default location flag is true then use the store URL of saved app location
            if (hasDefaultAppLocation) {
                persistentStoreDescription = [[NSPersistentStoreDescription alloc] initWithURL:storeURL];
            } else {
                // Use the persistent Store URL
                persistentStoreDescription = [[NSPersistentStoreDescription alloc] initWithURL:persistentStoreURL];
            }

            persistentStoreDescription.shouldMigrateStoreAutomatically = YES;
            persistentStoreDescription.shouldInferMappingModelAutomatically = YES;
            container.persistentStoreDescriptions = @[persistentStoreDescription];

            [container loadPersistentStoresWithCompletionHandler:^(NSPersistentStoreDescription *description, NSError *error) {
                if (error) {
                    NSLog(@"Failed to load Core Data stack: %@", error);
                    self->_isStoreLoaded = NO;
                    return;
                }

                if (storeNeedsMigration) {

                    NSError *migrateError;
                    NSError *deleteError;

                    NSURL *oldStoreURL = description.URL;

                    // Get the current store we want to migrate.
                    NSPersistentStore *store = [container.persistentStoreCoordinator persistentStoreForURL: oldStoreURL];

                    // Set the store options.
                    NSDictionary *options = @{NSInferMappingModelAutomaticallyOption:[NSNumber numberWithBool:YES],
                                              NSMigratePersistentStoresAutomaticallyOption:[NSNumber numberWithBool:YES]};

                    // Migrate the store to App group.
                    NSPersistentStore *newStore = [container.persistentStoreCoordinator migratePersistentStore:store
                                                                                                         toURL:groupStoreURL
                                                                                                       options:options
                                                                                                      withType:NSSQLiteStoreType
                                                                                                         error:&migrateError];
                    if (newStore
                        && !migrateError) {
                        self->_isStoreLoaded = YES;
                        // Removing the old SQLLite database.
                        [[[NSFileCoordinator alloc] init] coordinateWritingItemAtURL: oldStoreURL
                                                                             options: NSFileCoordinatorWritingForDeleting
                                                                               error: &deleteError
                                                                          byAccessor: ^(NSURL *urlForModifying) {
                            NSError *removeError;
                            [[NSFileManager defaultManager] removeItemAtURL: urlForModifying
                                                                      error: &removeError];
                            if (removeError) {
                                NSLog(@"Error in removing a old Store URL file %@ @@@@", [removeError localizedDescription]);
                            }
                        }];

                        if (deleteError) {
                            NSLog(@"Error in deleting the old Store URL %@", [deleteError localizedDescription]);
                        }
                    } else {
                        // Store migration failed required
                        self->_isStoreLoaded = NO;
                        if (migrateError) {
                            NSLog(@"Error in Store migration %@", [migrateError localizedDescription]);
                        }
                    }
                } else {
                    // Store migration not required
                    self->_isStoreLoaded = YES;
                }

            }];

            if (self.isStoreLoaded) {
                [container.viewContext setMergePolicy:NSMergeByPropertyObjectTrumpMergePolicy];
                _persistentContainer = container;
            }
        } else {
            if (![self persistentStoreExistsWithStoreURL:persistentStoreURL]) {
                _persistentContainer = nil;
            }
        }
    }
    return _persistentContainer;
}

#pragma mark - Core Data Saving support

- (NSError *)saveContext {
    NSError *error = nil;
    NSManagedObjectContext *context = self.persistentContainer.viewContext;
    @try {
        if (context) {
            if ([context hasChanges] && ![context  save:&error]) {
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

- (void)saveWithContext:(NSManagedObjectContext *)context
             completion:(void (^)(NSError*error))completion {
    @try {
        NSError *error;
        if (!context) {
            error = [NSError errorWithDomain:@"Applozic" code:1 userInfo:@{NSLocalizedDescriptionKey : @"Managed object context is nil"}];
            completion(error);
            return;
        }
        if (context.hasChanges &&
            [context save:&error]) {
            completion(nil);
            return;
        } else {
            if (error) {
                ALSLog(ALLoggerSeverityError, @"DB ERROR in saveWithContext :%@",error);
                [context rollback];
            }
            completion(error);
        }
    } @catch (NSException *exception) {
        ALSLog(ALLoggerSeverityError, @"Unresolved NSException in db saveWithContext %@, %@", exception.reason, [exception userInfo]);
    }
}

- (NSArray *)executeFetchRequest:(NSFetchRequest *)fetchrequest withError:(NSError **)fetchError {
    if (!self.persistentContainer) {
        return nil;
    }
    NSArray *fetchResultArray = nil;
    NSManagedObjectContext *context = self.persistentContainer.viewContext;

    if (context) {
        fetchResultArray = [context executeFetchRequest:fetchrequest
                                                  error:fetchError];
    }
    return fetchResultArray;
}

- (NSEntityDescription *)entityDescriptionWithEntityForName:(NSString *)name {
    if (!self.persistentContainer) {
        return nil;
    }
    NSManagedObjectContext *context = self.persistentContainer.viewContext;

    if (context) {
        return [NSEntityDescription entityForName:name inManagedObjectContext:context];
    }
    return nil;
}

- (NSUInteger)countForFetchRequest:(NSFetchRequest *)fetchrequest {
    if (!self.persistentContainer) {
        return 0;
    }
    NSManagedObjectContext *context = self.persistentContainer.viewContext;
    if (context) {
        NSError *fetchError = nil;
        NSUInteger fetchCount = [context countForFetchRequest:fetchrequest error:&fetchError];
        if (fetchError) {
            return 0;
        }
        return fetchCount;
    }
    return 0;
}

- (NSManagedObject *)existingObjectWithID:(NSManagedObjectID *)objectID {
    NSManagedObject *managedObject = nil;
    if (!self.persistentContainer) {
        return nil;
    }
    NSManagedObjectContext *context = self.persistentContainer.viewContext;
    if (context) {
        NSError *managedObjectError = nil;
        managedObject = [context existingObjectWithID:objectID
                                                error:&managedObjectError];
        if (managedObjectError) {
            ALSLog(ALLoggerSeverityError, @"Error while fetching NSManagedObject %@", managedObjectError);
            return nil;
        }
    }
    return managedObject;
}

- (NSManagedObject *)insertNewObjectForEntityForName:(NSString *) entityName {
    if (!self.persistentContainer) {
        return nil;
    }

    NSManagedObjectContext *context = self.persistentContainer.viewContext;
    if (context) {
        return [NSEntityDescription insertNewObjectForEntityForName:entityName inManagedObjectContext:context];
    }
    return nil;
}

- (void)deleteObject:(NSManagedObject *)managedObject {
    if (!self.persistentContainer) {
        return;
    }
    NSManagedObjectContext *context = self.persistentContainer.viewContext;
    if (context) {
        [context deleteObject:managedObject];
    }
}
- (NSManagedObject *)insertNewObjectForEntityForName:(NSString *)entityName withManagedObjectContext:(NSManagedObjectContext *)context {
    if (context) {
        return [NSEntityDescription insertNewObjectForEntityForName:entityName inManagedObjectContext:context];
    }
    return nil;
}

- (NSBatchUpdateResult *)executeRequestForNSBatchUpdateResult:(NSBatchUpdateRequest *)updateRequest withError:(NSError **)fetchError {
    NSBatchUpdateResult *batchUpdateResult = nil;
    if (!self.persistentContainer) {
        return nil;
    }

    NSManagedObjectContext *context = self.persistentContainer.viewContext;
    if (context) {
        batchUpdateResult = (NSBatchUpdateResult *)[context executeRequest:updateRequest error:fetchError];
    }
    return batchUpdateResult;
}

- (BOOL)persistentStoreExistsWithStoreURL:(NSURL *)url {

    if (url &&
        url.isFileURL &&
        [NSFileManager.defaultManager fileExistsAtPath:url.path]) {
        return YES;
    }
    return NO;
}

/// get the bundle if its SWIFT_PACKAGE will use the runtime bundle of SPM else will use the bundle from class
- (NSBundle*)getBundle {
#if SWIFT_PACKAGE
    return SWIFTPM_MODULE_BUNDLE;
#else
    return [NSBundle bundleForClass:[ALDBHandler class]];
#endif
}

@end
