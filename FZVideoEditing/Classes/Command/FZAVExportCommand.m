//
//  FZAVExportCommand.m
//  FZMyLibiary
//
//  Created by 吴福增 on 2019/8/5.
//

#import "FZAVExportCommand.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import "FZAssetManager.h"

@implementation FZAVExportCommand
- (void)performWithAsset:(AVAsset *)asset completion:(void(^)(FZAVCommand* avCommand))block{
    
    AVAssetTrack *assetVideoTrack = nil;
    AVAssetTrack *assetAudioTrack = nil;
    // Check if the asset contains video and audio tracks
    if ([[asset tracksWithMediaType:AVMediaTypeVideo] count] != 0) {
        assetVideoTrack = [asset tracksWithMediaType:AVMediaTypeVideo][0];
    }
    if ([[asset tracksWithMediaType:AVMediaTypeAudio] count] != 0) {
        assetAudioTrack = [asset tracksWithMediaType:AVMediaTypeAudio][0];
    }
    
    CMTime insertionPoint = kCMTimeZero;
    NSError *error = nil;
    
    if (!self.mutableComposition) {
        self.mutableComposition  = [AVMutableComposition composition];
        
        if (assetVideoTrack != nil) {
            AVMutableCompositionTrack *compositionVideoTrack = [self.mutableComposition addMutableTrackWithMediaType:AVMediaTypeVideo preferredTrackID:kCMPersistentTrackID_Invalid];
            [compositionVideoTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, [asset duration]) ofTrack:assetVideoTrack atTime:insertionPoint error:&error];
        }
        if (assetAudioTrack != nil) {
            AVMutableCompositionTrack *compositionAudioTrack = [self.mutableComposition addMutableTrackWithMediaType:AVMediaTypeAudio preferredTrackID:kCMPersistentTrackID_Invalid];
            [compositionAudioTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, [asset duration]) ofTrack:assetAudioTrack atTime:insertionPoint error:&error];
        }
    }
    
    // Step 1
    // Create an outputURL to which the exported movie will be saved
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *outputURL = paths[0];
    NSFileManager *manager = [NSFileManager defaultManager];
    [manager createDirectoryAtPath:outputURL withIntermediateDirectories:YES attributes:nil error:nil];
    outputURL = [outputURL stringByAppendingPathComponent:@"output.mp4"];
    // Remove Existing File
    [manager removeItemAtPath:outputURL error:nil];
    
    
    // Step 2
    // Create an export session with the composition and write the exported movie to the photo library
    
    self.exportSession = [[AVAssetExportSession alloc] initWithAsset:[self.mutableComposition copy] presetName:AVAssetExportPreset1280x720];
    
    self.exportSession.videoComposition = self.mutableVideoComposition;
    self.exportSession.audioMix = self.mutableAudioMix;
    self.exportSession.outputURL = [NSURL fileURLWithPath:outputURL];
    self.exportSession.outputFileType=AVFileTypeMPEG4;
    
    [self.exportSession exportAsynchronouslyWithCompletionHandler:^(void){
        switch (self.exportSession.status) {
            case AVAssetExportSessionStatusCompleted:
                [self writeVideoToPhotoLibrary:outputURL];
                if (block) {
                    block(self);
                }
                
                break;
            case AVAssetExportSessionStatusFailed:
                NSLog(@"Failed:%@",self.exportSession.error);
                self.executeStatus = NO;
                if (block) {
                    block(self);
                }
                break;
            case AVAssetExportSessionStatusCancelled:
                NSLog(@"Canceled:%@",self.exportSession.error);
                self.executeStatus = NO;
                if (block) {
                    block(self);
                }
                break;
            default:
                break;
        }
    }];
}

- (void)writeVideoToPhotoLibrary:(NSString *)url{
    [FZAssetManager saveVideo:url toAlbum:@"Album" completion:^(NSURL *url, NSError *error) {
        if (error) {
            NSLog(@"save to album failed");
        }else{
            NSLog(@"save to album success");
        }
    }];
}

@end
