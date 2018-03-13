//
//  TTBanner.h
//  TTBanner
//
//  Created by wangd on 2018/3/11.
//  Copyright © 2018年 wangd. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol TTBannerDataSource;
@protocol TTBannerDelegate;

@interface TTBanner : UIView

/** 是否自动滚动，默认YES */
@property (nonatomic, assign) BOOL autoScroll;
/** 自动滚动时间间隔,默认3秒 */
@property (nonatomic, assign) NSInteger scrollInterval;
/** 是否循环滚动 */
@property (nonatomic, assign) BOOL shouldLoop;

@property (nonatomic, weak) id<TTBannerDataSource> dataSource;
@property (nonatomic, weak) id<TTBannerDelegate> delegate;

- (void)reloadData;

/**
 继续自动滚动，只有 autoScroll 为真的时候，才起作用。
 */
- (void)resumeAutoScroll;

/**
 暂停自动滚动，只有 autoScroll 为真的时候，才起作用。
 */
- (void)suspendAutoScroll;

@end

@protocol TTBannerDataSource <NSObject>

@required
- (NSInteger)numberOfItemsInBanner:(TTBanner *)banner;

- (UIView *)banner:(TTBanner *)banner viewForItemAtIndex:(NSInteger)index;

@end

@protocol TTBannerDelegate <NSObject>

@optional
- (void)banner:(TTBanner *)banner didSelectAtIndex:(NSInteger)index;

@end
