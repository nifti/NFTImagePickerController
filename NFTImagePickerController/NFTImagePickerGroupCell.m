//
//  NFTImagePickerGroupCell.m
//
//  Created by Ryan Fitzgerald on 6/18/14.
//
//

#import "NFTImagePickerGroupCell.h"

@interface NFTImagePickerGroupCell()

@property (nonatomic, strong) UILabel *nameLabel;
@property (nonatomic, strong) UILabel *countLabel;
@property(nonatomic, strong) UIImageView *thumbnailImageView;

@end

@implementation NFTImagePickerGroupCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.backgroundColor = [UIColor colorWithRed:242/255.0 green:242/255.0 blue:242/255.0 alpha:1];
        
        [self.contentView addSubview:self.thumbnailImageView];
        [self.contentView addSubview:self.nameLabel];
        [self.contentView addSubview:self.countLabel];
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

#pragma mark - Lazy initialization

- (UILabel *)nameLabel {
    if (!_nameLabel) {
        _nameLabel = [UILabel new];
        _nameLabel.backgroundColor = [UIColor clearColor];
        _nameLabel.textColor = [UIColor colorWithRed:137/255.0 green:153/255.0 blue:167/255.0 alpha:1];
        _nameLabel.textAlignment = NSTextAlignmentLeft;
        _nameLabel.font = [_nameLabel.font fontWithSize:14];
    }
    
    return _nameLabel;
}

- (UILabel *)countLabel {
    if (!_countLabel) {
        _countLabel = [UILabel new];
        _countLabel.backgroundColor = [UIColor clearColor];
        _countLabel.textColor = [UIColor colorWithRed:137/255.0 green:153/255.0 blue:167/255.0 alpha:1];
        _countLabel.textAlignment = NSTextAlignmentRight;
        _countLabel.font = [_countLabel.font fontWithSize:12];
    }
    
    return _countLabel;
}

- (UIImageView *)thumbnailImageView {
    if (!_thumbnailImageView) {
        _thumbnailImageView = [UIImageView new];
        _thumbnailImageView.contentMode = UIViewContentModeScaleAspectFill;
        _thumbnailImageView.clipsToBounds = YES;
    }
    return _thumbnailImageView;
}

- (void)updateAssetsGroup:(ALAssetsGroup *)assetsGroup
{
    // Update thumbnail view
//    self.thumbnailView.assetsGroup = self.assetsGroup;
    
    // Update label
    self.nameLabel.text = [assetsGroup valueForProperty:ALAssetsGroupPropertyName];
    self.countLabel.text = [NSString stringWithFormat:@"%ld", (long)assetsGroup.numberOfAssets];
    
    UIImage *thumbnailImage = [UIImage imageWithCGImage:assetsGroup.posterImage];
    self.thumbnailImageView.image = thumbnailImage;
}

#pragma mark - Layout

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGFloat x = 0, y = 0, h = CGRectGetHeight(self.bounds), w = h;
    self.thumbnailImageView.frame = CGRectMake(x, y, w, h);
    
    x = x + w + 10, y = 0, w = CGRectGetWidth(self.bounds) - (2 * x), h = CGRectGetHeight(self.bounds);
    self.nameLabel.frame = CGRectMake(x, y, w, h);
    
    w = 50;
    x = CGRectGetWidth(self.bounds) - (w) - 20;
    self.countLabel.frame = CGRectMake(x, y, w, h);
}

@end
