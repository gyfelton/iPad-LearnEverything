//
//  BingImageSearchAPIWrapper.m
//  learnEverything
//
//  Created by Yuanfeng on 2012-11-23.
//
//

#import "BingImageSearchAPIWrapper.h"

static BingImageSearchAPIWrapper *sharedInstance;

#define BING_IMAGE_API_BASE_URL @"https://api.datamarket.azure.com/Data.ashx/Bing/Search/v1/Image?"

@implementation BingImageSearchAPIWrapper

+ (BingImageSearchAPIWrapper*)sharedInstance
{
    if (!sharedInstance) {
        @synchronized(self)
        {
            if (!sharedInstance) {
                sharedInstance = [[self alloc] init];
            }
        }
    }
    return sharedInstance;
}

- (id)init
{
    self = [super init];
    if (self) {
    }
    return self;
}

- (void)requestBingImageSearchInJSONWithQueryStringArray:(NSArray*)queryArray appID:(NSString*)appID numberOfImagesPerPage:(int)numImagesPerPage currentPageNumberStartFrom0:(int)currPageNumber completionBlock:(void (^)(id parsedJSONObject))completion failedBlock:(void (^)(NSError *error))failed usingCachedDataBlock:(void (^)(id parsedJSONObject))usingCachedData
{
    NSString *query = @"";
    for (NSString *str in queryArray) {
        query = [query stringByAppendingString:[NSString stringWithFormat:@"'%@'+", str]];
    }
    if ([query length] >= 1) {
        query = [query substringToIndex:[query length]-1]; //Remove the last +
    }
    
    //Query=%27test%27&$top=20&$skip=0&$format=json
    NSString *url = [NSString stringWithFormat:@"%@%@%@%@%d%@%d%@",BING_IMAGE_API_BASE_URL, @"Query=", query, @"&$top=", numImagesPerPage, @"&$skip=", numImagesPerPage*currPageNumber,@"&$format=json"];
    url = [url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    ASIHTTPRequest *searchRequest = [[ASIHTTPRequest alloc] initWithURL:[NSURL URLWithString:url]];
    [searchRequest setUsername:appID];
    [searchRequest setPassword:appID];
    
    __unsafe_unretained ASIHTTPRequest *ptr = searchRequest;
    
    [searchRequest setCompletionBlock:^{
        NSData *raw = [ptr responseData];
        id parsedJSON = [raw objectFromJSONData];
        
        completion(parsedJSON);
    }];
    [searchRequest setFailedBlock:^{
        /*TODO
         usingCachedData block is never implemented, it's up to you to implementing this method by passing back cached data to view controller, like this:
         if (hasCachedData) {
         completion(Cached_data);
         } else{
         failed([ptr error]);
         }
         */
        failed([ptr error]);
    }];
    [searchRequest startAsynchronous];
}

@end
