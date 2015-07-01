//
//  JSONUtil.m
//  BabyAlbum
//
//  Created by ITS 段建勇 on 11-11-22.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "JSONUtil.h"
#import "CommonUtil.h"             // 共同方法
//#import "CommonUtil+User.h"        // 关于用户的静态方法
#import "CommonUtil+Date.h"        // 关于时间的静态方法
//#import "CommonUtil+Files.h"       // 关于文件管理的静态方法

@implementation JSONUtil

+ (NSDictionary *)analyData:(NSData *)responseData {
	
	int encodes[] = 
	{
		NSUTF8StringEncoding,			// UTF-8
		NSUnicodeStringEncoding,		// Unicode
		NSShiftJISStringEncoding,		// Shift_JIS
		NSJapaneseEUCStringEncoding,	// EUC-JP
		NSISO2022JPStringEncoding,		// JIS
		NSASCIIStringEncoding			// ASCII
	};
	
	NSString *responseBody = nil;
	
	
	int max = sizeof(encodes) / sizeof(encodes[0]);
	
	for (int i = 0; i < max; i++)
	{
		responseBody = [[[NSString alloc] initWithData:responseData encoding:encodes[i]] autorelease];
		
		if (responseBody != nil)
		{
			break;
		}
	}
		
	return [self analyString:responseBody];
}

+ (NSDictionary *)analyString:(NSString *)responseString {
    NSLog(@"responseString=%@",responseString);
	if ([CommonUtil isEmpty:responseString]) {
		return nil;
	}
	//JSON処理
	return (NSDictionary *)[responseString JSONValue];
}

+ (NSString *)toJson:(id)obj {
	return [obj JSONRepresentation];
}

@end
