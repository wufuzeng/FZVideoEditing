//
//  FZAVAddWatermarkCommand.h
//  FZMyLibiary
//
//  Created by 吴福增 on 2019/8/5.
//  添加水印

#import "FZAVCommand.h"
#import <QuartzCore/QuartzCore.h>
NS_ASSUME_NONNULL_BEGIN
typedef NS_ENUM(NSUInteger, FZWatermarkType)
{
    /* Use pictures as watermarks. */
    FZWatermarkTypeImage = 0,
    /* Use text as watermarks. */
    FZWatermarkTypeText = 1
};
@interface FZAVAddWatermarkCommand : FZAVCommand

@end

NS_ASSUME_NONNULL_END
