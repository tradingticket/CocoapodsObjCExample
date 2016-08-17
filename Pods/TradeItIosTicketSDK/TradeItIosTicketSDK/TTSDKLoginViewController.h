//
//  TTSDKLoginViewController.h
//  TradeItIosTicketSDK
//
//  Created by Antonio Reyes on 7/21/15.
//  Copyright (c) 2015 Antonio Reyes. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <TradeItIosEmsApi/TradeItAuthenticationInfo.h>
#import <TradeItIosEmsApi/TradeItErrorResult.h>
#import <TradeItIosEmsApi/TradeItAuthLinkResult.h>
#import <TradeItIosEmsApi/TradeItAuthenticationResult.h>
#import <TradeItIosEmsApi/TradeItSecurityQuestionResult.h>
#import "TTSDKViewController.h"

@interface TTSDKLoginViewController : TTSDKViewController <UITextFieldDelegate, UIAlertViewDelegate>

@property TradeItAuthenticationInfo * verifyCreds;
@property BOOL isModal;
@property BOOL cancelToParent;
@property BOOL reAuthenticate;
@property NSString * addBroker;
@property NSArray * questionOptions;

@property (nonatomic,strong) void (^onCompletion)(TradeItResult *);

@end
