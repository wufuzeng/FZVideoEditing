//
//  FZAVAddMusicCommand.m
//  FZMyLibiary
//
//  Created by 吴福增 on 2019/8/5.
//

#import "FZAVAddMusicCommand.h"

@implementation FZAVAddMusicCommand

-(void)performWithAsset:(AVAsset *)asset completion:(void(^)(FZAVCommand* avCommand))block{
    
    AVAssetTrack* videoTrack = nil;
    AVAssetTrack* audioTrack = nil;
    
    if ([asset tracksWithMediaType:AVMediaTypeVideo].count != 0) {
        videoTrack = [asset tracksWithMediaType:AVMediaTypeVideo][0];
    }
    if ([asset tracksWithMediaType:AVMediaTypeAudio].count != 0) {
        audioTrack = [asset tracksWithMediaType:AVMediaTypeAudio][0];
    }
    NSError* error = nil;
    NSString* audioURL = [[NSBundle mainBundle] pathForResource:@"Music" ofType:@"m4a"];
    AVAsset* audioAsset = [[AVURLAsset alloc] initWithURL:[NSURL fileURLWithPath:audioURL] options:nil];
    AVAssetTrack* newAudioTrack = [audioAsset tracksWithMediaType:AVMediaTypeAudio][0];
    
    if (!self.mutableComposition) {
        self.mutableComposition = [AVMutableComposition composition];
    }
    if (videoTrack) {
        AVMutableCompositionTrack* compositionVideoTrack =
        // 添加视频轨道
        [self.mutableComposition addMutableTrackWithMediaType:AVMediaTypeVideo
                                             preferredTrackID:kCMPersistentTrackID_Invalid];
        // 插入视频轨道
        [compositionVideoTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, [asset duration])
                                       ofTrack:videoTrack
                                        atTime:kCMTimeZero
                                         error:&error];
    }
    
    if (audioTrack) {
        // 添加音频轨道
        AVMutableCompositionTrack* compositionAudioTrack =
        [self.mutableComposition addMutableTrackWithMediaType:AVMediaTypeAudio
                                             preferredTrackID:kCMPersistentTrackID_Invalid];
        // 插入音频轨道
        [compositionAudioTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, [asset duration]) ofTrack:audioTrack atTime:kCMTimeZero error:&error];
    }
    
    if (newAudioTrack) {
        // 添加音频轨道
        AVMutableCompositionTrack* customAudioTrack =
        [self.mutableComposition addMutableTrackWithMediaType:AVMediaTypeAudio
                                             preferredTrackID:kCMPersistentTrackID_Invalid];
        // 插入音频轨道
        [customAudioTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, [self.mutableComposition duration])
                                  ofTrack:newAudioTrack atTime:kCMTimeZero error:&error];
    }
    
    /*
     AVMutableAudioMixInputParameters* mixParameters =
     [AVMutableAudioMixInputParameters audioMixInputParametersWithTrack:newAudioTrack];
     [mixParameters setVolumeRampFromStartVolume:1
     toEndVolume:0
     timeRange:CMTimeRangeMake(kCMTimeZero, self.mutableComposition.duration)];
     */
    self.mutableAudioMix = [AVMutableAudioMix audioMix];
    //self.mutableAudioMix.inputParameters = @[mixParameters];
    
    
    if (block) {
        block(self);
    }
}

@end
