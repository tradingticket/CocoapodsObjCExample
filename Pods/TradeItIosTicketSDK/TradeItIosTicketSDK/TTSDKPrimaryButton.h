//
//  TTSDKPrimaryButton.h
//  TradeItIosTicketSDK
//
//  Created by Daniel Vaughn on 4/8/16.
//  Copyright © 2016 Antonio Reyes. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TTSDKPrimaryButton : UIButton

-(void) activate;
-(void) deactivate;
-(void) enterLoadingState;
-(void) exitLoadingState;

@end
