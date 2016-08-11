//
//  ALFileMetaInfo.m
//  ChatApp
//
//  Created by shaik riyaz on 23/08/15.
//  Copyright (c) 2015 AppLogic. All rights reserved.
//

#import "ALFileMetaInfo.h"

@implementation ALFileMetaInfo



-(NSString *)getTheSize
{
    
    if ((self.size.intValue/1024.0)/1024.0 >= 1) {
        
        return [NSString stringWithFormat:@" %.1f mb",(self.size.intValue/1024.0)/1024.0];
    }
    else
    {
        return [NSString stringWithFormat:@" %d kb",self.size.intValue/1024];
    }
    
}

-(ALFileMetaInfo *) populate:(NSDictionary *)dict {
    self.blobKey=[dict objectForKey:@"blobKey"];
    self.contentType=[dict objectForKey:@"contentType"];
    self.createdAtTime= @([[dict objectForKey:@"createdAtTime"] doubleValue]);
    self.key=[dict objectForKey:@"key"];
    self.name=[dict objectForKey:@"name"];
    self.size=[dict objectForKey:@"size"];
    self.userKey=[dict objectForKey:@"suUserKeyString"];
    self.thumbnailUrl=[dict objectForKey:@"thumbnailUrl"];
    self.url= [dict objectForKey:@"url"];
    return self;

}

@end
