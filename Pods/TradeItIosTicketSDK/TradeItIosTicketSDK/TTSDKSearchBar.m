//
//  TTSDKSearchBar.m
//  TradeItIosTicketSDK
//
//  Created by Daniel Vaughn on 4/17/16.
//  Copyright © 2016 Antonio Reyes. All rights reserved.
//

#import "TTSDKSearchBar.h"
#import "TradeItStyles.h"

@implementation TTSDKSearchBar


-(void) awakeFromNib {
    [self setViewStyles];
}

-(void) setViewStyles {
    TradeItStyles * styles = [TradeItStyles sharedStyles];

    [[UIBarButtonItem appearanceWhenContainedIn:TTSDKSearchBar.class, nil] setTintColor:styles.activeColor];

    self.backgroundImage = [[UIImage alloc] init];

    [self setImage:[[UIImage alloc] init] forSearchBarIcon:UISearchBarIconSearch state:UIControlStateNormal];

    UITextField *searchTextField = [self valueForKey:@"_searchField"];
    if ([searchTextField respondsToSelector:@selector(setAttributedPlaceholder:)]) {
        UIColor *color = styles.primaryPlaceholderColor;
        [searchTextField setAttributedPlaceholder:[[NSAttributedString alloc] initWithString:@"Enter a symbol" attributes:@{NSForegroundColorAttributeName: color}]];
    }

    self.backgroundImage = [[UIImage alloc] init];
    [[UITextField appearanceWhenContainedIn:TTSDKSearchBar.class, nil] setBackgroundColor:[UIColor clearColor]];
    [[UITextField appearanceWhenContainedIn:TTSDKSearchBar.class, nil] setTextColor: styles.primaryTextColor];
}


@end
