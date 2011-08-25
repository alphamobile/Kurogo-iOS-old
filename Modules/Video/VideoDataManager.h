#import <Foundation/Foundation.h>
#import "KGORequestManager.h"
#import "Reachability.h"
#import "Video.h"

typedef void (^VideoDataRequestResponse)(id result);

@class VideoDataManager; 

@interface VideoDataManager : NSObject<KGORequestDelegate> {
    
}

#pragma mark Public
- (BOOL)requestSectionsThenRunBlock:(VideoDataRequestResponse)responseBlock;

- (BOOL)requestVideosForSection:(NSString *)section 
                   thenRunBlock:(VideoDataRequestResponse)responseBlock;

- (BOOL)requestVideoForDetailSection:(NSString *)section andVideoID:(NSString *)videoID 
                   thenRunBlock:(VideoDataRequestResponse)responseBlock;

- (BOOL)requestSearchOfSection:(NSString *)section 
                         query:(NSString *)query
                  thenRunBlock:(VideoDataRequestResponse)responseBlock;

- (NSArray *)bookmarkedVideos;
- (void)pruneVideos; 

// Key: KGORequest. Value: VideoDataRequestResponse.
@property (nonatomic, retain) NSMutableDictionary *responseBlocksForRequestPaths; 
@property (nonatomic, retain) NSMutableSet *pendingRequests; 
@property (nonatomic, retain) NSString *moduleTag;
@property (nonatomic, retain) NSArray *sections;
@property (nonatomic, retain) NSMutableArray *videos;
@property (nonatomic, retain) NSMutableArray *videosFromCurrentSearch;
@property (nonatomic, retain) NSMutableArray *detailVideo;
@property (nonatomic, retain) Reachability *reachability;




@end
