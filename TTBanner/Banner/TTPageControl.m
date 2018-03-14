//
//  TTPageControl.m
//  TTBanner
//
//  Created by jyzx101 on 2018/3/14.
//  Copyright © 2018年 wangd. All rights reserved.
//

#import "TTPageControl.h"

//本文件所有page代表指示的小圆点
static CGFloat const kPageWidth = 10.0;
static CGFloat const kPageHeight = 10.0;
static CGFloat const kPageMargin = 5.0;
static CGFloat const kCurrentPageW = 25.0;

@interface TTPageControl ()

@property (nonatomic, strong) UIView *container;        //加载所有指示圆点的容器
@property (nonatomic, strong) NSMutableArray *pageArr;  //存放所有指示圆点

@end

@implementation TTPageControl

@synthesize numberOfPage = _numberOfPage;
@synthesize currentPage = _currentPage;

- (instancetype)initWithFrame:(CGRect)frame {
    
    if (self = [super initWithFrame:frame]) {
        _numberOfPage = 0;
        _currentPage = 0;
        _pageTintColor = [UIColor lightGrayColor];
        _currentPageTintColor = [UIColor whiteColor];
        
        [self addSubview:self.container];
    }
    
    return self;
}

#pragma mark - Setter

- (void)setNumberOfPage:(NSInteger)numberOfPage {
    
    _numberOfPage = numberOfPage;
    
    [self.container.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    [self.pageArr removeAllObjects];
    
    CGFloat containerW = kCurrentPageW + (self.numberOfPage - 1) * (kPageWidth + kPageMargin);
    CGFloat containerH = kPageHeight;
    CGFloat containerX = 0.5 * (self.bounds.size.width - containerW);
    CGFloat containerY = 0.5 * (self.bounds.size.height - containerH);
    self.container.frame = CGRectMake(containerX, containerY, containerW, containerH);
    
    CGFloat pageX = 0.0;
    
    for (NSInteger i = 0; i < self.numberOfPage; i++) {
        if (i == self.currentPage) {
            UIView *pageView = [[UIView alloc] initWithFrame:CGRectMake(pageX,
                                                                        0,
                                                                        kCurrentPageW,
                                                                        kPageHeight)];
            pageView.backgroundColor = self.currentPageTintColor;
            pageView.layer.cornerRadius = 0.5 * kPageWidth;
            pageView.clipsToBounds = YES;
            
            pageX = pageX + kCurrentPageW + kPageMargin;
            
            [self.container addSubview:pageView];
            [self.pageArr addObject:pageView];
        }else {
            
            UIView *pageView = [[UIView alloc] initWithFrame:CGRectMake(pageX,
                                                                        0,
                                                                        kPageWidth,
                                                                        kPageHeight)];
            pageView.backgroundColor = self.pageTintColor;
            pageView.layer.cornerRadius = 0.5 * kPageWidth;
            pageView.clipsToBounds = YES;
            
            pageX = pageX + kPageWidth + kPageMargin;
            
            [self.container addSubview:pageView];
            [self.pageArr addObject:pageView];
        }
    }
}

- (void)setCurrentPage:(NSInteger)currentPage {
    
    if (_currentPage == currentPage) return;
    
    _currentPage = MIN(currentPage, self.numberOfPage - 1);
    
    CGFloat pageX = 0.0;
    for (NSInteger i = 0; i < self.numberOfPage; i++) {
        UIView *pageView = (UIView *)self.pageArr[i];
        
        if (i == self.currentPage) {
            pageView.frame = CGRectMake(pageX, 0, kCurrentPageW, kPageHeight);
            pageView.backgroundColor = self.currentPageTintColor;
            pageX = pageX + kCurrentPageW + kPageMargin;
        }else {
            pageView.frame = CGRectMake(pageX, 0, kPageWidth, kPageHeight);
            pageView.backgroundColor = self.pageTintColor;
            pageX = pageX + kPageWidth + kPageMargin;
        }
    }
}

#pragma mark - Getter

- (UIView *)container {
    
    if (!_container) {
        _container = [[UIView alloc] init];
        _container.backgroundColor = [UIColor clearColor];
    }
    return _container;
}

- (NSMutableArray *)pageArr {
    
    if (!_pageArr) {
        _pageArr = [NSMutableArray array];
    }
    return _pageArr;
}

@end
