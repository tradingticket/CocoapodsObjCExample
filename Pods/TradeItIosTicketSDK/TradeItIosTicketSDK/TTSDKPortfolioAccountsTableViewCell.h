//
//  TTSDKPortfolioAccountsTableViewCell.h
//  TradeItIosTicketSDK
//
//  Created by Daniel Vaughn on 1/7/16.
//  Copyright © 2016 Antonio Reyes. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TTSDKPortfolioAccount.h"

@protocol TTSDKAccountDelegate;

@protocol TTSDKAccountDelegate <NSObject>

@required
-(void)didSelectAuth:(TTSDKPortfolioAccount *)account;

@end

@interface TTSDKPortfolioAccountsTableViewCell : UITableViewCell

@property (nonatomic, weak) id<TTSDKAccountDelegate> delegate;

@property (weak, nonatomic) IBOutlet UIView *authenticateView;
@property (weak, nonatomic) IBOutlet UIView *selectedView;

-(void) configureCellWithAccount:(TTSDKPortfolioAccount *)account;
-(void) configureSelectedState:(BOOL)selected;
-(void) hideSeparator;
-(void) showSeparator;

@end
