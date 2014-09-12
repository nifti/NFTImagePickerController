//
//  NFTPhotoAccessNotDeterminedView.m
//  NFTImagePickerController
//
//  Created by Mikhail Vetoshkin on 12/09/14.
//
//

#import "NFTPhotoAccessNotDeterminedView.h"


@interface NFTPhotoAccessNotDeterminedView ()

@property (nonatomic, strong) UILabel *titleView;
@property (nonatomic, strong) UIImageView *imageView;

@end

@implementation NFTPhotoAccessNotDeterminedView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];

    if (self) {
        [self addSubview:self.titleView];
        [self addSubview:self.imageView];

        self.backgroundColor = [UIColor colorWithRed:242 / 255.0f green:242 / 255.0f blue:242 / 255.0f alpha:1];
    }

    return self;
}

#pragma mark - Lazy init

- (UILabel *)titleView {
    if (!_titleView) {
        _titleView = [[UILabel alloc] initWithFrame:CGRectZero];
        _titleView.text = @"Allow access to your Photos\nto select images from your phone";
        _titleView.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:16.0f];
        _titleView.textAlignment = NSTextAlignmentCenter;
        _titleView.numberOfLines = 0;
        _titleView.textColor = [[UIColor blackColor] colorWithAlphaComponent:0.8];
    }

    return _titleView;
}

- (UIImageView *)imageView {
    if (!_imageView) {
        _imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"photo-icon"]];
        _imageView.clipsToBounds = YES;
        _imageView.contentMode = UIViewContentModeScaleAspectFill;
    }

    return _imageView;
}

#pragma mark - Layout

- (void)layoutSubviews {
    [super layoutSubviews];

    CGFloat windowWidth = CGRectGetWidth(self.bounds);
    CGFloat w = windowWidth - 40, h = 80;
    CGFloat x = windowWidth / 2 - w / 2, y = 64;

    self.titleView.frame = CGRectMake(x, y, w, h);

    y += h;
    h = 35;
    w = 35;
    x = windowWidth / 2 - w / 2;

    self.imageView.frame = CGRectMake(x, y, w, h);
}

@end
