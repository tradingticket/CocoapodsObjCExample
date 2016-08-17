//
//  TTSDKStyles.h
//  TradeItIosTicketSDK
//
//  Created by Daniel Vaughn on 4/7/16.
//  Copyright © 2016 Antonio Reyes. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface TradeItStyles : NSObject

#pragma mark State Colors
@property UIColor * activeColor;
@property UIColor * secondaryActiveColor;
@property UIColor * secondaryDarkActiveColor;
@property UIColor * inactiveColor;
@property UIColor * warningColor;
@property UIColor * lossColor;
@property UIColor * gainColor;

#pragma mark Page Colors
@property UIColor * pageBackgroundColor;
@property UIColor * darkPageBackgroundColor;

#pragma mark Navigation Colors
@property UIStatusBarStyle statusBarStyle;
@property UIColor * navigationBarBackgroundColor;
@property UIColor * navigationBarItemColor;
@property UIColor * navigationBarTitleColor;
@property UIColor * tabBarBackgroundColor;
@property UIColor * tabBarItemColor;

#pragma mark Text Colors
@property UIColor * primaryTextColor;
@property UIColor * primaryTextHighlightColor;
@property UIColor * smallTextColor;
@property UIColor * primaryPlaceholderColor;

#pragma mark Loading Colors
@property UIColor * loadingBackgroundColor;
@property UIColor * loadingIconColor;

#pragma mark Peripheral Colors
@property UIColor * switchColor;
@property UIColor * primarySeparatorColor;
@property UIColor * alertBackgroundColor;
@property UIColor * alertTextColor;
@property UIColor * alertButtonColor;

#pragma mark Buttons
@property UIButton * primaryInactiveButton;
@property UIButton * primaryActiveButton;

+(id) sharedStyles;

-(UIColor *) retrieveEtradeColor;
-(UIColor *) retrieveRobinhoodColor;
-(UIColor *) retrieveSchwabColor;
-(UIColor *) retrieveScottradeColor;
-(UIColor *) retrieveFidelityColor;
-(UIColor *) retrieveTdColor;
-(UIColor *) retrieveOptionsHouseColor;

@end
