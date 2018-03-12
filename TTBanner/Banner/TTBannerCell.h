//
//  TTBannerCell.h
//  TTBanner
//
//  Created by wangd on 2018/3/11.
//  Copyright © 2018年 wangd. All rights reserved.
//

/** 自定义Banner Cell，方便以后扩展，比如添加底部标题等 */

#import <UIKit/UIKit.h>

@interface TTBannerCell : UICollectionViewCell

@property (nonatomic, strong) UIView *itemView;

@end
