//
//  TTSDKTableViewController.m
//  TradeItIosTicketSDK
//
//  Created by Daniel Vaughn on 4/8/16.
//  Copyright © 2016 Antonio Reyes. All rights reserved.
//

#import "TTSDKTableViewController.h"
#import "TTSDKWebViewController.h"
#import "TTSDKAlertController.h"

@implementation TTSDKTableViewController

#pragma mark - Rotation

- (BOOL)shouldAutorotate {
    return NO;
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation {
    return UIInterfaceOrientationPortrait;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait;
}


#pragma mark - Initialization

- (void)viewDidLoad {
    [super viewDidLoad];

    [[UIDevice currentDevice] setValue:@1 forKey:@"orientation"];

    self.ticket = [TTSDKTradeItTicket globalTicket];
    self.utils = [TTSDKUtils sharedUtils];
    self.styles = [TradeItStyles sharedStyles];

    [self setViewStyles];
}

- (void)setViewStyles {
    self.view.backgroundColor = self.styles.pageBackgroundColor;

    self.navigationController.navigationBar.barTintColor = self.styles.navigationBarBackgroundColor;
    self.navigationController.navigationBar.tintColor = self.styles.activeColor;

    self.tableView.separatorColor = self.styles.primarySeparatorColor;
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    self.styles = [TradeItStyles sharedStyles];
    
    return self.styles.statusBarStyle;
}


#pragma mark - iOS7 fallbacks

- (void)showOldErrorAlert:(NSString *)title
             withMessage:(NSString *)message {
    UIAlertView * alert;
    alert = [[UIAlertView alloc] initWithTitle:title message:message delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [alert show];
    });
}


#pragma mark - Picker

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    return self.pickerTitles.count;
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    return self.pickerTitles[row];
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    self.currentSelection = self.pickerValues[row];
}

- (void)showPicker:(NSString *)pickerTitle
    withSelection:(NSString *)selection
       andOptions:(NSArray *)options
      onSelection:(void (^)(void))selectionBlock {
    self.currentSelection = selection;
    
    if(![UIAlertController class]) {
        NSMutableArray * titles = [[NSMutableArray alloc] init];
        NSMutableArray * values = [[NSMutableArray alloc] init];
        
        for (NSDictionary *optionContainer in options) {
            NSString * k = [optionContainer.allKeys firstObject];
            NSString * v = optionContainer[k];
            [titles addObject: k];
            [values addObject: v];
        }
        
        self.pickerTitles = [titles copy];
        self.pickerValues = [values copy];
        
        TTSDKCustomIOSAlertView * alert = [[TTSDKCustomIOSAlertView alloc]init];
        [alert setContainerView:[self createPickerView: pickerTitle]];
        [alert setButtonTitles:[NSMutableArray arrayWithObjects:@"CANCEL",@"SELECT",nil]];
        
        [alert setOnButtonTouchUpInside:^(TTSDKCustomIOSAlertView *alertView, int buttonIndex) {
            if(buttonIndex == 1) {
                selectionBlock();
            }
        }];

        dispatch_async(dispatch_get_main_queue(), ^{
            [alert show];
        });
    } else {
        TTSDKAlertController * alert = [TTSDKAlertController alertControllerWithTitle:pickerTitle
                                                                        message:nil
                                                                 preferredStyle:UIAlertControllerStyleActionSheet];
        alert.modalPresentationStyle = UIModalPresentationPopover;

        NSAttributedString * attributedTitle = [[NSAttributedString alloc] initWithString:pickerTitle attributes: @{NSForegroundColorAttributeName: self.styles.alertTextColor}];
        [alert setValue:attributedTitle forKey:@"attributedTitle"];

        for (NSDictionary *optionContainer in options) {
            NSString * k = [optionContainer.allKeys firstObject];
            NSString * v = optionContainer[k];

            UIAlertAction * action = [UIAlertAction actionWithTitle:k style:UIAlertActionStyleDefault handler:^(UIAlertAction * action){
                self.currentSelection = v;
                selectionBlock();
            }];
            
            [alert addAction: action];
        }
        
        UIAlertAction * cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction * action) {
            // do nothing
        }];
        [alert addAction: cancelAction];
        
        [self presentViewController:alert animated:YES completion:nil];

        alert.view.tintColor = self.styles.alertButtonColor;

        UIPopoverPresentationController * alertPresentationController = alert.popoverPresentationController;
        alertPresentationController.sourceView = self.view;
        alertPresentationController.permittedArrowDirections = 0;
        alertPresentationController.sourceRect = CGRectMake(self.view.bounds.size.width / 2.0, self.view.bounds.size.height / 2.0, 1.0, 1.0);
    }
}

- (UIView *)createPickerView:(NSString *)title {
    UIView * contentView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 290, 200)];
    
    UILabel * titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 5, 270, 20)];
    [titleLabel setTextColor:[UIColor blackColor]];
    [titleLabel setTextAlignment:NSTextAlignmentCenter];
    [titleLabel setFont: [UIFont boldSystemFontOfSize:16.0f]];
    [titleLabel setNumberOfLines:0];
    [titleLabel setText: title];
    [contentView addSubview:titleLabel];
    
    UIPickerView * picker = [[UIPickerView alloc] initWithFrame:CGRectMake(10, 20, 270, 130)];
    self.currentPicker = picker;
    
    [picker setDataSource: self];
    [picker setDelegate: self];
    picker.showsSelectionIndicator = YES;
    [contentView addSubview:picker];
    
    [contentView setNeedsDisplay];
    return contentView;
}


#pragma mark - Navigation

- (void)showWebViewWithURL:(NSString *)url andTitle:(NSString *)title {
    // Get storyboard
    UIStoryboard *ticketStoryboard = [[TTSDKTradeItTicket globalTicket] getTicketStoryboard];
    
    TTSDKWebViewController * webViewController = (TTSDKWebViewController *)[ticketStoryboard instantiateViewControllerWithIdentifier: @"WebView"];
    [webViewController setModalPresentationStyle:UIModalPresentationFullScreen];
    
    webViewController.pageTitle = title;
    
    [self presentViewController:webViewController animated:YES completion:^(void) {
        [webViewController.webView loadRequest: [NSURLRequest requestWithURL: [NSURL URLWithString:url]]];
    }];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    self.ticket.lastUsed = [NSDate date];
}

@end
