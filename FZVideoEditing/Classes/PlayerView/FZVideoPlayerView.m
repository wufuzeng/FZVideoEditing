//
//  FZVideoPlayerView.m
//  FZMyLibiary
//
//  Created by 吴福增 on 2019/8/5.
//

#import "FZVideoPlayerView.h"
#import <MediaPlayer/MediaPlayer.h>

@interface  FZVideoPlayerView ()
@property (nonatomic, strong) AVPlayer* player;
@property (nonatomic, strong) AVPlayerLayer* playerLayer;
@property (nonatomic, strong) AVPlayerItem* currentPlayItem;

// indicating index of 'currentPlayItem' in the 'videoQueue'
@property (nonatomic, assign) NSInteger currentItemIndex;

@property (nonatomic, assign) FZPlayerState playerState;

@end

@implementation FZVideoPlayerView

-(instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor blackColor];
    }
    return self;
}


-(void)layoutSubviews{
    [super layoutSubviews];
    self.playerLayer.frame = self.bounds;
}

#pragma mark -- 播放器初始化配置





- (void)configPlayer{
    self.player = [AVPlayer playerWithPlayerItem:self.currentPlayItem];
    self.playerLayer = [AVPlayerLayer playerLayerWithPlayer:self.player];
    //self.playerLayer.frame = self.bounds;
    self.playerLayer.videoGravity = AVLayerVideoGravityResizeAspect;
    [self.layer addSublayer:self.playerLayer];
    self.playerState = FZPlayerStateReadyToPlay;
    __weak typeof(self) weakSelf = self;
    [self.player addPeriodicTimeObserverForInterval:CMTimeMake(1, NSEC_PER_SEC) queue:dispatch_get_main_queue() usingBlock:^(CMTime time) {
        if ([weakSelf.delegate respondsToSelector:@selector(player:didPlayedToTime:)]) {
            [weakSelf.delegate player:weakSelf didPlayedToTime:time];
        }
    }];
    
    [self.currentPlayItem addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew context:nil];
 
    [self addNotifications];
}

- (void)addNotifications{
    /** 播放完成 */
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(moviePlayDidEnd:) name:AVPlayerItemDidPlayToEndTimeNotification object:self.currentPlayItem];
    /** 进入后台 */
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didEnterBackground) name:UIApplicationDidEnterBackgroundNotification object:nil];
    /** 进入前台 */
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(willEnterForeground) name:UIApplicationWillEnterForegroundNotification object:nil];
}

#pragma mark -- MPRemoteCommandCenter --
/** 添加媒体播放遥控器命令 */
- (void)addMediaPlayerRemoteCommands{
    MPRemoteCommandCenter* commandCenter = [MPRemoteCommandCenter sharedCommandCenter];
    
    MPRemoteCommand* pauseCommand = [commandCenter pauseCommand];
    [pauseCommand setEnabled:YES];
    [pauseCommand addTargetWithHandler:^MPRemoteCommandHandlerStatus(MPRemoteCommandEvent * _Nonnull event) {
        [self pause];
        return MPRemoteCommandHandlerStatusSuccess;
    }];
    
    MPRemoteCommand* playCommand = [commandCenter playCommand];
    [playCommand setEnabled:YES];
    [playCommand addTargetWithHandler:^MPRemoteCommandHandlerStatus(MPRemoteCommandEvent * _Nonnull event) {
        [self play];
        return MPRemoteCommandHandlerStatusSuccess;
    }];
    
    MPRemoteCommand* playNextCommand = [commandCenter nextTrackCommand];
    [playNextCommand setEnabled:YES];
    [playNextCommand addTargetWithHandler:^MPRemoteCommandHandlerStatus(MPRemoteCommandEvent * _Nonnull event) {
        [self playNext];
        return MPRemoteCommandHandlerStatusSuccess;
    }];
    
    MPRemoteCommand* playPreCommand = [commandCenter previousTrackCommand];
    [playPreCommand setEnabled:YES];
    [playPreCommand addTargetWithHandler:^MPRemoteCommandHandlerStatus(MPRemoteCommandEvent * _Nonnull event) {
        [self playPrevious];
        return MPRemoteCommandHandlerStatusSuccess;
    }];
    
    if (@available(ios 9.1, *)) {
        MPRemoteCommand* changeProgressCommand = [commandCenter changePlaybackPositionCommand];
        [changeProgressCommand setEnabled:YES];
        [changeProgressCommand addTargetWithHandler:^MPRemoteCommandHandlerStatus(MPRemoteCommandEvent * _Nonnull event) {
            MPChangePlaybackPositionCommandEvent * playbackPositionEvent = (MPChangePlaybackPositionCommandEvent *)event;
            CMTime time = CMTimeMakeWithSeconds(playbackPositionEvent.positionTime, self.player.currentItem.duration.timescale);
            [self seekToTime:time];
            return MPRemoteCommandHandlerStatusSuccess;
        }];
    }
}

- (void)removeMediaPlayerRemoteCommands{
    MPRemoteCommandCenter* commandCenter = [MPRemoteCommandCenter sharedCommandCenter];
    [[commandCenter playCommand] removeTarget:self];
    [[commandCenter pauseCommand] removeTarget:self];
    [[commandCenter nextTrackCommand] removeTarget:self];
    [[commandCenter previousTrackCommand] removeTarget:self];
    if (@available(iOS 9.1, *)) {
        [[commandCenter changePlaybackPositionCommand] removeTarget:self];
    }
}

- (void)updateRemoteInfoCenter{
    if (!self.player) {
        return;
    }
    MPNowPlayingInfoCenter* infoCenter = [MPNowPlayingInfoCenter defaultCenter];
    NSMutableDictionary* info = [NSMutableDictionary dictionary];
    // title
    
    [info setObject:[NSString stringWithFormat:@"歌曲%ld",(long)self.currentItemIndex] forKey:MPMediaItemPropertyTitle];
    [info setObject:[NSString stringWithFormat:@"专辑%ld",(long)self.currentItemIndex] forKey:MPMediaItemPropertyAlbumTitle];
    // cover image
    if (@available(iOS 10.0, *)) {
        MPMediaItemArtwork *artwork = [[MPMediaItemArtwork alloc] initWithBoundsSize:CGSizeMake(250, 250) requestHandler:^UIImage * _Nonnull(CGSize size) {
            UIImage* image = [UIImage imageNamed:@"cover.jpg"];
            return image;
        }];
        [info setObject:artwork forKey:MPMediaItemPropertyArtwork];
    } else {
        // Fallback on earlier versions
    }
    // set screen progress
    NSNumber* duration = @(CMTimeGetSeconds(self.player.currentItem.duration));
    NSNumber* currentTime = @(CMTimeGetSeconds(self.player.currentItem.currentTime));
    [info setObject:duration forKey:MPMediaItemPropertyPlaybackDuration];
    [info setObject:currentTime forKey:MPNowPlayingInfoPropertyElapsedPlaybackTime];
    [info setObject:@(self.player.rate) forKey:MPNowPlayingInfoPropertyPlaybackRate];
    
    infoCenter.nowPlayingInfo = info;
}

#pragma mark -- 视频控制事件 --

- (void)enableAudioTracks:(BOOL)enable inPlayerItem:(AVPlayerItem*)playerItem{
    for (AVPlayerItemTrack *track in playerItem.tracks){
        if ([track.assetTrack.mediaType isEqual:AVMediaTypeAudio]){
            track.enabled = enable;
        }
    }
}

- (void)play{
    self.player.currentItem.audioTimePitchAlgorithm = AVAudioTimePitchAlgorithmVarispeed;
    [self.player play];
    self.playerState = FZPlayerStatePlaying;
    if (self.isUsingRemoteCommand) {
        [self updateRemoteInfoCenter];
    }
}

- (void)pause{
    [self.player pause];
    self.playerState = FZPlayerStateStop;
    if (self.isUsingRemoteCommand) {
        [self updateRemoteInfoCenter];
    }
}

- (void)playWithRate:(CGFloat)rate{
    self.player.currentItem.audioTimePitchAlgorithm = AVAudioTimePitchAlgorithmVarispeed;
    self.player.rate = rate;
    [self.player play];
    self.playerState = FZPlayerStatePlaying;
    if (self.isUsingRemoteCommand) {
        [self updateRemoteInfoCenter];
    }
}

- (void)playNext{
    if (!self.videoQueue.count) {
        return;
    }
    ++self.currentItemIndex >= self.videoQueue.count ? self.currentItemIndex = 0 : 1;
    AVAsset* nextAsset = [self.videoQueue objectAtIndex:self.currentItemIndex];
    self.currentPlayItem = [AVPlayerItem playerItemWithAsset:nextAsset];
    [self replaceItemWithAsset:nextAsset];
    [self play];
}

- (void)playPrevious{
    if (!self.videoQueue.count) {
        return;
    }
    --self.currentItemIndex < 0 ? self.currentItemIndex = (int)self.videoQueue.count - 1 : 1;
    AVAsset* preAsset = [self.videoQueue objectAtIndex:self.currentItemIndex];
    self.currentPlayItem = [AVPlayerItem playerItemWithAsset:preAsset];
    [self replaceItemWithAsset:preAsset];
    [self play];
}

- (void)seekToTime:(CMTime)time{
    [self.player seekToTime:time];
}

- (void)seekToSeconds:(CGFloat)seconds isPlay:(BOOL)isPlay{
    [self.player pause];
    
    CMTime time = CMTimeMakeWithSeconds(seconds, 600);
    [self.player seekToTime:time];
    if (isPlay && self.player.status == AVPlayerStatusReadyToPlay) {
        [self.player play];
    }else{
        [self.player pause];
    }
//    __weak __typeof(self) weakSelf = self;
//    [self.player seekToTime:time completionHandler:^(BOOL finished) {
//        if (isPlay && weakSelf.player.status == AVPlayerStatusReadyToPlay) {
//            [weakSelf.player play];
//        }else{
//            [weakSelf.player pause];
//        }
//    }];
}

- (void)destroy{
    [self pause];
    self.player = nil;
    if (self.isUsingRemoteCommand) {
        [self removeMediaPlayerRemoteCommands];
    }
}

#pragma mark -- 通知响应事件 --

- (void)moviePlayDidEnd:(NSNotification*)notification{
    if (self.singleCirclePlay) {
        [self.player seekToTime:kCMTimeZero completionHandler:^(BOOL finished) {
            [self play];
        }];
    }else{
        if (self.videoQueue.count) {
            [self playNext];
        }
    }
}

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context{
    if ([keyPath isEqualToString:@"status"]) {
        AVPlayerItemStatus status = [change[NSKeyValueChangeNewKey]intValue];
        switch (status) {
            case AVPlayerItemStatusFailed:
                break;
            case AVPlayerItemStatusReadyToPlay:
                [self updateRemoteInfoCenter];
                if ([self.delegate respondsToSelector:@selector(player:readyToPlayVideoOfIndex:)]) {
                    [self.delegate player:self readyToPlayVideoOfIndex:self.currentItemIndex];
                }
                break;
            case AVPlayerItemStatusUnknown:
                break;
            default:
                break;
        }
    }
    //移除监听（观察者）
    [object removeObserver:self forKeyPath:@"status"];
}

- (void)didEnterBackground{
    self.playerLayer.player = nil;
}

- (void)willEnterForeground{
    self.playerLayer.player = self.player;
}

#pragma mark -- 设置播放源

-(void)setVideoURL:(NSURL *)videoURL{
    _videoURL = videoURL;
    self.currentPlayItem = [AVPlayerItem playerItemWithURL:videoURL];
    [self.player replaceCurrentItemWithPlayerItem:self.currentPlayItem];
    [self configPlayer];
}

-(void)setAsset:(AVAsset *)asset{
    _asset = asset;
    self.currentPlayItem = [AVPlayerItem playerItemWithAsset:asset];
    [self.player replaceCurrentItemWithPlayerItem:self.currentPlayItem];
    [self configPlayer];
}
-(void)setVideoQueue:(NSArray<AVAsset *> *)videoQueue{
    if (videoQueue.count) {
        _videoQueue = videoQueue;
        if ([[videoQueue firstObject] isKindOfClass:[AVAsset class]]) {
            self.currentPlayItem = [AVPlayerItem playerItemWithAsset:videoQueue.firstObject];
            [self configPlayer];
        }
    }
}
- (void)replaceItemWithAsset:(AVAsset *)asset{
    self.currentPlayItem = [AVPlayerItem playerItemWithAsset:asset];
    [self.player replaceCurrentItemWithPlayerItem:self.currentPlayItem];
    
    [[NSNotificationCenter defaultCenter]addObserver:self
                                            selector:@selector(moviePlayDidEnd:)
                                                name:AVPlayerItemDidPlayToEndTimeNotification
                                              object:self.currentPlayItem];
    [self.currentPlayItem addObserver:self
                           forKeyPath:@"status"
                              options:NSKeyValueObservingOptionNew
                              context:nil];
    
    [self play];
}

- (void)setIsUsingRemoteCommand:(BOOL)isUsingRemoteCommand{
    _isUsingRemoteCommand = isUsingRemoteCommand;
    if (isUsingRemoteCommand) {
        [[UIApplication sharedApplication] beginReceivingRemoteControlEvents];
        [self addMediaPlayerRemoteCommands];
    }
}


-(void)dealloc{
    NSLog(@"player view dealloc");
    if (self.isUsingRemoteCommand) {
        [self removeMediaPlayerRemoteCommands];
    }
    [[NSNotificationCenter defaultCenter] removeObserver:self name:AVPlayerItemDidPlayToEndTimeNotification object:self.currentPlayItem];
    [[UIApplication sharedApplication] endReceivingRemoteControlEvents];
}

@end
