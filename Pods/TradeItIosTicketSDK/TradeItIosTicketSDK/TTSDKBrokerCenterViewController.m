//
//  TTSDKBrokerCenterViewController.m
//  TradeItIosTicketSDK
//
//  Created by Daniel Vaughn on 5/9/16.
//  Copyright © 2016 Antonio Reyes. All rights reserved.
//

#import "TTSDKBrokerCenterViewController.h"
#import "TTSDKBrokerCenterTableViewCell.h"
#import <TradeItIosEmsApi/TradeItEmsUtils.h>

@interface TTSDKBrokerCenterViewController ()

@property NSLayoutManager * layoutManager;
@property NSArray * brokerCenterData;
@property NSArray * brokerCenterImages;
@property NSArray * disclaimers;
@property NSMutableArray * links;
@property NSIndexPath * disclaimerIndexPath;
@property NSInteger selectedIndex;
@property CGFloat currentDisclaimerHeight;
@property BOOL disclaimerOpen;

@end

@implementation TTSDKBrokerCenterViewController

static CGFloat kDefaultHeight = 158.0f;
static CGFloat kExpandedHeight = 293.0f;


-(void) viewDidLoad {
    [super viewDidLoad];

    self.links = [[NSMutableArray alloc] init];

    self.disclaimerOpen = NO;

    if (self.isModal) {
        UIBarButtonItem * closeButton = [[UIBarButtonItem alloc] initWithTitle:@"Close" style:UIBarButtonItemStylePlain target:self action:@selector(closePressed:)];
        self.navigationItem.rightBarButtonItem = closeButton;
    }

    self.brokerCenterImages = [[NSArray alloc] init];

    [self populateBrokerDataByActiveFilter];

    self.selectedIndex = -1;

    [self setDisclaimerLabelsAndSizes];
}

-(void) populateBrokerDataByActiveFilter {
    NSMutableArray * brokerList = [[NSMutableArray alloc] init];

    for (TradeItBrokerCenterBroker *broker in self.ticket.publisherService.brokerCenterBrokers) {
        if (broker.active) {
            [brokerList addObject: broker];
        }
    }

    self.brokerCenterData = [brokerList copy];
}

-(void) setDisclaimerLabelsAndSizes {
    NSMutableArray * disclaimersArray = [[NSMutableArray alloc] init];

    for (TradeItBrokerCenterBroker * broker in self.brokerCenterData) {
        NSArray * disclaimers = broker.disclaimers;

        float totalLabelsHeight = 0.0f;

        UIView * containerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.tableView.frame.size.width, 100.0f)];
        containerView.backgroundColor = [UIColor clearColor];
        containerView.layoutMargins = UIEdgeInsetsZero;
        containerView.clipsToBounds = NO;

        UILabel * keyLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.tableView.frame.size.width, 12.0f)];
        keyLabel.text = @"";
        [keyLabel sizeToFit];
        [containerView insertSubview:keyLabel atIndex:0];

        NSLayoutConstraint * topKeyConstraint = [NSLayoutConstraint
                                              constraintWithItem:keyLabel
                                              attribute:NSLayoutAttributeTop
                                              relatedBy:NSLayoutRelationEqual
                                              toItem:containerView
                                              attribute:NSLayoutAttributeTopMargin
                                              multiplier:1
                                              constant:0];
        topKeyConstraint.priority = 900;

        NSLayoutConstraint * leftKeyConstraint = [NSLayoutConstraint
                                               constraintWithItem:keyLabel
                                               attribute:NSLayoutAttributeLeading
                                               relatedBy:NSLayoutRelationEqual
                                               toItem:containerView
                                               attribute:NSLayoutAttributeLeadingMargin
                                               multiplier:1
                                               constant:0];
        leftKeyConstraint.priority = 900;

        NSLayoutConstraint * rightKeyConstraint = [NSLayoutConstraint
                                                constraintWithItem:keyLabel
                                                attribute:NSLayoutAttributeTrailing
                                                relatedBy:NSLayoutRelationEqual
                                                toItem:containerView
                                                attribute:NSLayoutAttributeTrailingMargin
                                                multiplier:1
                                                constant:0];
        rightKeyConstraint.priority = 900;

        [containerView addConstraint:topKeyConstraint];
        [containerView addConstraint:leftKeyConstraint];
        [containerView addConstraint:rightKeyConstraint];

        UILabel * lastAttachedLabel = keyLabel;

        for (NSDictionary * disclaimer in disclaimers) {
            BOOL isItalic = [[disclaimer valueForKey:@"italic"] boolValue];
            UIColor * textColor = [TTSDKBrokerCenterTableViewCell colorFromArray: broker.textColor];
            NSString * prefixStr;
            NSString * prefix = [disclaimer valueForKey:@"prefix"];

            if ([prefix isEqualToString:@"asterisk"]) {
                prefixStr = [NSString stringWithFormat:@"%C", 0x0000002A];
            } else if ([prefix isEqualToString:@"dagger"]) {
                prefixStr = [NSString stringWithFormat:@"%C", 0x00002020];
            } else {
                prefixStr = @"";
            }

            UILabel * label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.tableView.frame.size.width, 100.0f)];

            NSString * message = [NSString stringWithFormat:@"%@%@", prefixStr, [disclaimer valueForKey:@"content"]];

            /*
             This is a complicated procedure. If attempting to modify, read the comments carefully.

             We need to modify each disclaimer label to style links and add them to an array. The data uses a double-curly syntax: {{click-my-link}}
             First, we split the string by occurrences of the opening curly braces:
             */
            
            // This will be resulting string, with styled links
            NSMutableAttributedString * attributedStringByComponent = [[NSMutableAttributedString alloc] init];

            // Split by occurrences of opening curly braces
            NSArray * componentByBeginningMatch = [message componentsSeparatedByString:@"{{"];

            // If there are no links, the result will be an array with one item - the original string
            if (componentByBeginningMatch.count > 1) {
                // Go ahead and create the attributes we'll be adding to style the links
                NSDictionary *linkAttributes = @{
                                                 NSFontAttributeName: [UIFont boldSystemFontOfSize:label.font.pointSize],
                                                 NSUnderlineStyleAttributeName : @(NSUnderlineStyleSingle)
                                                 };

                /*
                 We have an array of strings that were split among the instances of "{{", so now we need to cycle through those
                 and split the string at the instances of "}}".
                 */
                NSMutableArray * mutableComponentByEndingMatch = [[NSMutableArray alloc ] init];

                for (NSString *component in componentByBeginningMatch) {
                    NSArray * endComponent = [component componentsSeparatedByString:@"}}"];
                    // Store these arrays in a separate array
                    [mutableComponentByEndingMatch addObject:endComponent];
                }

                // Create a static copy of the result, since we no longer need to mutate it
                NSArray * componentByEndingMatch = [mutableComponentByEndingMatch copy];

                // Each time we encounter a link, we need to add the title and href to an array that we'll store as a property on our view controller
                NSMutableArray * hrefsHolder = [[NSMutableArray alloc] init];
                NSArray * hrefs = (NSArray *)[disclaimer valueForKey:@"hrefs"];
                int hrefCounter = 0;

                for (NSArray * endingComponent in componentByEndingMatch) {
                    /*
                     This is the tricky part. We're looping through a 2D array, and each looped array is a match of "}}". Therefore, it will always behave accordingly:
                     1. The matched array will never contain more than two strings.
                     2. If the matched array only contains one string, then we know it is the beginning of the disclaimer.
                     3. If the matched array contains 2 strings, then we know that the first string is the link text, and the second string is non-link text.
                     */
                    if (endingComponent.count == 2) {
                        // Turn the first string into a link, since we know it is linked text
                        NSAttributedString * attributedEndingComponent = [[NSAttributedString alloc] initWithString:(NSString *)[endingComponent firstObject] attributes:linkAttributes];

                        // Add the href to our list of link urls and titles
                        [hrefsHolder addObject:@{@"href": (NSString *)[hrefs objectAtIndex: hrefCounter], @"title": [attributedEndingComponent string]}];
                        hrefCounter++;

                        // Add the linked string to our final string
                        [attributedStringByComponent appendAttributedString: attributedEndingComponent];

                        // Then convert the second string into an attributed string and append it. It's not a link so we don't need to add style attributes to it
                        NSAttributedString * attributedEndingHangingComponent = [[NSAttributedString alloc] initWithString:(NSString *)[endingComponent lastObject]];
                        [attributedStringByComponent appendAttributedString: attributedEndingHangingComponent];
                    } else {
                        // If the array only has one string, just convert it into an attributed string and append it. It's not a link so we don't need to add style attributes to it
                        [attributedStringByComponent appendAttributedString:[[NSAttributedString alloc] initWithString:(NSString *)[endingComponent firstObject]]];
                    }
                }

                [self.links addObject:@{@"broker": broker.broker, @"hrefs": [hrefsHolder copy]}];

                label.userInteractionEnabled = YES;
                label.attributedText = [attributedStringByComponent copy];

                UITapGestureRecognizer * linkTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(linkPressed:)];
                [label addGestureRecognizer: linkTap];
            } else {
                label.text = message;
            }

            label.lineBreakMode = NSLineBreakByWordWrapping;
            label.autoresizesSubviews = YES;
            label.adjustsFontSizeToFitWidth = NO;
            label.translatesAutoresizingMaskIntoConstraints = NO;
            label.numberOfLines = 0;
            label.textColor = textColor;
            label.backgroundColor = [UIColor clearColor];
            label.clipsToBounds = NO;

            if (isItalic) {
                label.font = [UIFont italicSystemFontOfSize:10.0f];
            } else {
                label.font = [UIFont systemFontOfSize:10.0f];
            }

            [label sizeToFit];

            totalLabelsHeight += (label.frame.size.height + 10.0f);
            containerView.frame = CGRectMake(containerView.frame.origin.x, containerView.frame.origin.y, containerView.frame.size.width, totalLabelsHeight);

            [containerView insertSubview:label belowSubview:lastAttachedLabel];

            NSLayoutConstraint * topConstraint = [NSLayoutConstraint
                                                  constraintWithItem:label
                                                  attribute:NSLayoutAttributeTop
                                                  relatedBy:NSLayoutRelationEqual
                                                  toItem:lastAttachedLabel
                                                  attribute:NSLayoutAttributeBottom
                                                  multiplier:1
                                                  constant:10.0f];
            topConstraint.priority = 900;
            
            NSLayoutConstraint * leftConstraint = [NSLayoutConstraint
                                                   constraintWithItem:label
                                                   attribute:NSLayoutAttributeLeading
                                                   relatedBy:NSLayoutRelationEqual
                                                   toItem:containerView
                                                   attribute:NSLayoutAttributeLeadingMargin
                                                   multiplier:1
                                                   constant:0];
            leftConstraint.priority = 900;
            
            NSLayoutConstraint * rightConstraint = [NSLayoutConstraint
                                                    constraintWithItem:label
                                                    attribute:NSLayoutAttributeTrailing
                                                    relatedBy:NSLayoutRelationEqual
                                                    toItem:containerView
                                                    attribute:NSLayoutAttributeTrailingMargin
                                                    multiplier:1
                                                    constant:-8.0f];
            rightConstraint.priority = 900;

            [containerView addConstraint: topConstraint];
            [containerView addConstraint: leftConstraint];
            [containerView addConstraint: rightConstraint];

            lastAttachedLabel = label;
        }

        [containerView layoutSubviews];

        [disclaimersArray addObject:@{@"view": containerView, @"totalHeight": [NSNumber numberWithFloat: totalLabelsHeight + 30.0f]}];
    }

    self.disclaimers = [disclaimersArray copy];
}

-(NSArray *) rangesOfString:(NSString *)searchString inString:(NSString *)str {
    NSMutableArray *results = [NSMutableArray array];
    NSRange searchRange = NSMakeRange(0, [str length]);
    NSRange range;
    while ((range = [str rangeOfString:searchString options:0 range:searchRange]).location != NSNotFound) {
        [results addObject:[NSValue valueWithRange:range]];
        searchRange = NSMakeRange(NSMaxRange(range), [str length] - NSMaxRange(range));
    }
    return results;
}

-(IBAction) closePressed:(id)sender {
    if (self.ticket.presentationMode == TradeItPresentationModeBrokerCenter) {
        [self.ticket returnToParentApp];
    } else {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

-(IBAction) linkPressed:(id)sender {
    TradeItBrokerCenterBroker * selectedBroker = [self.brokerCenterData objectAtIndex: self.selectedIndex];

    NSArray * selectedLinksList;

    for (NSDictionary * link in self.links) {
        NSString * broker = [link valueForKey:@"broker"];

        if ([selectedBroker.broker isEqualToString:broker]) {
            selectedLinksList = (NSArray *)[link valueForKey:@"hrefs"];
        }
    }

    if (!selectedLinksList || !selectedLinksList.count) {
        return;
    }

    NSDictionary * firstLinkItem = (NSDictionary *)[selectedLinksList firstObject];

    if (selectedLinksList.count == 1) {
        [self showWebViewWithURL: [firstLinkItem valueForKey:@"href"] andTitle:[firstLinkItem valueForKey:@"title"]];
    } else {

        NSMutableArray * optionsArray = [[NSMutableArray alloc] init];
        for (NSDictionary *linkItem in selectedLinksList) {
            [optionsArray addObject:@{[linkItem valueForKey:@"title"]: [linkItem valueForKey:@"href"]}];
        }

        [self showPicker:@"Select a link" withSelection:[firstLinkItem valueForKey:@"href"] andOptions:[optionsArray copy] onSelection:^(void){
            dispatch_async(dispatch_get_main_queue(), ^{

                for (NSDictionary * optionsItem in optionsArray) {
                    for (id key in optionsItem) {
                        NSString * val = (NSString *)[optionsItem valueForKey:key];
                        if ([val isEqualToString:self.currentSelection]) {
                            [self showWebViewWithURL:val andTitle:key];
                            return;
                        }
                    }
                }
            });
        }];
    }
}

-(BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    if(UIWebViewNavigationTypeLinkClicked == navigationType /*you can add some checking whether link should be opened in Safari */) {
        [[UIApplication sharedApplication] openURL:[request URL]];

        return NO;
    }

    return YES;
}

-(void) didToggleExpandedView:(BOOL)toggled atIndexPath:(NSIndexPath *)indexPath {
    // shut disclaimer every time you toggle
    self.disclaimerOpen = NO;

    if (self.selectedIndex == -1) { // user taps row with none currently expanded
        self.selectedIndex = indexPath.row;

        [self.tableView beginUpdates];
        [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationNone];
        [self.tableView endUpdates];
        
    } else if (self.selectedIndex == indexPath.row) { // user taps the currenty expanded row
        self.selectedIndex = -1; // reset index

        [self.tableView beginUpdates];
        [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationNone];
        [self.tableView endUpdates];
        
    } else { // user must have selected a different row
        // get the previous selection path
        NSIndexPath * prevPath = [NSIndexPath indexPathForRow: self.selectedIndex inSection: 0];
        
        // reset the disclaimer
        TTSDKBrokerCenterTableViewCell * cell = [self.tableView cellForRowAtIndexPath:prevPath];
        cell.disclaimerToggled = NO;

        self.selectedIndex = indexPath.row;

        [CATransaction begin];
        [self.tableView beginUpdates];

        [CATransaction setCompletionBlock: ^{
            [self.tableView reloadData];
        }];
        
        [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:prevPath] withRowAnimation:UITableViewRowAnimationNone];
        [self.tableView endUpdates];
        [CATransaction commit];
    }

    [self.tableView layoutIfNeeded];
}

-(void) didSelectLink:(NSString *)link withTitle:(NSString *)title {
    [self showWebViewWithURL:link andTitle:title];
}

-(void) didSelectDisclaimer:(BOOL)selected withHeight:(CGFloat)height atIndexPath:(NSIndexPath *)indexPath {
    self.disclaimerOpen = selected;
    self.currentDisclaimerHeight = height;
    self.disclaimerIndexPath = indexPath;

    [self.tableView reloadData];
}

-(NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.brokerCenterData.count;
}

-(CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.selectedIndex == indexPath.row) {

        if (self.disclaimerOpen && self.disclaimerIndexPath.row == indexPath.row) {
            NSDictionary * disclaimer = [self.disclaimers objectAtIndex:indexPath.row];
            float disclaimerHeight = [[disclaimer valueForKey:@"totalHeight"] floatValue];
            return kExpandedHeight + (disclaimerHeight ? disclaimerHeight : 0.0f);
        } else {
            return kExpandedHeight;
        }
    } else {
        return kDefaultHeight;
    }
}

-(void) promptButtonPressed:(id)sender {
    [self showWebViewWithURL:@"https://www.trade.it/terms" andTitle:@"Terms"];
}

-(UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *cellIdentifier;
    NSString *nibIdentifier;
    NSBundle *resourceBundle = [[TTSDKTradeItTicket globalTicket] getBundle];

    cellIdentifier = @"BrokerCenterIdentifier";
    nibIdentifier = @"TTSDKBrokerCenterCell";
    TTSDKBrokerCenterTableViewCell * cell = [tableView dequeueReusableCellWithIdentifier: cellIdentifier];

    [tableView registerNib:[UINib nibWithNibName: nibIdentifier bundle:resourceBundle] forCellReuseIdentifier:cellIdentifier];
    cell = [tableView dequeueReusableCellWithIdentifier: cellIdentifier];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;

    if (self.disclaimerOpen && self.disclaimerIndexPath.row == indexPath.row) {
        cell.disclaimerToggled = YES;

        NSDictionary * disclaimer = [self.disclaimers objectAtIndex:indexPath.row];

        float totalHeight = [[disclaimer valueForKey:@"totalHeight"] floatValue];
        cell.disclaimerLabelsTotalHeight = totalHeight;

        UIView * disclaimerView = (UIView *)[disclaimer valueForKey:@"view"];

        [cell configureDisclaimers: disclaimerView];
    } else {
        cell.disclaimerToggled = NO;
    }

    TradeItBrokerCenterBroker * brokerCenterItem = [self.brokerCenterData objectAtIndex: indexPath.row];
    [cell configureWithBroker: brokerCenterItem];

    BOOL selected = self.selectedIndex == indexPath.row;

    if (selected) {
        NSDictionary * buttonQueueItem = [self.ticket.publisherService.brokerCenterButtonViews objectAtIndex:indexPath.row];

        if ([[buttonQueueItem valueForKey:@"broker"] isEqualToString:brokerCenterItem.broker]) {
            UIWebView * buttonWebView = (UIWebView *)[buttonQueueItem valueForKey:@"webView"];

            buttonWebView.delegate = self;
            buttonWebView.frame = CGRectMake(0, 0, cell.promptButtonWebViewContainer.frame.size.width, cell.promptButtonWebViewContainer.frame.size.height);

            [cell.promptButtonWebViewContainer addSubview:buttonWebView];
        }
    } else {
        [cell.promptButtonWebViewContainer.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    }

    UIImage * img = [self.ticket.publisherService logoImageByBoker: [brokerCenterItem valueForKey:@"broker"]];
    [cell addImage:img];

    [cell configureSelectedState: selected];

    cell.indexPath = indexPath;
    cell.delegate = self;

    return cell;
}


@end
