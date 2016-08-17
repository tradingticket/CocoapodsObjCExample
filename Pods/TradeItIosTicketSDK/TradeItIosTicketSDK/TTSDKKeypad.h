//
//  TTSDKKeypad.h
//  TradeItIosTicketSDK
//
//  Created by Daniel Vaughn on 4/21/16.
//  Copyright © 2016 Antonio Reyes. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TTSDKKeypad : UIView

@property (nonatomic) UIView * container;

-(void) setContainer:(UIView *)container;
-(void) show;
-(void) hide;
-(void) showDecimal;
-(void) hideDecimal;

@end
