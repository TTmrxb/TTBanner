//
//  TTPageControl.h
//  TTBanner
//
//  Created by jyzx101 on 2018/3/14.
//  Copyright © 2018年 wangd. All rights reserved.
//
/** 自定义PageControl，方便改变状态，如大小、形状等 */

#import <UIKit/UIKit.h>

@interface TTPageControl : UIControl

@property (nonatomic, assign) NSInteger numberOfPage;
@property (nonatomic, assign) NSInteger currentPage;
@property (nonatomic, strong) UIColor *pageTintColor;
@property (nonatomic, strong) UIColor *currentPageTintColor;

@end
