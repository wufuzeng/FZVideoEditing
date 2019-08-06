//
//  FZVideoPlayerView.h
//  FZMyLibiary
//
//  Created by 吴福增 on 2019/8/5.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, FZPlayerState){
    FZPlayerStateReadyToPlay = 0,
    FZPlayerStatePlaying     = 1,
    FZPlayerStateStop        = 2,
    FZPlayerStateFailed      = 3
};

@class FZVideoPlayerView;
@protocol FZVideoPlayerViewDelegate <NSObject>
@optional
/** 播放进度 */
- (void)player:(FZVideoPlayerView *)player didPlayedToTime:(CMTime)time;
/** 准备播放 */
- (void)player:(FZVideoPlayerView *)player readyToPlayVideoOfIndex:(NSInteger)index;

@end

@interface FZVideoPlayerView : UIView
/** 媒体 */
@property (nonatomic, strong) AVAsset* asset;
/** 链接 */
@property (nonatomic, strong) NSURL* videoURL;
/**
 @brief  the queue of videos to play, if it's null, the functions 'playNext' and 'playPrevious' will be unable;
 */
@property (nonatomic, strong) NSMutableArray<AVAsset *>* videoQueue;
/** 自动播放 */
@property (nonatomic, assign) BOOL autoPlay;
/** 单循环 */
@property (nonatomic, assign) BOOL singleCirclePlay;
/** 播放状态 */
@property (nonatomic, assign, readonly) FZPlayerState playerState;
/** 当前播放 */
@property (nonatomic, strong, readonly) AVPlayerItem* currentPlayItem;
/** 是否使用遥控器 */
@property (nonatomic, assign) BOOL isUsingRemoteCommand;

@property (nonatomic,   weak)id <FZVideoPlayerViewDelegate> delegate;

- (instancetype)initWithAsset:(AVAsset *)asset frame:(CGRect)frame;
- (instancetype)initWithVideoURL:(NSURL*)videoURL frame:(CGRect)frame;
- (instancetype)initWithVideoQueue:(NSMutableArray*)videoQueue frame:(CGRect)frame;

- (void)play;
- (void)pause;
/** 播放速度 */
- (void)playWithRate:(CGFloat)rate;

- (void)playPrevious;
- (void)playNext;

- (void)seekToTime:(CMTime)time;

- (void)replaceItemWithAsset:(AVAsset *)asset;

- (void)destroy;

@end

NS_ASSUME_NONNULL_END
