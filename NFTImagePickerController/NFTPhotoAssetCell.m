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
        [self.contentView addSubview:self.thumbnailImageView];
        [self.contentView addSubview:self.checkmarkView];
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
        _checkmarkView.hidden = YES;
    }

    return _checkmarkView;
}

- (void)setSelected:(BOOL)selected {
    [super setSelected:selected];

    // Show/hide overlay view
    if (selected) {
        [self showCheckmarkView];
        self.layer.borderWidth = 2.0;
        self.layer.borderColor = [UIColor colorWithRed:57 / 255.0f green:187 / 255.0f blue:181 / 255.0f alpha:1].CGColor;
    } else {
        [self hideCheckmarkView];
        self.layer.borderWidth = 0;
        self.layer.borderColor = [UIColor clearColor].CGColor;
    }
}

- (void)showCheckmarkView {
    self.checkmarkView.hidden = NO;
}

- (void)hideCheckmarkView {
    self.checkmarkView.hidden = YES;
}

#pragma mark - Layout

- (void)layoutSubviews {
    [super layoutSubviews];

    self.thumbnailImageView.frame = self.bounds;

    CGFloat w = 24, h = w;
    CGFloat x = CGRectGetWidth(self.bounds) - w - 3;
    CGFloat y = CGRectGetHeight(self.bounds) - h - 3;

    self.checkmarkView.frame = CGRectMake(x, y, w, h);
}

- (void)updateWithAsset:(ALAsset *)asset {
    self.thumbnailImageView.image = [UIImage imageWithCGImage:[asset thumbnail]];
}

@end