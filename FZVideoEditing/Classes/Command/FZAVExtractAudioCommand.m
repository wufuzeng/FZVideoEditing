//
//  FZAVExtractAudioCommand.m
//  FZMyLibiary
//
//  Created by 吴福增 on 2019/8/5.
//

#import "FZAVExtractAudioCommand.h"

#import "FZAssetManager.h"

@implementation FZAVExtractAudioCommand

- (void)performWithAsset:(AVAsset *)asset completion:(void(^)(FZAVCommand* avCommand))block{
    
    // Step 1
    // Create an outputURL to which the exported movie will be saved
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *outputURL = paths[0];
    NSFileManager *manager = [NSFileManager defaultManager];
    [manager createDirectoryAtPath:outputURL withIntermediateDirectories:YES attributes:nil error:nil];
    outputURL = [outputURL stringByAppendingPathComponent:@"captureMusic.m4a"];
    // Remove Existing File
    [manager removeItemAtPath:outputURL error:nil];
    
    // step2
    self.exportSession = [AVAssetExportSession exportSessionWithAsset:asset presetName:AVAssetExportPresetAppleM4A];
    self.exportSession.outputURL = [NSURL fileURLWithPath:outputURL];
    self.exportSession.outputFileType = AVFileTypeAppleM4A;
    self.exportSession.timeRange = CMTimeRangeMake(kCMTimeZero, asset.duration);
    
    // step3
    [self.exportSession exportAsynchronouslyWithCompletionHandler:^{
        switch (self.exportSession.status) {
            case AVAssetExportSessionStatusCompleted:
                NSLog(@"导出音频成功");
                [self writeVideoToPhotoLibrary:outputURL];
                if (block) {
                    block(self);
                }
                break;
            case AVAssetExportSessionStatusFailed:
                NSLog(@"导出音频失败");
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
    [FZAssetManager saveVideo:url toAlbum:@"RXAlbum" completion:^(NSURL *url, NSError *error) {
        if (error) {
            NSLog(@"save to album failed");
        }else{
            NSLog(@"save to album success");
        }
    }];
}


@end
