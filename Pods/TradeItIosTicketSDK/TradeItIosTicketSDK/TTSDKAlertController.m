//
//  TTSDKAlertController.m
//  TradeItIosTicketSDK
//
//  Created by Daniel Vaughn on 6/6/16.
//  Copyright © 2016 Antonio Reyes. All rights reserved.
//

#import "TTSDKAlertController.h"

@implementation TTSDKAlertController

-(BOOL) shouldAutorotate {
    return NO;
}

-(UIInterfaceOrientation) preferredInterfaceOrientationForPresentation {
    return UIInterfaceOrientationPortrait;
}

-(UIInterfaceOrientationMask) supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait;
}

@end
