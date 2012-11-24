//
//  BingImageSearchAPIWrapper.h
//  learnEverything
//
//  Created by Yuanfeng on 2012-11-23.
//
//

#import <Foundation/Foundation.h>
#import "ASIHTTPRequest.h"
#import "JSONKit.h"

@interface BingImageSearchAPIWrapper : NSObject

+ (BingImageSearchAPIWrapper*)sharedInstance;

- (void)requestBingImageSearchInJSONWithQueryStringArray:(NSArray*)queryArray appID:(NSString*)appID numberOfImagesPerPage:(int)numImagesPerPage currentPageNumberStartFrom0:(int)currPageNumber completionBlock:(void (^)(id parsedJSONObject))completion failedBlock:(void (^)(NSError *error))failed usingCachedDataBlock:(void (^)(id parsedJSONObject))usingCachedData;

@end
