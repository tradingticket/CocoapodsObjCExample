//
//  TTSDKAccountSelectTableViewCell.h
//  TradeItIosTicketSDK
//
//  Created by Daniel Vaughn on 12/16/15.
//  Copyright © 2015 Antonio Reyes. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TTSDKPortfolioAccount.h"

@interface TTSDKAccountSelectTableViewCell : UITableViewCell

-(void) configureCellWithAccount:(TTSDKPortfolioAccount *)account loaded:(BOOL)loaded;
-(void) configureSelectedState:(BOOL)selected;

@end
