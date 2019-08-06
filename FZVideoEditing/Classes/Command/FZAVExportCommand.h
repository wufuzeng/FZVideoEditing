//
//  FZAVExportCommand.h
//  FZMyLibiary
//
//  Created by 吴福增 on 2019/8/5.
//  导出

#import "FZAVCommand.h"

NS_ASSUME_NONNULL_BEGIN

@interface FZAVExportCommand : FZAVCommand
@property AVAssetExportSession *exportSession;
@end

NS_ASSUME_NONNULL_END
