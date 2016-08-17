//
//  TTSDKKeypad.m
//  TradeItIosTicketSDK
//
//  Created by Daniel Vaughn on 4/21/16.
//  Copyright © 2016 Antonio Reyes. All rights reserved.
//

#import "TTSDKKeypad.h"
#import "TTSDKImageView.h"
#import "TradeItStyles.h"
#import "TTSDKUtils.h"

@interface TTSDKKeypad()

@property (weak, nonatomic) IBOutlet TTSDKImageView *backspaceImage;
@property (weak, nonatomic) IBOutlet UIButton *decimal;
@property TTSDKUtils * utils;
@property TradeItStyles * styles;

@end

@implementation TTSDKKeypad


-(void) awakeFromNib {
    [super awakeFromNib];

    self.utils = [TTSDKUtils sharedUtils];
    self.styles = [TradeItStyles sharedStyles];

    [self setViewStyles];
}

-(void) setViewStyles {
    self.backgroundColor = [UIColor clearColor];
    self.userInteractionEnabled = YES;

    [[UIButton appearanceWhenContainedIn:TTSDKKeypad.class, nil] setTitleColor:self.styles.activeColor forState:UIControlStateNormal];
    [[UIButton appearanceWhenContainedIn:TTSDKKeypad.class, nil] setBackgroundColor:[UIColor clearColor]];
}

-(void) setContainer:(UIView *)container {
    CGRect frame = CGRectMake(0, 0, container.frame.size.width, container.frame.size.height);
    self.frame = frame;

    [self updateConstraints];
    [self layoutSubviews];
    [self layoutIfNeeded];

    _container = container;
}

-(BOOL) isVisible {
    if (self.container && self.container.layer.opacity < 1) {
        return NO;
    } else {
        return YES;
    }
}

-(void) show {
    if ([self isVisible] || ![self.utils isSmallScreen]) {
        return;
    }

    CATransform3D currentTransform = self.container.layer.transform;
    [UIView animateWithDuration:0.5f delay:0.0 options:UIViewAnimationOptionTransitionNone
                     animations:^{
                         self.container.layer.transform = CATransform3DConcat(currentTransform, CATransform3DMakeTranslation(0.0f, -250.0f, 0.0f));
                         self.container.layer.opacity = 1.0f;
                     }
                     completion:^(BOOL finished) {
                     }
     ];
}

-(void) hide {
    if (![self isVisible] || ![self.utils isSmallScreen]) {
        return;
    }

    CATransform3D currentTransform = self.container.layer.transform;
    [UIView animateWithDuration:0.5f delay:0.0 options:UIViewAnimationOptionTransitionNone
                     animations:^{
                         self.container.layer.transform = CATransform3DConcat(currentTransform, CATransform3DMakeTranslation(0.0f, 250.0f, 0.0f));
                         self.container.layer.opacity = 0;
                     }
                     completion:^(BOOL finished) {
                     }
     ];
}

-(void) showDecimal {
    self.decimal.hidden = NO;
    self.decimal.userInteractionEnabled = YES;
}

-(void) hideDecimal {
    self.decimal.hidden = YES;
    self.decimal.userInteractionEnabled = NO;
}


@end
