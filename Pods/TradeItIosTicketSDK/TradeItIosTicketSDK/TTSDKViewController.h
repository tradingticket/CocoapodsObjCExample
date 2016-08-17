//
//  TTSDKViewController.h
//  TradeItIosTicketSDK
//
//  Created by Daniel Vaughn on 4/6/16.
//  Copyright © 2016 Antonio Reyes. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TTSDKTradeItTicket.h"
#import "TTSDKUtils.h"
#import "TradeItStyles.h"
#import "TTSDKCustomIOSAlertView.h"
#import "TTSDKMBProgressHUD.h"

@interface TTSDKViewController : UIViewController <UIPickerViewDataSource, UIPickerViewDelegate, UIAlertViewDelegate>

@property TTSDKTradeItTicket * ticket;
@property TTSDKUtils * utils;
@property TradeItStyles * styles;
@property NSArray * pickerTitles;
@property NSArray * pickerValues;
@property UIPickerView * currentPicker;
@property NSString * currentSelection;

-(void) setViewStyles;
-(void) showOldErrorAlert: (NSString *) title withMessage:(NSString *) message;
-(void) showErrorAlert:(TradeItErrorResult *)error onAccept:(void (^)(void))acceptanceBlock;
-(void) showErrorAlert:(TradeItErrorResult *)error onAccept:(void (^)(void))acceptanceBlock onCancel:(void (^)(void))cancellationBlock;
-(void) showPicker:(NSString *)pickerTitle withSelection:(NSString *)selection andOptions:(NSArray *)options onSelection:(void (^)(void))selectionBlock;
-(UIView *) createPickerView: (NSString *) title;
-(void) authenticate:(void (^)(TradeItResult * resultToReturn)) completionBlock;
-(void) authenticateSession:(TTSDKTicketSession *) session cancelToParent:(BOOL) cancelToParent broker:(NSString *) broker withCompletionBlock:(void (^)(TradeItResult *))completionBlock;

@end
