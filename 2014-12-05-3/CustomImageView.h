//
//  CustomImageView.h
//  2014-12-05-3
//
//  Created by TTC on 12/5/14.
//  Copyright (c) 2014 TTC. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CustomImageView;

@protocol CustomImageViewDelegate <NSObject>

- (void)customImageView:(CustomImageView *)customImgView didClickButton:(UIButton *)button;

@end

@interface CustomImageView : UIImageView

@property (strong, nonatomic) NSString *title;
@property (nonatomic) id<CustomImageViewDelegate> delegate;

@end
