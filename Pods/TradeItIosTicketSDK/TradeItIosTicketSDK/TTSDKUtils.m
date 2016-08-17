//
//  TTSDKUtils.m
//  TradeItIosTicketSDK
//
//  Created by Daniel Vaughn on 12/4/15.
//  Copyright © 2015 Antonio Reyes. All rights reserved.
//


#import "TTSDKUtils.h"
#import "TradeItStyles.h"
#import "TTSDKPortfolioService.h"

@interface TTSDKUtils () {
    UIButton * currentGradientContainer;
    CAGradientLayer * activeButtonGradient;
    UIActivityIndicatorView * currentIndicator;
    UIImageView * loadingIcon;
    BOOL animating;
    TradeItStyles * styles;
}

@end

@implementation TTSDKUtils

@synthesize warningColor;
@synthesize etradeColor;
@synthesize robinhoodColor;
@synthesize schwabColor;
@synthesize scottradeColor;
@synthesize fidelityColor;
@synthesize tdColor;
@synthesize optionshouseColor;
@synthesize lossColor;
@synthesize gainColor;

static NSString * kAccountsKey = @"TRADEIT_ACCOUNTS";

+ (id)sharedUtils {
    static TTSDKUtils *sharedUtilsInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedUtilsInstance = [[self alloc] init];
    });

    return sharedUtilsInstance;
}

- (id)init {
    if (self = [super init]) {
        warningColor = [UIColor colorWithRed:236.0f/255.0f green:121.0f/255.0f blue:31.0f/255.0f alpha:1.0f];
        etradeColor = [UIColor colorWithRed:98.0f / 255.0f green:77.0f / 255.0f blue:160.0f / 255.0f alpha:1.0f];
        robinhoodColor = [UIColor colorWithRed:33.0f / 255.0f green:206.0f / 255.0f blue:153.0f / 255.0f alpha:1.0f];
        schwabColor = [UIColor colorWithRed:25.0f / 255.0f green:159.0f / 255.0f blue:218.0f / 255.0f alpha:1.0f];
        scottradeColor = [UIColor colorWithRed:69.0f / 255.0f green:40.0f / 255.0f blue:112.0f / 255.0f alpha:1.0f];
        fidelityColor = [UIColor colorWithRed:74.0f / 255.0f green:145.0f / 255.0f blue:46.0f / 255.0f alpha:1.0f];
        tdColor = [UIColor colorWithRed:2.0f / 255.0f green:182.0f / 255.0f blue:36.0f / 255.0f alpha:1.0f];
        optionshouseColor = [UIColor colorWithRed:46.0f / 255.0f green:98.0f / 255.0f blue:9.0f / 255.0f alpha:1.0f];
        lossColor = [UIColor colorWithRed:200.0f/255.0f green:22.0f/255.0f blue:0.0f alpha:1.0f];
        gainColor = [UIColor colorWithRed:0.0f green:200.0f/255.0f blue:22.0f/255.0f alpha:1.0f];

        styles = [TradeItStyles sharedStyles];
    }

    return self;
}

-(BOOL) isOnboarding {
    NSArray * linkedAccounts = [TTSDKPortfolioService linkedAccounts];

    if (linkedAccounts && linkedAccounts.count) {
        return NO;
    } else {
        return YES;
    }
}

-(CGFloat) retrieveScreenHeight {
    return [[UIScreen mainScreen] bounds].size.height;
}

-(BOOL) isSmallScreen {
    return ([self retrieveScreenHeight] < 500);
}

-(BOOL) isMediumScreen {
    return ([self retrieveScreenHeight] < 660);
}

-(BOOL) isLargeScreen {
    return ([self retrieveScreenHeight] >= 660);
}

-(UIColor *) retrieveBrokerColorByBrokerName:(NSString *)brokerName {
    UIColor * brokerColor;

    @try {
        brokerColor = [self valueForKey: [NSString stringWithFormat:@"%@Color", [brokerName lowercaseString]]];
    }
    @catch (NSException *exception) {
        brokerColor = styles.activeColor;
    }

    return brokerColor;
}

-(NSString *) getBrokerUsername:(NSString *) broker {
    NSDictionary *brokerUsernames = @{
                                      @"Dummy":@"Username",
                                      @"TD":@"User Id",
                                      @"Robinhood":@"Username",
                                      @"OptionsHouse":@"User Id",
                                      @"Schwabs":@"User Id",
                                      @"TradeStation":@"Username",
                                      @"Etrade":@"User Id",
                                      @"Fidelity":@"Username",
                                      @"Scottrade":@"Account #",
                                      @"Tradier":@"Username",
                                      @"IB":@"Username",
                                      };
    
    NSString * brokerName = [brokerUsernames valueForKey:broker];
    
    if (brokerName) {
        return brokerName;
    } else {
        return @"Username";
    }
}

-(CAShapeLayer *) retrieveCircleGraphicWithSize:(CGFloat)diameter andColor:(UIColor *)color {
    CAShapeLayer * circleLayer = [CAShapeLayer layer];
    [circleLayer setPath:[[UIBezierPath bezierPathWithOvalInRect:CGRectMake(0, 0, 4.0f, 4.0f)] CGPath]];
    [circleLayer setFillColor: color.CGColor];

    return circleLayer;
}

-(NSString *) formatIntegerToReadablePrice: (NSString *)price {
    unsigned int len = (int)[price length];
    unichar buffer[len];

    [price getCharacters:buffer range:NSMakeRange(0, len)];

    NSMutableString * formatString = [NSMutableString string];

    int pos = 0;
    for(int i = len - 1; i >= 0; --i) {
        char current = buffer[i];
        NSString * stringToInsert;
        
        if (pos && pos % 3 == 0) {
            stringToInsert = [NSString stringWithFormat:@"%c,", current];
        } else {
            stringToInsert = [NSString stringWithFormat:@"%c", current];
        }
        
        [formatString insertString:stringToInsert atIndex:0];

        pos++;
    }
    
    return formatString;
}

-(UIView *) retrieveLoadingOverlayForView:(UIView *)view withRadius:(NSInteger)radius {
    UIView * loadingView = [[UIView alloc] init];

    loadingView.frame = CGRectMake(0, 0, view.frame.size.width, view.frame.size.height);
    loadingView.backgroundColor = [styles.loadingBackgroundColor colorWithAlphaComponent: 0.4f];
    view.clipsToBounds = NO;
    UIActivityIndicatorView * indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];

    indicator.color = styles.loadingIconColor;

    indicator.hidden = NO;
    [loadingView addSubview:indicator];
    loadingView.layer.zPosition = 10.0f;
    indicator.frame = CGRectMake((loadingView.frame.size.width / 2) - radius, (loadingView.frame.size.height / 2) - radius, radius * 2, radius * 2);
    [indicator startAnimating];

    return loadingView;
}

- (void) spinWithOptions: (UIViewAnimationOptions) options {
    // this spin completes 360 degrees every 2 seconds
    [UIView animateWithDuration: 0.5f
                          delay: 0.0f
                        options: options
                     animations: ^{
                         loadingIcon.transform = CGAffineTransformRotate(loadingIcon.transform, M_PI / 2);
                     }
                     completion: ^(BOOL finished) {
                         if (finished) {
                             if (animating) {
                                 // if flag still set, keep spinning with constant speed
                                 [self spinWithOptions: UIViewAnimationOptionCurveLinear];
                             } else if (options != UIViewAnimationOptionCurveEaseOut) {
                                 // one last spin, with deceleration
                                 [self spinWithOptions: UIViewAnimationOptionCurveEaseOut];
                             }
                         }
                     }];
}

- (void) startSpin {
    if (!animating) {
        animating = YES;
        [self spinWithOptions: UIViewAnimationOptionCurveEaseIn];
    }
}

-(TTSDKCompanyDetails *) companyDetailsWithName: (NSString *)name intoContainer: (UIView *)container inController: (UIViewController *)vc {
    NSBundle *resourceBundle = [[TTSDKTradeItTicket globalTicket] getBundle];
    NSArray * companyDetailsArray = [resourceBundle loadNibNamed:@"TTSDKCompanyDetailsView" owner:vc options:nil];

    TTSDKCompanyDetails * companyDetailsNib = [companyDetailsArray firstObject];
    CGRect frame = CGRectMake(0, 0, container.frame.size.width, container.frame.size.height);
    companyDetailsNib.frame = frame;

    if ([vc.restorationIdentifier isEqualToString:@"tradeViewController"]) {
        companyDetailsNib.brokerDetails.hidden = NO;
    } else {
        companyDetailsNib.brokerDetails.hidden = YES;
    }

    [container addSubview:companyDetailsNib];

    return [companyDetailsNib init];
}

- (void) stopSpin {
    // set the flag to stop spinning after one last 90 degree increment
    animating = NO;
}

-(void) styleFocusedInput: (UITextField *)textField withPlaceholder: (NSString *)placeholder {
    textField.textColor = styles.activeColor;
    textField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:placeholder attributes:@{NSForegroundColorAttributeName: styles.activeColor}];
}

-(void) styleUnfocusedInput: (UITextField *)textField withPlaceholder: (NSString *)placeholder {
    double x = [placeholder doubleValue];

    UIColor * textColor;
    if (x > 0) {
        textColor = [UIColor blackColor];
    } else {
        textColor = styles.inactiveColor;
    }

    textField.textColor = textColor;
    textField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:placeholder attributes:@{NSForegroundColorAttributeName: textColor}];
}

-(void) styleBorderedFocusInput: (UIView *)input {
    input.layer.borderColor = styles.activeColor.CGColor;
}

-(void) styleBorderedUnfocusInput: (UIView *)input {
    input.layer.borderColor = styles.inactiveColor.CGColor;
}

-(void) styleDropdownButton:(UIButton *)button {
    [button setTitleColor:[UIColor redColor] forState:UIControlStateNormal];

    UIImageView * arrow = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"chevron_right"]];
    arrow.transform = CGAffineTransformMakeRotation(M_PI_2);
    arrow.contentMode = UIViewContentModeScaleAspectFit;

    [button addSubview: arrow];
}

-(void) styleAlertController:(UIView *)alertView {
    alertView.tintColor = styles.alertButtonColor;
    alertView.backgroundColor = [UIColor clearColor];
    alertView.layer.cornerRadius = 8.0f;
    alertView.layer.backgroundColor = styles.alertBackgroundColor.CGColor;
}

-(NSString *) formatPriceString: (NSNumber *)num {
    return [self formatPriceString:num withLocaleId:@"en_US"];
}

-(NSString *) formatPriceString: (NSNumber *)num withLocaleId: (NSString *) localeId {
    localeId = [self mapLocaleString: localeId];
    
    NSLocale * locale = [[NSLocale alloc] initWithLocaleIdentifier:localeId];
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    [formatter setNumberStyle:NSNumberFormatterCurrencyStyle];
    [formatter setLocale: locale];
    
    NSString * formatedString = [formatter stringFromNumber: num];
    
    if([localeId isEqualToString:@"en_SG"]) {
        formatedString = [NSString stringWithFormat:@"S%@", formatedString];
    }
    
    return formatedString;
}

-(double) numberFromPriceString: (NSString *)priceString {
    NSLocale * US = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    [formatter setNumberStyle:NSNumberFormatterCurrencyStyle];
    [formatter setLocale: US];

    return [formatter numberFromString:priceString].doubleValue;
}

-(NSString *) mapLocaleString:(NSString *) str {
    if([str isEqualToString:@"SGD"]) {
        return @"en_SG";
    } else {
        return @"en_US";
    }
}

-(NSString *) splitCamelCase:(NSString *) str {
    NSMutableString * str2 = [NSMutableString string];

    for (NSInteger i=0; i < str.length; i++){
        NSString *ch = [str substringWithRange:NSMakeRange(i, 1)];
        if ([ch rangeOfCharacterFromSet:[NSCharacterSet uppercaseLetterCharacterSet]].location != NSNotFound) {
            [str2 appendString:@" "];
        }
        [str2 appendString:ch];
    }

    return str2.capitalizedString;
}

-(NSMutableAttributedString *) logoStringLight {
    NSMutableAttributedString * text = [[NSMutableAttributedString alloc] initWithString: @"TRADEIT"];

    [text addAttribute:NSForegroundColorAttributeName
                 value:[UIColor lightGrayColor]
                 range:NSMakeRange(0, 5)];

    [text addAttribute:NSForegroundColorAttributeName
                 value:styles.activeColor
                 range:NSMakeRange(5, 2)];

    return text;
}

-(NSAttributedString *) getColoredString: (NSNumber *) number withFormat: (int) style {
    UIColor * positiveColor = [UIColor colorWithRed:58.0f/255.0f green:153.0f/255.0f blue:69.0f/255.0f alpha:1.0f];
    UIColor * negativeColor = [UIColor colorWithRed:197.0f/255.0f green:81.0f/255.0f blue:75.0f/255.0f alpha:1.0f];

    NSMutableAttributedString * attString;
    if([number doubleValue] > 0) {
        attString = [[NSMutableAttributedString alloc] initWithString:@"\u25B2"];
    } else {
        attString = [[NSMutableAttributedString alloc] initWithString:@"\u25BC"];
    }

    double absValue = fabs([number doubleValue]);
    NSString * asString = [self formatPriceString:[NSNumber numberWithDouble:absValue]];
    [attString appendAttributedString:[[NSAttributedString alloc] initWithString:asString]];

    if(style == NSNumberFormatterDecimalStyle) {
        [attString appendAttributedString:[[NSAttributedString alloc] initWithString:@"%"]];
    }

    if([number doubleValue] > 0) {
        [attString addAttribute:NSForegroundColorAttributeName
                          value:positiveColor
                          range:NSMakeRange(0, [attString length])];
    } else {
        [attString addAttribute:NSForegroundColorAttributeName
                          value:negativeColor
                          range:NSMakeRange(0, [attString length])];
    }

    return (NSAttributedString *) attString;
}

-(BOOL) containsString: (NSString *) base searchString: (NSString *) searchString {
    NSRange range = [base rangeOfString:searchString];
    return range.length != 0;
}

-(BOOL) hasTouchId {
    if(![LAContext class]) {
        return NO;
    }
    
    LAContext * myContext = [[LAContext alloc] init];
    NSError * authError = nil;
    
    if([myContext canEvaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics error:&authError]) {
        return YES;
    } else {
        return NO;
    }
}

@end
