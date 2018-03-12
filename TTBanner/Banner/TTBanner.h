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

@property (nonatomic, assign) BOOL autoScroll;

@property (nonatomic, weak) id<TTBannerDataSource> dataSource;
@property (nonatomic, weak) id<TTBannerDelegate> delegate;

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
