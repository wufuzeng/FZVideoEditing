//
//  FZMediaInfo.h
//  FZMyLibiary
//
//  Created by 吴福增 on 2019/8/5.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

typedef NS_ENUM(NSUInteger, FZVideoOrientation)
{
    FZVideoOrientationPortrait           = 0,
    FZVideoOrientationLandscapeRight     = 1,
    FZVideoOrientationPortraitUpsideDown = 2,
    FZVideoOrientationLandscapeLeft      = 3
};
NS_ASSUME_NONNULL_BEGIN
// 获取视频分辨率，帧率，帧间隔，编码输出码率，视频方向，时长，大小，
// 音频采样率，码率，
@interface FZMediaInfo : NSObject
// videoInfo

@property (nonatomic, assign) float videoWidth;
@property (nonatomic, assign) float videoHeight;
@property (nonatomic, assign) float videoFrameRate;
@property (nonatomic, assign) float videoOutputBitrate;
@property (nonatomic, assign) FZVideoOrientation videoOrientation;
@property (nonatomic, assign) CMTime videoDuration;
@property (nonatomic, assign) long long videoByte;

// audioInfo
@end

NS_ASSUME_NONNULL_END
