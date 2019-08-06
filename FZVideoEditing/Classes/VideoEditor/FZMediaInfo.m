//
//  FZMediaInfo.m
//  FZMyLibiary
//
//  Created by 吴福增 on 2019/8/5.
//

#import "FZMediaInfo.h"

@implementation FZMediaInfo
-(NSString *)description{
    
    NSString* descriptions = [NSString stringWithFormat:@"\n videoWidth = %f \n videoHeight = %f \n videoFrameRate = %f \n videoOutputBitrate = %f \n videoOrientation = %lu \n videoDuration = %lld \n videoByte = %lld \n",self.videoWidth,self.videoHeight,self.videoFrameRate,self.videoOutputBitrate,(unsigned long)self.videoOrientation,self.videoDuration.value/self.videoDuration.timescale,self.videoByte];
    return descriptions;
}

@end
