//
//  FZAVExtractAudioCommand.h
//  FZMyLibiary
//
//  Created by 吴福增 on 2019/8/5.
//  提取音频

#import "FZAVCommand.h"

NS_ASSUME_NONNULL_BEGIN

@interface FZAVExtractAudioCommand : FZAVCommand

@property AVAssetExportSession *exportSession;

@end

NS_ASSUME_NONNULL_END
