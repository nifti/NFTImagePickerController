//
// Created by Ryan Fitzgerald on 7/15/14.
//

#import "NFTNoPhotosFoundCell.h"


@interface NFTNoPhotosFoundCell ()

@property(nonatomic, strong) UILabel *titleLabel;
@property(nonatomic, strong) UILabel *detailsLabel;

@end

@implementation NFTNoPhotosFoundCell

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self.contentView addSubview:self.titleLabel];
        [self.contentView addSubview:self.detailsLabel];
    }

    return self;
}

#pragma mark - Lazy initialization

- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [UILabel new];
        _titleLabel.backgroundColor = [UIColor clearColor];
        _titleLabel.textColor = [UIColor colorWithRed:137 / 255.0 green:153 / 255.0 blue:167 / 255.0 alpha:1];
        _titleLabel.textAlignment = NSTextAlignmentCenter;
        _titleLabel.font = [_titleLabel.font fontWithSize:22];
        _titleLabel.text = @"No Photos";
    }

    return _titleLabel;
}

- (UILabel *)detailsLabel {
    if (!_detailsLabel) {
        _detailsLabel = [UILabel new];
        _detailsLabel.backgroundColor = [UIColor clearColor];
        _detailsLabel.textColor = [UIColor colorWithRed:137 / 255.0 green:153 / 255.0 blue:167 / 255.0 alpha:1];
        _detailsLabel.textAlignment = NSTextAlignmentCenter;
        _detailsLabel.font = [_detailsLabel.font fontWithSize:16];
        _detailsLabel.text = @"You can sync photos\nonto your device using iTunes.";
        _detailsLabel.numberOfLines = 0;
    }

    return _detailsLabel;
}

#pragma mark - Layout

- (void)layoutSubviews {
    [super layoutSubviews];

    CGFloat x = 0, w = CGRectGetWidth(self.bounds), h = 22;
    CGFloat y = (CGRectGetHeight(self.contentView.bounds) / 2) - 70;
    self.titleLabel.frame = CGRectMake(x, y, w, h);

    y += h + 10;
    h = 40;
    self.detailsLabel.frame = CGRectMake(x, y, w, h);
}

@end