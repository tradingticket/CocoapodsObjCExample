//
//  TTSDKAccountLinkTableViewCell.h
//  TradeItIosTicketSDK
//
//  Created by Daniel Vaughn on 1/13/16.
//  Copyright © 2016 Antonio Reyes. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TTSDKPortfolioAccount.h"

@protocol TTSDKAccountLinkDelegate;

@protocol TTSDKAccountLinkDelegate <NSObject>

@required
-(void)linkToggleDidSelect:(UISwitch *)toggle forAccount:(TTSDKPortfolioAccount *)account;
-(void)linkToggleDidNotSelect:(NSString *)errorMessage;

@end

@interface TTSDKAccountLinkTableViewCell : UITableViewCell

@property (nonatomic, weak) id<TTSDKAccountLinkDelegate> delegate;
@property (unsafe_unretained, nonatomic) IBOutlet UISwitch * toggle;
@property (unsafe_unretained, nonatomic) IBOutlet UILabel * accountNameLabel;
@property NSString * accountName;

-(void) configureCellWithAccount:(TTSDKPortfolioAccount *)portfolioAccount;
-(void) setBalanceNil;

@end
