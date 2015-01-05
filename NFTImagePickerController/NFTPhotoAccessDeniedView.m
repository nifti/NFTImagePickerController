//
// Created by Ryan Fitzgerald on 6/20/14.
//

#import "NFTPhotoAccessDeniedView.h"


@interface NFTPhotoAccessDeniedView ()
@property(nonatomic, strong) UILabel *titleView;
@property(nonatomic, strong) UILabel *detailsView;
@property(nonatomic, strong) UILabel *stepsView;
@end

@implementation NFTPhotoAccessDeniedView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];

    if (self) {
        [self addSubview:self.titleView];
        [self addSubview:self.detailsView];
        [self addSubview:self.stepsView];

        self.backgroundColor = [UIColor colorWithRed:242 / 255.0f green:242 / 255.0f blue:242 / 255.0f alpha:1];
    }

    return self;
}

#pragma mark - Lazy init

- (UILabel *)titleView {
    if (!_titleView) {
        _titleView = [[UILabel alloc] initWithFrame:CGRectZero];
        _titleView.text = @"Please Allow Access to\nYour Photos";
        _titleView.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:20.0f];
        _titleView.textAlignment = NSTextAlignmentCenter;
        _titleView.numberOfLines = 0;
        _titleView.textColor = [[UIColor blackColor] colorWithAlphaComponent:0.8];
    }

    return _titleView;
}

- (UILabel *)detailsView {
    if (!_detailsView) {
        _detailsView = [[UILabel alloc] initWithFrame:CGRectZero];
        _detailsView.text = @"This will allow you to share photos\nfrom your library and save photos to\n your camera roll.";
        _detailsView.font = [UIFont fontWithName:@"HelveticaNeue" size:16.0f];
        _detailsView.textAlignment = NSTextAlignmentCenter;
        _detailsView.textColor = [[UIColor blackColor] colorWithAlphaComponent:0.6];
        _detailsView.numberOfLines = 0;
    }

    return _detailsView;
}

- (UILabel *)stepsView {
    if (!_stepsView) {
        _stepsView = [[UILabel alloc] initWithFrame:CGRectZero];
        _stepsView.font = [UIFont fontWithName:@"HelveticaNeue" size:16.0f];
        _stepsView.textAlignment = NSTextAlignmentLeft;
        _stepsView.numberOfLines = 0;
        _stepsView.textColor = [[UIColor blackColor] colorWithAlphaComponent:0.8];

        NSString *appName = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleDisplayName"];
        _stepsView.text = [NSString stringWithFormat:@"1. Open Settings\n2. Tap Privacy > Photos\n3. Set \"%@\" to ON", appName];
    }

    return _stepsView;
}

- (void)layoutSubviews {
    [super layoutSubviews];

    CGFloat x = 0, y = 100, w = CGRectGetWidth(self.bounds), h = 50;
    self.titleView.frame = CGRectMake(x, y, w, h);

    y = y + h + 10;
    h = 60;
    self.detailsView.frame = CGRectMake(x, y, w, h);

    y = y + h + 20;
    h = 80;
    x = 20;
    self.stepsView.frame = CGRectMake(x, y, w, h);
}

@end