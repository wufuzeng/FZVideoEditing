//
//  FZVideoEditor.h
//  FZMyLibiary
//
//  Created by 吴福增 on 2019/8/5.
//

#import <Foundation/Foundation.h>
#import "FZAVCommand.h"
#import "FZAVExtractAudioCommand.h"
#import "FZAVAddMusicCommand.h"
#import "FZAVAddWatermarkCommand.h"
#import "FZAVExportCommand.h"

NS_ASSUME_NONNULL_BEGIN

@interface FZVideoEditor : NSObject

/** 添加背景音乐 */
- (void)addMusicToAsset:(AVAsset*)asset completion:(void(^)(FZAVCommand*avCommand))block;
/** 添加水印 */
- (void)addWatermark:(FZWatermarkType)watermarkType inAsset:(AVAsset*)asset completion:(void(^)(FZAVCommand *avCommand))block;
/** 导出媒体 */
- (void)exportAsset:(AVAsset*)asset;

/** 获取视频中间帧图片集 */
- (void)centerFrameImageWithAsset:(AVAsset*)asset completion:(void (^)(UIImage *image))completion;

/**
 * @brief 制作一个时长为15s的视频，帧率为30
 */
- (void)composeVideoWithImages:(NSArray*)images;


@end

NS_ASSUME_NONNULL_END
