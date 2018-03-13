//
//  TTBanner.m
//  TTBanner
//
//  Created by wangd on 2018/3/11.
//  Copyright © 2018年 wangd. All rights reserved.
//

#import "TTBanner.h"
#import "TTBannerCell.h"
#import "TTTimer.h"

static NSString * const kBannerCell = @"BannerCell";

@interface TTBanner ()
<UICollectionViewDataSource,
UICollectionViewDelegate>

{
    __block NSInteger _currentIndex;
}

@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) TTTimer *timer;
@property (nonatomic, assign) NSInteger itemCount;

@end

@implementation TTBanner

@synthesize autoScroll = _autoScroll;
@synthesize scrollInterval = _scrollInterval;
@synthesize shouldLoop = _shouldLoop;

- (void)dealloc {
    
    [self destoryTimer];
}

- (instancetype)initWithFrame:(CGRect)frame {
    
    if (self = [super initWithFrame:frame]) {
        _currentIndex = 0;
        _itemCount = 0;
        _scrollInterval = 3;
        _autoScroll = YES;
        _shouldLoop = YES;
        
        [self addSubview:self.collectionView];
        
        [self timerTick];
    }
    
    return self;
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    
    if (self.dataSource && [self.dataSource respondsToSelector:@selector(numberOfItemsInBanner:)]) {
        self.itemCount = [self.dataSource numberOfItemsInBanner:self];
        return self.itemCount;
    }
    
    return 0;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    TTBannerCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kBannerCell
                                                                   forIndexPath:indexPath];
    if (self.dataSource && [self.dataSource respondsToSelector:@selector(banner:viewForItemAtIndex:)]) {
        cell.itemView = [self.dataSource banner:self viewForItemAtIndex:indexPath.item];
    }
    
    return cell;
}

#pragma mark - UICollectionViewDelegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(banner:didSelectAtIndex:)]) {
        [self.delegate banner:self didSelectAtIndex:indexPath.item];
    }
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    
    [self suspendAutoScroll];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    
    [self resumeAutoScroll];
}

#pragma mark - Public Methods

- (void)resumeAutoScroll {
    
    if (self.autoScroll) {
        [self.timer resume];
    }
}

- (void)suspendAutoScroll {
    
    if (self.autoScroll) {
        [self.timer suspend];
    }
}

#pragma mark - Private Method

- (void)timerTick {
    
    [self destoryTimer];
    
    if (!self.autoScroll) {
        return;
    }
    
    [self.timer tickProgress:^{
        _currentIndex = _currentIndex + 1;
        if (_currentIndex >= self.itemCount) {
            _currentIndex = 0;
        }
        
        BOOL animated = YES;
        if (_currentIndex == 0) {
            animated = NO;
        }
        
        [self.collectionView
         scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:_currentIndex inSection:0]
         atScrollPosition:UICollectionViewScrollPositionRight
         animated:animated];
    }];
}

- (void)destoryTimer {
    
    [self.timer destroy];
    self.timer = nil;
}

#pragma mark - Setter

- (void)setAutoScroll:(BOOL)autoScroll {
    
    _autoScroll = autoScroll;
    [self timerTick];
}

- (void)setScrollInterval:(NSInteger)scrollInterval {
    
    _scrollInterval = scrollInterval;
    
    self.timer.tickInterval = self.scrollInterval;
    [self timerTick];
}

- (void)setShouldLoop:(BOOL)shouldLoop {
    
    _shouldLoop = shouldLoop;
}

#pragma mark - Getter

- (UICollectionView *)collectionView {
    
    if (!_collectionView) {
        UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
        flowLayout.minimumInteritemSpacing = 0;
        flowLayout.minimumLineSpacing = 0;
        flowLayout.itemSize = self.bounds.size;
        flowLayout.sectionInset = UIEdgeInsetsZero;
        flowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        
        _collectionView = [[UICollectionView alloc] initWithFrame:self.bounds
                                             collectionViewLayout:flowLayout];
        _collectionView.backgroundColor = [UIColor whiteColor];
        _collectionView.showsHorizontalScrollIndicator = NO;
        _collectionView.pagingEnabled = YES;
        _collectionView.alwaysBounceHorizontal = YES;
        _collectionView.scrollsToTop = NO;
        _collectionView.dataSource = self;
        _collectionView.delegate = self;
        
        [_collectionView registerClass:[TTBannerCell class] forCellWithReuseIdentifier:kBannerCell];
    }
    
    return _collectionView;
}

- (TTTimer *)timer {
    
    if (!_timer) {
        _timer = [[TTTimer alloc] init];
        _timer.tickInterval = self.scrollInterval;
    }
    
    return _timer;
}

@end
