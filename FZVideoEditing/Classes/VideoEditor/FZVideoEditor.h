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


/** 导出裁剪视频 */
-(void)exportClipAsset:(AVAsset *)asset startTime:(CGFloat)startTime endTime:(CGFloat)endTime completedHandler:(void(^)(NSString *path))completedHandler;

 
/** 获取视频第一帧 */
- (UIImage*)getVideoPreviewImage:(AVAsset *)asset atTimeSec:(double)timeSec;
/** 获取中间帧图片 */
- (void)centerFrameImageWithAsset:(AVAsset*)asset
                       completion:(void (^)(UIImage *image))completion;
/** 帧图片 */
- (void)frameImagesWithAsset:(AVAsset*)asset
                       count:(NSInteger)count
                  completion:(void (^)(NSArray <UIImage *>*images))completion;
/**
 *  把视频文件拆成图片保存在沙盒中
 *
 *  @param fileUrl        本地视频文件URL
 *  @param fps            拆分时按此帧率进行拆分
 *  @param completedBlock 所有帧被拆完成后回调
 */
- (void)splitVideo:(NSURL *)fileUrl fps:(CGFloat)fps completedBlock:(void(^)(void))completedBlock;
/**
 * @brief 制作一个时长为15s的视频，帧率为30
 */
- (void)composeVideoWithImages:(NSArray*)images;


@end

NS_ASSUME_NONNULL_END
