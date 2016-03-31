//
//  TankGifView.h
//  GifDemo
//
//  Created by yanwb on 16/3/31.
//  Copyright © 2016年 wbyan. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TankGifView : UIView

/**
 *  初始化GifView
 *
 *  @param center 位置
 *  @param file   GIF路径或者URL
 */
-(instancetype)initWithCenter:(CGPoint)center file:(NSString *)file;


-(void)startGif;


-(void)stopGif;


+(NSArray *)framesInGifURL:(NSURL *)fileURL;


+(NSArray *)framesInGifFilePath:(NSString *)filePath;
@end
