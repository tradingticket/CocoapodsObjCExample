//
//  TTSDKUtils.h
//  TradeItIosTicketSDK
//
//  Created by Daniel Vaughn on 12/4/15.
//  Copyright © 2015 Antonio Reyes. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "TTSDKCompanyDetails.h"
#import <LocalAuthentication/LocalAuthentication.h>

@interface TTSDKUtils : NSObject

@property (nonatomic, retain) UIColor * warningColor;
@property (nonatomic, retain) UIColor * etradeColor;
@property (nonatomic, retain) UIColor * robinhoodColor;
@property (nonatomic, retain) UIColor * schwabColor;
@property (nonatomic, retain) UIColor * scottradeColor;
@property (nonatomic, retain) UIColor * fidelityColor;
@property (nonatomic, retain) UIColor * tdColor;
@property (nonatomic, retain) UIColor * optionshouseColor;
@property (nonatomic, retain) UIColor * lossColor;
@property (nonatomic, retain) UIColor * gainColor;

+ (id)sharedUtils;

-(BOOL) isOnboarding;
-(NSString *) formatIntegerToReadablePrice: (NSString *)price;
-(NSString *) formatPriceString: (NSNumber *)num;
-(NSString *) formatPriceString: (NSNumber *)num withLocaleId: (NSString *) localeId;
-(double) numberFromPriceString: (NSString *)priceString;
-(NSAttributedString *) getColoredString: (NSNumber *) number withFormat: (int) style;
-(NSMutableAttributedString *) logoStringLight;
-(void) styleFocusedInput: (UITextField *)textField withPlaceholder:(NSString *)placeholder;
-(void) styleUnfocusedInput: (UITextField *)textField withPlaceholder: (NSString *)placeholder;
-(void) styleBorderedFocusInput: (UIView *)input;
-(void) styleBorderedUnfocusInput: (UIView *)input;
-(void) styleDropdownButton:(UIButton *)button;
-(void) styleAlertController:(UIView *)alertView;
-(UIView *) retrieveLoadingOverlayForView:(UIView *)view withRadius:(NSInteger)radius;
-(NSString *) splitCamelCase:(NSString *) str;
-(BOOL) containsString: (NSString *) base searchString: (NSString *) searchString;
-(TTSDKCompanyDetails *) companyDetailsWithName: (NSString *)name intoContainer: (UIView *)container inController: (UIViewController *)vc;
- (CAShapeLayer *)retrieveCircleGraphicWithSize:(CGFloat)diameter andColor:(UIColor *)color;
-(UIColor *) retrieveBrokerColorByBrokerName:(NSString *)brokerName;
-(CGFloat) retrieveScreenHeight;
-(BOOL) isSmallScreen;
-(BOOL) isMediumScreen;
-(BOOL) isLargeScreen;
-(BOOL) hasTouchId;
-(NSString *) getBrokerUsername:(NSString *) broker;

@end