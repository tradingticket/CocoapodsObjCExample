//
//  TTSDKPortfolioHoldingTableViewCell.h
//  TradeItIosTicketSDK
//
//  Created by Daniel Vaughn on 1/6/16.
//  Copyright © 2016 Antonio Reyes. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <TradeItIosEmsApi/TradeItPosition.h>
#import "TTSDKPosition.h"

@protocol TTSDKPositionDelegate;

@protocol TTSDKPositionDelegate <NSObject>

@required

-(void)didSelectBuy:(TTSDKPosition *)position;
-(void)didSelectSell:(TTSDKPosition *)position;

@end

@interface TTSDKPortfolioHoldingTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIView *expandedView;

@property (nonatomic, weak) id<TTSDKPositionDelegate> delegate;

-(void) configureCellWithPosition:(TradeItPosition *)position withLocale:(NSString *) locale;
-(void) hideSeparator;
-(void) showSeparator;

@end
