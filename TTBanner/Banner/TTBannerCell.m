//
//  TTBannerCell.m
//  TTBanner
//
//  Created by wangd on 2018/3/11.
//  Copyright © 2018年 wangd. All rights reserved.
//

#import "TTBannerCell.h"

@implementation TTBannerCell

@synthesize itemView = _itemView;

#pragma mark - Setter

- (void)setItemView:(UIView *)itemView {
    if (_itemView) {
        [_itemView removeFromSuperview];
        _itemView = nil;
    }
    
    _itemView = itemView;
    _itemView.frame = self.bounds;
    [self addSubview:_itemView];
}

@end
