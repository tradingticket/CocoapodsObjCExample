//
//  TTSKAccountsHeaderView.h
//  TradeItIosTicketSDK
//
//  Created by Daniel Vaughn on 2/21/16.
//  Copyright © 2016 Antonio Reyes. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TTSDKAccountsHeaderView : UIView

@property (weak, nonatomic) IBOutlet UIButton *editAccountsButton;

-(void) populateTotalPortfolioValue:(NSString *)value;

@end
