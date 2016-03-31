//
//  TankGifView.m
//  GifDemo
//
//  Created by yanwb on 16/3/31.
//  Copyright © 2016年 wbyan. All rights reserved.
//

#import "TankGifView.h"
#import <ImageIO/ImageIO.h>
#import <QuartzCore/QuartzCore.h>

/**
 *  根据URL获取GIF信息
 */
void getFrameInfo(CFURLRef url, NSMutableArray *frames, NSMutableArray *delayTimes, CGFloat *totalTime,CGFloat *gifWidth, CGFloat *gifHeight)
{
    CGImageSourceRef gifSource = CGImageSourceCreateWithURL(url, NULL);
    
    
    
    // get frame count
    size_t frameCount = CGImageSourceGetCount(gifSource);
    if (frameCount > 1) {
        for (size_t i = 0; i < frameCount; ++i) {
            // get each frame
            CGImageRef frame = CGImageSourceCreateImageAtIndex(gifSource, i, NULL);
            [frames addObject:(__bridge id)frame];
            CGImageRelease(frame);
            
            // get gif info with each frame
            NSDictionary *dict = (NSDictionary*)CFBridgingRelease(CGImageSourceCopyPropertiesAtIndex(gifSource, i, NULL));
            NSLog(@"kCGImagePropertyGIFDictionary %@", [dict valueForKey:(NSString*)kCGImagePropertyGIFDictionary]);
            
            // get gif size
            if (gifWidth != NULL && gifHeight != NULL) {
                *gifWidth = [[dict valueForKey:(NSString*)kCGImagePropertyPixelWidth] floatValue];
                *gifHeight = [[dict valueForKey:(NSString*)kCGImagePropertyPixelHeight] floatValue];
            }
            
            // kCGImagePropertyGIFDictionary中kCGImagePropertyGIFDelayTime，kCGImagePropertyGIFUnclampedDelayTime值是一样的
            NSDictionary *gifDict = [dict valueForKey:(NSString*)kCGImagePropertyGIFDictionary];
            [delayTimes addObject:[gifDict valueForKey:(NSString*)kCGImagePropertyGIFDelayTime]];
            
            if (totalTime) {
                *totalTime = *totalTime + [[gifDict valueForKey:(NSString*)kCGImagePropertyGIFDelayTime] floatValue];
            }
        }
    } else {
        NSLog(@"不是GIF");
    }
}


/**
 *  根据路径获取GIF信息
 */
void getFrameInfoWithFilePath(NSString *filePath, NSMutableArray *frames, NSMutableArray *delayTimes, CGFloat *totalTime,CGFloat *gifWidth, CGFloat *gifHeight)
{
    NSData *sourceData = [NSData dataWithContentsOfFile:filePath];
    
    CFDataRef data = (__bridge CFDataRef)(sourceData);
    
    //    CFDataRef data = (__bridge CFDataRef)([NSData dataWithContentsOfFile:filePath]);
    
    NSLog(@"=================%@",data);

    
    CGImageSourceRef gifSource = CGImageSourceCreateWithData(data, NULL);
    
    NSLog(@"+++++++++%@",gifSource);
    
    // get frame count
    size_t frameCount = CGImageSourceGetCount(gifSource);
    
    if (frameCount > 1) {
    
    for (size_t i = 0; i < frameCount; ++i) {
        // get each frame
        CGImageRef frame = CGImageSourceCreateImageAtIndex(gifSource, i, NULL);
        [frames addObject:(__bridge id)frame];
        CGImageRelease(frame);
        
        // get gif info with each frame
        NSDictionary *dict = (NSDictionary*)CFBridgingRelease(CGImageSourceCopyPropertiesAtIndex(gifSource, i, NULL));
        NSLog(@"kCGImagePropertyGIFDictionary %@", [dict valueForKey:(NSString*)kCGImagePropertyGIFDictionary]);
        
        // get gif size
        if (gifWidth != NULL && gifHeight != NULL) {
            *gifWidth = [[dict valueForKey:(NSString*)kCGImagePropertyPixelWidth] floatValue];
            *gifHeight = [[dict valueForKey:(NSString*)kCGImagePropertyPixelHeight] floatValue];
        }
        
        // kCGImagePropertyGIFDictionary中kCGImagePropertyGIFDelayTime，kCGImagePropertyGIFUnclampedDelayTime值是一样的
        NSDictionary *gifDict = [dict valueForKey:(NSString*)kCGImagePropertyGIFDictionary];
        
        [delayTimes addObject:[gifDict valueForKey:(NSString*)kCGImagePropertyGIFDelayTime]];
        
        if (totalTime) {
            *totalTime = *totalTime + [[gifDict valueForKey:(NSString*)kCGImagePropertyGIFDelayTime] floatValue];
        }
    }
    } else {
        NSLog(@"不是GIF");
    }
}


// 验证是否是URL
BOOL validateUrl(NSString *Url)
{
    NSString * const regularExpression = @"\\bhttps?://[a-zA-Z0-9\\-.]+(?::(\\d+))?(?:(?:/[a-zA-Z0-9\\-._?,'+\\&%$=~*!():@\\\\]*)+)?";
    NSError *error = NULL;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:regularExpression
                                                                           options:NSRegularExpressionCaseInsensitive
                                                                             error:&error];
    if (error) {
        NSLog(@"error %@", error);
    }
    
    NSUInteger numberOfMatches = [regex numberOfMatchesInString:Url
                                                        options:0
                                                          range:NSMakeRange(0, [Url length])];
    return numberOfMatches > 0;
}


@interface TankGifView ()

@property (nonatomic, strong) NSMutableArray *frames;

@property (nonatomic, strong) NSMutableArray *frameDelayTimes;

@property (nonatomic, assign) CGFloat  totalTime;

@property (nonatomic, assign) CGFloat width;

@property (nonatomic, assign) CGFloat height;

@end

@implementation TankGifView

- (instancetype)initWithCenter:(CGPoint)center file:(NSString *)file
{
    self = [super initWithFrame:CGRectZero];
    if (self) {
        
        self.frames = [[NSMutableArray alloc] init];
        self.frameDelayTimes = [[NSMutableArray alloc] init];
        
        _width = 0;
        _height = 0;
        
        if (file) {
            //说明是URL
            if ([file hasPrefix:@"http"] || [file hasPrefix:@"https"]) {
                if( validateUrl(file))
                {
                    getFrameInfo((__bridge CFURLRef)[NSURL URLWithString:file], self.frames, self.frameDelayTimes, &_totalTime, &_width, &_height);
                }
            } else {
                getFrameInfoWithFilePath(file, self.frames, self.frameDelayTimes, &_totalTime, &_width, &_height);
            }
            
        }
        
        self.frame = CGRectMake(0, 0, _width, _height);
        self.center = center;
    }
    
    return self;
}
+ (NSArray*)framesInGifURL:(NSURL *)fileURL
{
    NSMutableArray *frames = [NSMutableArray arrayWithCapacity:3];
    NSMutableArray *delays = [NSMutableArray arrayWithCapacity:3];
    
    getFrameInfo((__bridge CFURLRef)fileURL, frames, delays, NULL, NULL, NULL);
    
    return frames;
}

+(NSArray *)framesInGifFilePath:(NSString *)filePath
{
    NSMutableArray *frames = [NSMutableArray arrayWithCapacity:3];
    NSMutableArray *delays = [NSMutableArray arrayWithCapacity:3];
    
    //    getFrameInfo((__bridge CFURLRef)fileURL, frames, delays, NULL, NULL, NULL);
    getFrameInfoWithFilePath(filePath, frames, delays, NULL, NULL, NULL);
    
    return frames;
}



- (void)startGif
{
    CAKeyframeAnimation *animation = [CAKeyframeAnimation animationWithKeyPath:@"contents"];
    
    NSMutableArray *times = [NSMutableArray arrayWithCapacity:3];
    CGFloat currentTime = 0;
    int count = _frameDelayTimes.count;
    for (int i = 0; i < count; ++i) {
        [times addObject:[NSNumber numberWithFloat:(currentTime / _totalTime)]];
        currentTime += [[_frameDelayTimes objectAtIndex:i] floatValue];
    }
    [animation setKeyTimes:times];
    
    NSMutableArray *images = [NSMutableArray arrayWithCapacity:3];
    for (int i = 0; i < count; ++i) {
        [images addObject:[_frames objectAtIndex:i]];
    }
    
    [animation setValues:images];
    [animation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear]];
    animation.duration = _totalTime;
    animation.delegate = self;
    animation.repeatCount = 5;
    
    [self.layer addAnimation:animation forKey:@"gifAnimation"];
}
- (void)stopGif
{
    [self.layer removeAllAnimations];
}
// remove contents when animation end
- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag
{
    self.layer.contents = nil;
}
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
@end
