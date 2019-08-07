//
//  FZVideoEditor.m
//  FZMyLibiary
//
//  Created by 吴福增 on 2019/8/5.
//

#import "FZVideoEditor.h"
#import <AVKit/AVKit.h>
#import "FZAssetManager.h"
@interface FZVideoEditor ()

@property (nonatomic, strong) FZAVCommand* avCommand;

@end

@implementation FZVideoEditor
/** 添加背景音乐 */
- (void)addMusicToAsset:(AVAsset *)asset completion:(void (^)(FZAVCommand *))block{
    
    FZAVAddMusicCommand* musicCommand =
    [[FZAVAddMusicCommand alloc] initWithComposition:self.avCommand.mutableComposition
                                    videoComposition:self.avCommand.mutableVideoComposition
                                            audioMix:self.avCommand.mutableAudioMix];
    
    [musicCommand performWithAsset:asset completion:^(FZAVCommand *avCommand) {
        self.avCommand = avCommand;
        if (block) {
            block(avCommand);
        }
    }];
}
/** 添加水印 */
- (void)addWatermark:(FZWatermarkType)watermarkType inAsset:(AVAsset *)asset completion:(void (^)(FZAVCommand *))block{
    
    FZAVAddWatermarkCommand* watermarkCommand =
    [[FZAVAddWatermarkCommand alloc] initWithComposition:self.avCommand.mutableComposition
                                        videoComposition:self.avCommand.mutableVideoComposition
                                                audioMix:self.avCommand.mutableAudioMix];
    
    [watermarkCommand performWithAsset:asset completion:^(FZAVCommand *avCommand) {
        self.avCommand = avCommand;
        if (block) {
            block(avCommand);
        }
    }];
}

- (void)exportAsset:(AVAsset*)asset{
    FZAVExportCommand* exportCommand = [[FZAVExportCommand alloc] initWithComposition:self.avCommand.mutableComposition videoComposition:self.avCommand.mutableVideoComposition audioMix:self.avCommand.mutableAudioMix];
    
    [exportCommand performWithAsset:asset completion:^(FZAVCommand *avCommand) {
        if (avCommand.executeStatus) {
            NSLog(@"export successfully");
        }else{
            NSLog(@"export fail");
        }
    }];
}
/** 导出裁剪视频 */
-(void)exportClipAsset:(AVAsset *)asset startTime:(CGFloat)startTime endTime:(CGFloat)endTime completedHandler:(void(^)(NSString *path))completedHandler{
    
    // Step 1
    // Create an outputURL to which the exported movie will be saved
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *outputURL = paths[0];
    NSFileManager *manager = [NSFileManager defaultManager];
    [manager createDirectoryAtPath:outputURL withIntermediateDirectories:YES attributes:nil error:nil];
    outputURL = [outputURL stringByAppendingPathComponent:@"output.mp4"];
    // Remove Existing File
    [manager removeItemAtPath:outputURL error:nil];
    
    AVAssetExportSession *exportSession = [[AVAssetExportSession alloc]initWithAsset:asset presetName:AVAssetExportPresetPassthrough];
    exportSession.outputURL = [NSURL fileURLWithPath:outputURL];
    exportSession.outputFileType = AVFileTypeMPEG4;
    CMTime start = CMTimeMakeWithSeconds(startTime, 1);
    CMTime duration = CMTimeMakeWithSeconds(endTime - startTime, 1);
    exportSession.timeRange = CMTimeRangeMake(start, duration);
    [exportSession exportAsynchronouslyWithCompletionHandler:^{
        switch (exportSession.status) {
            case AVAssetExportSessionStatusUnknown :{
                
            }break;
            case AVAssetExportSessionStatusWaiting :{
                
            }break;
            case AVAssetExportSessionStatusExporting :{
                
            }break;
            case AVAssetExportSessionStatusCompleted :{
                [FZAssetManager saveVideo:outputURL toAlbum:@"Album" completion:^(NSURL *url, NSError *error) {
                    if (error) {
                        NSLog(@"save to album failed");
                    }else{
                        NSLog(@"save to album success");
                    }
                }];
                if (completedHandler) {
                    completedHandler(exportSession.outputURL.relativePath);
                }
            }break;
            case AVAssetExportSessionStatusFailed :{
                
            }break;
            case AVAssetExportSessionStatusCancelled :{
                
            }break;
                
            default:break;
        }
    }];
}


/** 获取视频第一帧 */
- (UIImage*)getVideoPreviewImage:(AVAsset *)asset atTimeSec:(double)timeSec{
    if (!asset) {
        return nil;
    }
    //获取视频图像实际开始时间 部分视频并非一开始就是有图像的 因此要获取视频的实际开始片段
    AVAssetTrack *videoTrack = [asset tracksWithMediaType:AVMediaTypeVideo].firstObject;
    NSArray<AVAssetTrackSegment *> *segs = videoTrack.segments;
    if (!segs.count) {
        return nil;
    }
    CMTime currentStartTime = kCMTimeZero;
    for (NSInteger i = 0; i < segs.count; i ++) {
        if (!segs[i].isEmpty) {
            currentStartTime = segs[i].timeMapping.target.start;
            break;
        }
    }
    
    CMTime coverAtTimeSec = CMTimeMakeWithSeconds(timeSec, asset.duration.timescale);
    //如果想要获取的视频时间大于视频总时长 或者小于视频实际开始时间 则设置获取视频实际开始时间
    if (CMTimeCompare(coverAtTimeSec, asset.duration) == 1 ||
        CMTimeCompare(coverAtTimeSec, currentStartTime) == -1) {
        coverAtTimeSec = currentStartTime;
    }
    
    AVAssetImageGenerator *assetGen = [AVAssetImageGenerator assetImageGeneratorWithAsset:asset];
    assetGen.requestedTimeToleranceBefore = kCMTimeZero;
    assetGen.requestedTimeToleranceAfter = kCMTimeZero;
    assetGen.appliesPreferredTrackTransform = YES;
    NSError *error = nil;
    //获取单帧图片
    CGImageRef image = [assetGen copyCGImageAtTime:coverAtTimeSec actualTime:NULL error:&error];
    if (error) {
        return nil;
    }
    UIImage *videoImage = [UIImage imageWithCGImage:image];
    CGImageRelease(image);
    return videoImage;
}

/** 获取中间帧图片 */
- (void)centerFrameImageWithAsset:(AVAsset*)asset
                       completion:(void (^)(UIImage *image))completion {
    AVAssetImageGenerator *imageGenerator = [[AVAssetImageGenerator alloc] initWithAsset:asset];
    /** 应用首选轨道变换 （截图的时候调整到正确的方向） */
    imageGenerator.appliesPreferredTrackTransform = YES;
    CGFloat assetTimeLong = CMTimeGetSeconds(asset.duration);
    
    NSMutableArray* timeArr = [NSMutableArray array];
    for (NSInteger i = 0; i < assetTimeLong; i++) {
        /*
         * CMTime CMTimeMakeWithSeconds(
         *                              Float64 seconds,   //第几秒的截图,是当前视频播放到的帧数的具体时间
         *                              int32_t preferredTimeScale //首选的时间尺度 "每秒的帧数"
         *                              );
         */
        CGFloat fps = 600;
        CMTime midpoint = CMTimeMakeWithSeconds(i, fps);
        NSValue *midTime = [NSValue valueWithCMTime:midpoint];
        [timeArr addObject:midTime];
    }
    /*
     * 生成图像的实际时间将在[requestedTime-tolerance before,requestedTime+toleranceAfter]范围内，
     * 可能会与请求的时间有所不同，以提高效率。
     * 通过kCMTimeZero的公差前和公差后，要求帧精确的图像生成;
     * 这可能导致额外的解码延迟。
     * 默认是kCMTimePositiveInfinity。
     */
    //防止时间出现偏差
    imageGenerator.requestedTimeToleranceBefore = kCMTimeZero;
    imageGenerator.requestedTimeToleranceAfter = kCMTimeZero;
    
    NSInteger timesCount = [timeArr count];
    NSMutableArray *images = [NSMutableArray array];
    [imageGenerator generateCGImagesAsynchronouslyForTimes:timeArr
                                         completionHandler:^(CMTime requestedTime,
                                                             CGImageRef  _Nullable image,
                                                             CMTime actualTime,
                                                             AVAssetImageGeneratorResult result,
                                                             NSError * _Nullable error) {
 
        if (result == AVAssetImageGeneratorSucceeded && image != NULL) {
            UIImage *centerFrameImage = [[UIImage alloc] initWithCGImage:image];
            [images addObject:centerFrameImage];
            dispatch_async(dispatch_get_main_queue(), ^{
                if (completion) {
                    completion(centerFrameImage);
                }
            });
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (completion) {
                    completion(nil);
                }
            });
        }
     
                                             
    }];
}

/** 帧图片 */
- (void)frameImagesWithAsset:(AVAsset*)asset
                       count:(NSInteger)count
                  completion:(void (^)(NSArray <UIImage *>*images))completion {
    AVAssetImageGenerator *imageGenerator = [[AVAssetImageGenerator alloc] initWithAsset:asset];
    /** 应用首选轨道变换 （截图的时候调整到正确的方向） */
    imageGenerator.appliesPreferredTrackTransform = YES;
    CGFloat assetTimeLong = CMTimeGetSeconds(asset.duration);
    
    NSInteger inteval = 1;
    
    if (count) {
        inteval = assetTimeLong / count;
    }
    
    NSMutableArray* timeArr = [NSMutableArray array];
    for (NSInteger i = 0; i < assetTimeLong; i += inteval) {
        /*
         * CMTime CMTimeMakeWithSeconds(
         *                              Float64 seconds,   //第几秒的截图,是当前视频播放到的帧数的具体时间
         *                              int32_t preferredTimeScale //首选的时间尺度 "每秒的帧数"
         *                              );
         */
        CGFloat fps = 600;
        CMTime midpoint = CMTimeMakeWithSeconds(i, fps);
        NSValue *midTime = [NSValue valueWithCMTime:midpoint];
        [timeArr addObject:midTime];
    }
    
    NSInteger timesCount = [timeArr count];
    NSMutableArray *images = [NSMutableArray array];
    //防止时间出现偏差
    imageGenerator.requestedTimeToleranceBefore = kCMTimeZero;
    imageGenerator.requestedTimeToleranceAfter = kCMTimeZero;
    [imageGenerator generateCGImagesAsynchronouslyForTimes:timeArr
                                         completionHandler:^(CMTime requestedTime,
                                                             CGImageRef  _Nullable image,
                                                             CMTime actualTime,
                                                             AVAssetImageGeneratorResult result,
                                                             NSError * _Nullable error) {
                                             
                                             
                                             switch (result) {
                                                 case AVAssetImageGeneratorCancelled:
                                                     NSLog(@"Cancelled");
                                                     break;
                                                 case AVAssetImageGeneratorFailed:
                                                     NSLog(@"Failed");
                                                     break;
                                                 case AVAssetImageGeneratorSucceeded:{
                                                     NSLog(@"success");
                                                     if (image != NULL) {
                                                         UIImage *centerFrameImage = [[UIImage alloc] initWithCGImage:image];
                                                         [images addObject:centerFrameImage];
                                                     }
                                                 }
                                                     break;
                                             }
                                             
                                             if (requestedTime.value/requestedTime.timescale == (timesCount-1)*inteval) {
                                                 NSLog(@"completed");
                                                 dispatch_async(dispatch_get_main_queue(), ^{
                                                     if (completion) {
                                                         completion(images.copy);
                                                     }
                                                 });
                                             }
                                             
                                         }];
}


/**
 *  把视频文件拆成图片保存在沙盒中
 *
 *  @param fileUrl        本地视频文件URL
 *  @param fps            拆分时按此帧率进行拆分
 *  @param completedBlock 所有帧被拆完成后回调
 */
- (void)splitVideo:(NSURL *)fileUrl fps:(CGFloat)fps completedBlock:(void(^)(void))completedBlock {
    if (!fileUrl) {
        return;
    }
    NSDictionary *optDict = @{AVURLAssetPreferPreciseDurationAndTimingKey:@(NO)};
    AVURLAsset *avasset = [[AVURLAsset alloc] initWithURL:fileUrl options:optDict];
    
    CMTime cmtime = avasset.duration; //视频时间信息结构体
    Float64 durationSeconds = CMTimeGetSeconds(cmtime); //视频总秒数
    
    NSMutableArray *times = [NSMutableArray array];
    Float64 totalFrames = durationSeconds * fps; //获得视频总帧数
    CMTime timeFrame;
    for (int i = 1; i <= totalFrames; i++) {
        /*
         * CMTime CMTimeMake (
         *                    int64_t value,    //表示 当前视频播放到的第几桢数
         *                    int32_t timescale //每秒的帧数
         *                    );
         */
        timeFrame = CMTimeMake(i, fps); //第i帧  帧率
        NSValue *timeValue = [NSValue valueWithCMTime:timeFrame];
        [times addObject:timeValue];
    }
    
    NSLog(@"------- start");
    AVAssetImageGenerator *imageGenerator = [[AVAssetImageGenerator alloc] initWithAsset:avasset];
    //防止时间出现偏差
    imageGenerator.requestedTimeToleranceBefore = kCMTimeZero;
    imageGenerator.requestedTimeToleranceAfter = kCMTimeZero;
    
    NSString *cachePath = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject];
    NSInteger timesCount = [times count];
    
    [imageGenerator generateCGImagesAsynchronouslyForTimes:times
                                       completionHandler:^(CMTime requestedTime,
                                                           CGImageRef  _Nullable image,
                                                           CMTime actualTime,
                                                           AVAssetImageGeneratorResult result,
                                                           NSError * _Nullable error) {
                                           
        printf("current-----: %lld\n", requestedTime.value);
        switch (result) {
            case AVAssetImageGeneratorCancelled:
                NSLog(@"Cancelled");
                break;
            case AVAssetImageGeneratorFailed:
                NSLog(@"Failed");
                break;
            case AVAssetImageGeneratorSucceeded: {
                
                NSString *filePath = [cachePath stringByAppendingPathComponent:[NSString stringWithFormat:@"/%lld.png",requestedTime.value]];
                NSData *imgData = UIImagePNGRepresentation([UIImage imageWithCGImage:image]);
                [imgData writeToFile:filePath atomically:YES];
                if (requestedTime.value == timesCount) {
                    NSLog(@"completed");
                    if (completedBlock) {
                        completedBlock();
                    }
                }
            }
                break;
        }
    }];
}

#pragma imageToVideo

-(void)composeVideoWithImages:(NSArray *)images{
    NSMutableArray* imageArr = [NSMutableArray array];
    for (UIImage* image in images) {
        UIImage* newImage = [self imageWithImage:image scaledToSize:CGSizeMake(480, 480)];
        [imageArr addObject:newImage];
    }
    //设置mov路径
    NSArray *paths =NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES);
    NSString *moviePath =[[paths objectAtIndex:0]stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.mov",@"test"]];
    //self.theVideoPath=moviePath;
    
    //定义视频的大小320 480 倍数
    CGSize size =CGSizeMake(480,480);
    
    //        [selfwriteImages:imageArr ToMovieAtPath:moviePath withSize:sizeinDuration:4 byFPS:30];//第2中方法
    
    NSError *error =nil;
    //    转成UTF-8编码
    unlink([moviePath UTF8String]);
    NSLog(@"path->%@",moviePath);
    //     iphone提供了AVFoundation库来方便的操作多媒体设备，AVAssetWriter这个类可以方便的将图像和音频写成一个完整的视频文件
    AVAssetWriter *videoWriter = [[AVAssetWriter alloc] initWithURL:[NSURL fileURLWithPath:moviePath] fileType:AVFileTypeQuickTimeMovie error:&error];
    
    NSParameterAssert(videoWriter);
    if(error)
        NSLog(@"error =%@", [error localizedDescription]);
    //mov的格式设置 编码格式 宽度 高度
    NSDictionary *videoSettings =[NSDictionary dictionaryWithObjectsAndKeys:AVVideoCodecH264,AVVideoCodecKey,
                                  [NSNumber numberWithInt:size.width],AVVideoWidthKey,
                                  [NSNumber numberWithInt:size.height],AVVideoHeightKey,nil];
    
    AVAssetWriterInput *writerInput =[AVAssetWriterInput assetWriterInputWithMediaType:AVMediaTypeVideo outputSettings:videoSettings];
    
    NSDictionary*sourcePixelBufferAttributesDictionary =[NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:kCVPixelFormatType_32ARGB],kCVPixelBufferPixelFormatTypeKey,nil];
    //    AVAssetWriterInputPixelBufferAdaptor提供CVPixelBufferPool实例,
    //    可以使用分配像素缓冲区写入输出文件。使用提供的像素为缓冲池分配通常
    //    是更有效的比添加像素缓冲区分配使用一个单独的池
    AVAssetWriterInputPixelBufferAdaptor *adaptor =[AVAssetWriterInputPixelBufferAdaptor assetWriterInputPixelBufferAdaptorWithAssetWriterInput:writerInput sourcePixelBufferAttributes:sourcePixelBufferAttributesDictionary];
    
    NSParameterAssert(writerInput);
    NSParameterAssert([videoWriter canAddInput:writerInput]);
    
    if ([videoWriter canAddInput:writerInput]){
        [videoWriter addInput:writerInput];
    }
    
    [videoWriter startWriting];
    [videoWriter startSessionAtSourceTime:kCMTimeZero];
    
    //合成多张图片为一个视频文件
    dispatch_queue_t dispatchQueue =dispatch_queue_create("mediaInputQueue",NULL);
    int __block frame =0;
    [writerInput requestMediaDataWhenReadyOnQueue:dispatchQueue usingBlock:^{
        //写入时的逻辑：将数组中的每一张图片多次写入到buffer中，
        while([writerInput isReadyForMoreMediaData])
        {//数组中一共7张图片此时写入490次
            if(++frame >=[imageArr count]*imageArr.count*10)
            {
                [writerInput markAsFinished];
                [videoWriter finishWritingWithCompletionHandler:^{
                    NSLog(@"合成完成");
                }];
                break;
            }
            CVPixelBufferRef buffer =NULL;
            //每张图片写入70次换下一张
            int idx =frame/(imageArr.count*10);
            NSLog(@"idx==%d",idx);
            //将图片转成buffer
            buffer = (CVPixelBufferRef)[self pixelBufferFromCGImage:[[imageArr objectAtIndex:idx] CGImage] size:size];
            
            if (buffer)
            {//添加buffer并设置每个buffer出现的时间，每个buffer的出现时间为第n张除以30（30是一秒30张图片，帧率，也可以自己设置其他值）所以为frame/30，即CMTimeMake(frame,30)为每一个buffer出现的时间点
                if(![adaptor appendPixelBuffer:buffer withPresentationTime:CMTimeMake(frame,30)])//设置每秒钟播放图片的个数
                {
                    NSLog(@"FAIL");
                }
                else
                {
                    NSLog(@"OK");
                }
                
                CFRelease(buffer);
            }
        }
    }];
}

-(UIImage*)imageWithImage:(UIImage*)image scaledToSize:(CGSize)newSize{
    //    新创建的位图上下文 newSize为其大小
    UIGraphicsBeginImageContext(newSize);
    //    对图片进行尺寸的改变
    [image drawInRect:CGRectMake(0,0,newSize.width,newSize.height)];
    //    从当前上下文中获取一个UIImage对象  即获取新的图片对象
    UIImage* newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    // Return the new image.
    return newImage;
}

- (CVPixelBufferRef)pixelBufferFromCGImage:(CGImageRef)image size:(CGSize)size {
    NSDictionary *options =[NSDictionary dictionaryWithObjectsAndKeys:
                            [NSNumber numberWithBool:YES],kCVPixelBufferCGImageCompatibilityKey,
                            [NSNumber numberWithBool:YES],kCVPixelBufferCGBitmapContextCompatibilityKey,nil];
    CVPixelBufferRef pxbuffer =NULL;
    CVReturn status =CVPixelBufferCreate(kCFAllocatorDefault,size.width,size.height,kCVPixelFormatType_32ARGB,(__bridge CFDictionaryRef) options,&pxbuffer);
    
    NSParameterAssert(status ==kCVReturnSuccess && pxbuffer !=NULL);
    
    CVPixelBufferLockBaseAddress(pxbuffer,0);
    
    void *pxdata =CVPixelBufferGetBaseAddress(pxbuffer);
    NSParameterAssert(pxdata !=NULL);
    CGColorSpaceRef rgbColorSpace=CGColorSpaceCreateDeviceRGB();
    //    当你调用这个函数的时候，Quartz创建一个位图绘制环境，也就是位图上下文。当你向上下文中绘制信息时，Quartz把你要绘制的信息作为位图数据绘制到指定的内存块。一个新的位图上下文的像素格式由三个参数决定：每个组件的位数，颜色空间，alpha选项
    CGContextRef context =CGBitmapContextCreate(pxdata,size.width,size.height,8,4*size.width,rgbColorSpace,kCGImageAlphaPremultipliedFirst);
    NSParameterAssert(context);
    //使用CGContextDrawImage绘制图片  这里设置不正确的话 会导致视频颠倒
    //    当通过CGContextDrawImage绘制图片到一个context中时，如果传入的是UIImage的CGImageRef，因为UIKit和CG坐标系y轴相反，所以图片绘制将会上下颠倒
    CGContextDrawImage(context,CGRectMake(0,0,CGImageGetWidth(image),CGImageGetHeight(image)), image);
    // 释放色彩空间
    CGColorSpaceRelease(rgbColorSpace);
    // 释放context
    CGContextRelease(context);
    // 解锁pixel buffer
    CVPixelBufferUnlockBaseAddress(pxbuffer,0);
    
    return pxbuffer;
}
@end
