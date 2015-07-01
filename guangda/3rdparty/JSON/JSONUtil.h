//
//  JSONUtil.h
//  BabyAlbum
//
//  Created by ITS 段建勇 on 11-11-22.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JSON.h"

@interface JSONUtil : NSObject {

}

+ (NSDictionary *)analyData:(NSData *)responseData;
+ (NSDictionary *)analyString:(NSString *)responseString;

+ (NSString *)toJson:(id)obj;

@end
