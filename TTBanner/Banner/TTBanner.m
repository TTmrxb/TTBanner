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
UICollectionViewDelegate,
UICollectionViewDelegateFlowLayout>

{
    NSInteger _currentIndex;
}

@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) TTTimer *timer;

@end

@implementation TTBanner

- (void)dealloc {
    
    [self.timer destroy];
}

- (instancetype)initWithFrame:(CGRect)frame {
    
    if (self = [super initWithFrame:frame]) {
        _currentIndex = 0;
        
        [self addSubview:self.collectionView];
    }
    
    return self;
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    
    if (self.dataSource && [self.dataSource respondsToSelector:@selector(numberOfItemsInBanner:)]) {
        return [self.dataSource numberOfItemsInBanner:self];
    }
    
    return 0;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    TTBannerCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kBannerCell
                                                                   forIndexPath:indexPath];
    if (self.dataSource && [self.dataSource respondsToSelector:@selector(banner:viewForItemAtIndex:)]) {
        cell.itemView = [self.dataSource banner:self viewForItemAtIndex:indexPath.row];
    }
    
    return cell;
}

#pragma mark - UICollectionViewDelegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(banner:didSelectAtIndex:)]) {
        [self.delegate banner:self didSelectAtIndex:indexPath.row];
    }
}

#pragma mark - Private Method

- (void)timeTick {

    self.timer = [[TTTimer alloc] init];
    [self.timer tickProgress:^{
       
        
    }];
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

@end
