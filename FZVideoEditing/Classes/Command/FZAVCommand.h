//
//  FZAVCommand.h
//  FZMyLibiary
//
//  Created by 吴福增 on 2019/8/5.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
NS_ASSUME_NONNULL_BEGIN

@interface FZAVCommand : NSObject

/** 可变集合 */
@property (nonatomic, strong) AVMutableComposition* mutableComposition;
/** 可变视频集合 */
@property (nonatomic, strong) AVMutableVideoComposition* mutableVideoComposition;
/** 可变音频 */
@property (nonatomic, strong) AVMutableAudioMix* mutableAudioMix;

// The execution state of the command / success or not
@property (nonatomic, assign) BOOL executeStatus;

- (instancetype)initWithComposition:(AVMutableComposition *)composition videoComposition:(AVMutableVideoComposition *)videoComposition audioMix:(AVMutableAudioMix *)audioMix;

- (void)performWithAsset:(AVAsset *)asset completion:(void(^)(FZAVCommand* avCommand))block;


@end

NS_ASSUME_NONNULL_END
