//
//  ALContactService.m
//  ChatApp
//
//  Created by Devashish on 23/10/15.
//  Copyright © 2015 AppLogic. All rights reserved.
//

#import "ALContactService.h"
#import "ALContactDBService.h"
#import "ALDBHandler.h"
#import "ALUserDefaultsHandler.h"
#import "ALUserService.h"

@implementation ALContactService

 ALContactDBService * alContactDBService;

-(instancetype)  init{
    self= [super init];
    alContactDBService = [[ALContactDBService alloc] init];
    return self;
}

#pragma mark Deleting APIS


//For purgeing single contacts

-(BOOL)purgeContact:(ALContact *)contact{
    
    return [alContactDBService purgeContact:contact];
}


//For purgeing multiple contacts
-(BOOL)purgeListOfContacts:(NSArray *)contacts{
    
    return [ alContactDBService purgeListOfContacts:contacts];
}


//For delting all contacts at once

-(BOOL)purgeAllContact{
  return  [alContactDBService purgeAllContact];
    
}

#pragma mark Update APIS


-(BOOL)updateContact:(ALContact *)contact{
    return [alContactDBService updateContact:contact];
    
}

-(BOOL)setUnreadCountInDB:(ALContact*)contact{
    return [alContactDBService setUnreadCountDB:contact];
}

-(BOOL)updateListOfContacts:(NSArray *)contacts{
    return [alContactDBService updateListOfContacts:contacts];
}

-(NSNumber *)getOverallUnreadCountForContact
{
   return  [alContactDBService getOverallUnreadCountForContactsFromDB];
}

#pragma mark addition APIS


-(BOOL)addListOfContacts:(NSArray *)contacts{
    return [alContactDBService updateListOfContacts:contacts];

}

-(BOOL)addContact:(ALContact *)userContact{
    return [alContactDBService addContact:userContact];

}

#pragma mark fetching APIS


- (ALContact *)loadContactByKey:(NSString *) key value:(NSString*) value{
    return [alContactDBService loadContactByKey:key value:value];

}

#pragma mark fetching OR SAVE with Serevr call...


- (ALContact *)loadOrAddContactByKeyWithDisplayName:(NSString *) contactId value:(NSString*) displayName{
    
    DB_CONTACT * dbContact = [alContactDBService getContactByKey:@"userId" value:contactId];
    
    ALContact *contact = [[ALContact alloc] init];
    if (!dbContact) {
        contact.userId = contactId;
        contact.displayName = displayName;
        [self addContact:contact];
        [ALUserService updateUserDisplayName:contact];
        return contact;
    }
    contact.userId = dbContact.userId;
    contact.fullName = dbContact.fullName;
    contact.contactNumber = dbContact.contactNumber;
    contact.displayName = dbContact.displayName;
    contact.contactImageUrl = dbContact.contactImageUrl;
    contact.email = dbContact.email;
    contact.localImageResourceName = dbContact.localImageResourceName;
    contact.connected = dbContact.connected;
    contact.lastSeenAt = dbContact.lastSeenAt;
    contact.unreadCount= dbContact.unreadCount;
    
    if(![dbContact.displayName isEqualToString:displayName])
    {
        contact.displayName = displayName;
        [self updateContact:contact];
        [ALUserService updateUserDisplayName:contact];
    }
    
    return contact;
}


//----------------------------------------------------------------------------------------------------------------------
// Helper method for demo purpose. This method shows possible ways to insert contact and save it in local database.
//----------------------------------------------------------------------------------------------------------------------

- (void) insertInitialContacts{

    ALDBHandler * theDBHandler = [ALDBHandler sharedInstance];
    
    //contact 1
    ALContact *contact1 = [[ALContact alloc] init];
    contact1.userId = @"adarshk";
    contact1.fullName = @"Adarsh Kumar";
    contact1.displayName = @"Adarsh";
    contact1.email = @"github@applozic.com";
    contact1.contactImageUrl = nil;
    contact1.localImageResourceName = @"adarsh.jpg";
    
    // contact 2
    ALContact *contact2 = [[ALContact alloc] init];
    contact2.userId = @"marvel";
    contact2.fullName = @"abhishek thapliyal";
    contact2.displayName = @"abhishek";
    contact2.email = @"abhishek@applozic.com";
    contact2.contactImageUrl = nil;
    contact2.localImageResourceName = @"abhishek.jpg";
    
    
    //    Contact -------- Example with json
    
    
    NSString *jsonString =@"{\"userId\": \"applozic\",\"fullName\": \"Applozic\",\"contactNumber\": \"9535008745\",\"displayName\": \"Applozic Support\",\"contactImageUrl\": \"https://cdn-images-1.medium.com/max/800/1*RVmHoMkhO3yoRtocCRHSdw.png\",\"email\": \"devashish@applozic.com\",\"localImageResourceName\":null}";
    ALContact *contact3 = [[ALContact alloc] initWithJSONString:jsonString];
    
    
    
    //     Contact ------- Example with dictonary
    
    
    NSMutableDictionary *demodictionary = [[NSMutableDictionary alloc] init];
    [demodictionary setValue:@"aman999" forKey:@"userId"];
    [demodictionary setValue:@"aman sharma" forKey:@"fullName"];
    [demodictionary setValue:@"75760462" forKey:@"contactNumber"];
    [demodictionary setValue:@"aman" forKey:@"displayName"];
    [demodictionary setValue:@"aman@applozic.com" forKey:@"email"];
    [demodictionary setValue:@"http://images.landofnod.com/is/image/LandOfNod/Letter_Giant_Enough_A_231533_LL/$web_zoom$&wid=550&hei=550&/1308310656/not-giant-enough-letter-a.jpg" forKey:@"contactImageUrl"];
    [demodictionary setValue:nil forKey:@"localImageResourceName"];
    [demodictionary setValue:[ALUserDefaultsHandler getApplicationKey] forKey:@"applicationId"];
    
    ALContact *contact4 = [[ALContact alloc] initWithDict:demodictionary];
    [theDBHandler addListOfContacts:@[contact1, contact2, contact3, contact4]];
   
}

@end
