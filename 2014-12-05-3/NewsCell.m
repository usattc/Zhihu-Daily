//
//  NewsCell.m
//  2014-12-05-3
//
//  Created by TTC on 12/5/14.
//  Copyright (c) 2014 TTC. All rights reserved.
//

#import "NewsCell.h"

@implementation NewsCell

- (UILabel *)newsLabel {
    if (!_newsLabel) {
        _newsLabel = [[UILabel alloc] initWithFrame:CGRectMake(30, 10, 250, 50)];
        _newsLabel.textColor = [UIColor blackColor];
        _newsLabel.numberOfLines = 2;
        _newsLabel.font = [UIFont systemFontOfSize:14];
        [self.contentView addSubview:_newsLabel];
    }
    return _newsLabel;
}

- (UIImageView *)newsImageView {
    if (!_newsImageView) {
        _newsImageView = [[UIImageView alloc] initWithFrame:CGRectMake(320, 10, 80, 60)];
        _newsImageView.backgroundColor = [UIColor redColor];
        _newsImageView.contentMode = UIViewContentModeScaleAspectFill;
        _newsImageView.clipsToBounds = YES;
        [self.contentView addSubview:_newsImageView];
    }
    return _newsImageView;
}

@end
