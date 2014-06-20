//
// Created by Ryan Fitzgerald on 6/19/14.
//

#import "NFTPhotoAssetCell.h"
#import "NFTPhotoAssetCheckmarkView.h"


@interface NFTPhotoAssetCell ()

@property(nonatomic, strong) UIImageView *thumbnailImageView;
@property(nonatomic, strong) NFTPhotoAssetCheckmarkView *checkmarkView;

@end

@implementation NFTPhotoAssetCell

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
//        self.backgroundColor = [UIColor colorWithRed:242 / 255.0 green:242 / 255.0 blue:242 / 255.0 alpha:1];
        [self.contentView addSubview:self.thumbnailImageView];
    }
    return self;
}

#pragma mark - Lazy initialization

- (UIImageView *)thumbnailImageView {
    if (!_thumbnailImageView) {
        _thumbnailImageView = [UIImageView new];
        _thumbnailImageView.contentMode = UIViewContentModeScaleAspectFill;
        _thumbnailImageView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        _thumbnailImageView.clipsToBounds = YES;
    }
    return _thumbnailImageView;
}

- (NFTPhotoAssetCheckmarkView *)checkmarkView {
    if (!_checkmarkView) {
        _checkmarkView = [NFTPhotoAssetCheckmarkView new];
        _checkmarkView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    }

    return _checkmarkView;
}

- (void)setSelected:(BOOL)selected {
    [super setSelected:selected];

    // Show/hide overlay view
    if (selected) {
//        [self hideCheckmarkView];
        [self showCheckmarkView];
    } else {
        [self hideCheckmarkView];
    }
}

- (void)showCheckmarkView {
    if (![self isDescendantOfView:self.checkmarkView]) {
        CGFloat w = 24, h = w;
        CGFloat x = CGRectGetWidth(self.bounds) - w - 2;
        CGFloat y = CGRectGetHeight(self.bounds) - h - 2;
        self.checkmarkView.frame = CGRectMake(x, y, w, h);
        [self.contentView addSubview:self.checkmarkView];
    }
}

- (void)hideCheckmarkView {
    [self.checkmarkView removeFromSuperview];
}

#pragma mark - Layout

- (void)layoutSubviews {
    [super layoutSubviews];

    self.thumbnailImageView.frame = self.bounds;
}

- (void)updateWithAsset:(ALAsset *)asset {
    self.thumbnailImageView.image = [UIImage imageWithCGImage:[asset thumbnail]];
}

@end