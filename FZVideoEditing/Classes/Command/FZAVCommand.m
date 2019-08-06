//
//  FZAVCommand.m
//  FZMyLibiary
//
//  Created by 吴福增 on 2019/8/5.
//

#import "FZAVCommand.h"

@implementation FZAVCommand

- (instancetype)initWithComposition:(AVMutableComposition *)composition videoComposition:(AVMutableVideoComposition *)videoComposition audioMix:(AVMutableAudioMix *)audioMix{
    if (self = [super init]) {
        self.mutableComposition = composition;
        self.mutableVideoComposition = videoComposition;
        self.mutableAudioMix = audioMix;
        self.executeStatus = YES;
    }
    return self;
}

- (void)performWithAsset:(AVAsset *)asset completion:(void(^)(FZAVCommand* avCommand))block{
    NSParameterAssert(asset);
    //If the subclass does not implement this method, the program will throw an exception.
    [self doesNotRecognizeSelector:_cmd];
}

@end
