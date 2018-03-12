//
//  TTTimer.h
//  TTBanner
//
//  Created by wangd on 2018/3/11.
//  Copyright © 2018年 wangd. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TTTimer : NSObject

/** 钟摆间隔 */
@property (nonatomic, assign) NSInteger tickInterval;

- (void)tickProgress:(void(^)(void))progress;

- (void)suspend;

- (void)resume;

- (void)destroy;

@end
