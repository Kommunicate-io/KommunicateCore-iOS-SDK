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
    
    NSURL *modelURL = [[NSBundle bundleForClass:[self class]]URLForResource:@"AppLozic" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    
    return _managedObjectModel;
}

-(NSPersistentContainer *)persistentContainer {

    @synchronized (self) {
        NSURL *storeURL = [ALUtilityClass getApplicationDirectoryWithFilePath:AL_SQLITE_FILE_NAME];

        if (_persistentContainer == nil) {
            NSPersistentContainer *container = [[NSPersistentContainer alloc] initWithName:@"AppLozic" managedObjectModel:self.managedObjectModel];

            NSPersistentStoreDescription * persistentStoreDescription = [[NSPersistentStoreDescription alloc] initWithURL:storeURL];
            persistentStoreDescription.shouldMigrateStoreAutomatically = YES;
            persistentStoreDescription.shouldInferMappingModelAutomatically = YES;
            container.persistentStoreDescriptions = @[persistentStoreDescription];

            [container loadPersistentStoresWithCompletionHandler:^(NSPersistentStoreDescription * description, NSError * error) {
                if (error) {
                    NSLog(@"Failed to load Core Data stack: %@", error);
                    self->_isStoreLoaded = NO;
                    return;
                }
                self->_isStoreLoaded = YES;
            }];

            if (self.isStoreLoaded) {
                [container.viewContext setMergePolicy:NSMergeByPropertyObjectTrumpMergePolicy];
                _persistentContainer = container;
            }
        } else {
            if (![self persistentStoreExistsWithStoreURL:storeURL]) {
                _persistentContainer = nil;
            }
        }
    }
    return _persistentContainer;
}

#pragma mark - Core Data Saving support

- (NSError *)saveContext {
    NSError *error = nil;
    NSManagedObjectContext * context = self.persistentContainer.viewContext;
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

- (void) saveWithContext:(NSManagedObjectContext*)context
              completion:(void (^)(NSError*error))completion {
    @try {
        NSError* error;
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

-(NSArray *)executeFetchRequest:(NSFetchRequest *)fetchrequest withError: (NSError **)fetchError {
    if (!self.persistentContainer) {
        return nil;
    }
    NSArray * fetchResultArray = nil;
    NSManagedObjectContext *context = self.persistentContainer.viewContext;

    if (context) {
        fetchResultArray = [context executeFetchRequest:fetchrequest
                                                  error:fetchError];
    }
    return fetchResultArray;
}

-(NSEntityDescription *)entityDescriptionWithEntityForName:(NSString *)name {
    if (!self.persistentContainer) {
        return nil;
    }
    NSManagedObjectContext *context = self.persistentContainer.viewContext;

    if (context) {
        return [NSEntityDescription entityForName:name inManagedObjectContext:context];
    }
    return nil;
}

-(NSUInteger)countForFetchRequest:(NSFetchRequest *)fetchrequest {
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

-(NSManagedObject*)existingObjectWithID:(NSManagedObjectID *)objectID {
    NSManagedObject* managedObject = nil;
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

-(NSManagedObject *)insertNewObjectForEntityForName:(NSString *) entityName {
    if (!self.persistentContainer) {
        return nil;
    }

    NSManagedObjectContext *context = self.persistentContainer.viewContext;
    if (context) {
        return [NSEntityDescription insertNewObjectForEntityForName:entityName inManagedObjectContext:context];
    }
    return nil;
}

-(void)deleteObject:(NSManagedObject *) managedObject {
    if (!self.persistentContainer) {
        return;
    }
    NSManagedObjectContext *context = self.persistentContainer.viewContext;
    if (context) {
        [context deleteObject:managedObject];
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
    if (!self.persistentContainer) {
        return nil;
    }

    NSManagedObjectContext *context = self.persistentContainer.viewContext;
    if (context) {
        batchUpdateResult = (NSBatchUpdateResult *)[context executeRequest:updateRequest error:fetchError];
    }
    return batchUpdateResult;
}

-(BOOL)persistentStoreExistsWithStoreURL:(NSURL *)url {

    if (url &&
        url.isFileURL &&
        [NSFileManager.defaultManager fileExistsAtPath:url.path]) {
        return YES;
    }
    return NO;
}

@end
