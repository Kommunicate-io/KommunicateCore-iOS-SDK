//
//  TSMessageView.m
//  Felix Krause
//
//  Created by Felix Krause on 24.08.12.
//  Copyright (c) 2012 Felix Krause. All rights reserved.
//

#import "TSMessageView.h"
#import "HexColors.h"
#import "TSBlurView.h"
#import "TSMessage.h"
#import "ALUtilityClass.h"
#import <QuartzCore/QuartzCore.h>

#define TSMessageViewMinimumPadding 15.0

#define TSDesignFileName @"TSMessagesDefaultDesign"

static NSMutableDictionary *_notificationDesign;

@interface TSMessage (TSMessageView)
- (void)fadeOutNotification:(TSMessageView *)currentView; // private method of TSMessage, but called by TSMessageView in -[fadeMeOut]
@end

@interface TSMessageView () <UIGestureRecognizerDelegate>

/** The displayed title of this message */
@property (nonatomic, strong) NSString *title;

/** The displayed subtitle of this message view */
@property (nonatomic, strong) NSString *subtitle;

/** The title of the added button */
@property (nonatomic, strong) NSString *buttonTitle;

/** The view controller this message is displayed in */
@property (nonatomic, strong) UIViewController *viewController;


/** Internal properties needed to resize the view on device rotation properly */
@property (nonatomic, strong) UILabel *titleLabel;

@property (nonatomic, strong) UILabel *contentLabel;
@property (nonatomic, strong) UIImageView *iconImageView;
@property (nonatomic, strong) UIButton *button;
@property (nonatomic, strong) UIView *borderView;
@property (nonatomic, strong) UIImageView *backgroundImageView;
@property (nonatomic, strong) TSBlurView *backgroundBlurView; // Only used in iOS 7

@property (nonatomic, assign) CGFloat textSpaceLeft;
@property (nonatomic, assign) CGFloat textSpaceRight;

@property (copy) void (^callback)(void);
@property (copy) void (^buttonCallback)(void);

- (CGFloat)updateHeightOfMessageView;
- (void)layoutSubviews;

@end


@implementation TSMessageView{
    TSMessageNotificationType notificationType;
}
-(void) setContentFont:(UIFont *)contentFont{
    _contentFont = contentFont;
    [self.contentLabel setFont:contentFont];
}

-(void) setContentTextColor:(UIColor *)contentTextColor{
    _contentTextColor = contentTextColor;
    [self.contentLabel setTextColor:_contentTextColor];
}

-(void) setBannerBackgroundColor:(UIColor *)bannerBackgroundColor{
    _bannerBackgroundColor = bannerBackgroundColor;
    [self.backgroundBlurView setBackgroundColor:_bannerBackgroundColor];
}

-(void) setBannerShadowColor:(UIColor *)bannerShadowColor{
    _bannerShadowColor = bannerShadowColor;
    self.backgroundBlurView.layer.shadowColor = _bannerShadowColor.CGColor;
}

-(void) setBannerCornerRadius:(NSNumber *)bannerCornerRadius{
    _bannerCornerRadius = bannerCornerRadius;
    self.backgroundBlurView.layer.cornerRadius = [_bannerCornerRadius floatValue];
}

-(void) setBannerShadowRadius:(NSNumber *)bannerShadowRadius{
    _bannerShadowRadius = bannerShadowRadius;
    self.backgroundBlurView.layer.shadowRadius = [_bannerShadowRadius floatValue];
}

-(void) setShadowOpacity:(NSNumber *)shadowOpacity{
    _shadowOpacity = shadowOpacity;
    self.backgroundBlurView.layer.shadowOpacity = [_shadowOpacity floatValue];
}

-(void) setTitleFont:(UIFont *)aTitleFont{
    _titleFont = aTitleFont;
    [self.titleLabel setFont:_titleFont];
}

-(void)setTitleTextColor:(UIColor *)aTextColor{
    _titleTextColor = aTextColor;
    [self.titleLabel setTextColor:_titleTextColor];
}

-(void) setMessageIcon:(UIImage *)messageIcon{
    _messageIcon = messageIcon;
    [self updateCurrentIcon];
}

-(void) setErrorIcon:(UIImage *)errorIcon{
    _errorIcon = errorIcon;
    [self updateCurrentIcon];
}

-(void) setSuccessIcon:(UIImage *)successIcon{
    _successIcon = successIcon;
    [self updateCurrentIcon];
}

-(void) setWarningIcon:(UIImage *)warningIcon{
    _warningIcon = warningIcon;
    [self updateCurrentIcon];
}

-(void) updateCurrentIcon{
    UIImage *image = nil;
    switch (notificationType)
    {
        case TSMessageNotificationTypeMessage:
        {
            image = _messageIcon;
            self.iconImageView.image = _messageIcon;
            break;
        }
        case TSMessageNotificationTypeError:
        {
            image = _errorIcon;
            self.iconImageView.image = _errorIcon;
            break;
        }
        case TSMessageNotificationTypeSuccess:
        {
            image = _successIcon;
            self.iconImageView.image = _successIcon;
            break;
        }
        case TSMessageNotificationTypeWarning:
        {
            image = _warningIcon;
            self.iconImageView.image = _warningIcon;
            break;
        }
        default:
            break;
    }
    CGFloat topPadding = self.padding;

    if (@available(iOS 11.0, *)) {
        topPadding = topPadding + self.safeAreaInsets.top;
    }
    self.iconImageView.frame = CGRectMake(self.padding * 2,
                                          topPadding,
                                          image.size.width,
                                          image.size.height);
    self.iconImageView.layer.cornerRadius=image.size.width/2;
    self.iconImageView.layer.masksToBounds=YES;
}




+ (NSMutableDictionary *)notificationDesign
{
    if (!_notificationDesign)
    {
        NSBundle *bundle = [ALUtilityClass getBundle];
        NSString *path = [bundle pathForResource:TSDesignFileName ofType:@"json"];
        NSData *data = [NSData dataWithContentsOfFile:path];
        NSAssert(data != nil, @"Could not read TSMessages config file from main bundle with name %@.json", TSDesignFileName);

        _notificationDesign = [NSMutableDictionary dictionaryWithDictionary:[NSJSONSerialization JSONObjectWithData:data
                                                                                                            options:kNilOptions
                                                                                                              error:nil]];
    }

    return _notificationDesign;
}


+ (void)addNotificationDesignFromFile:(NSString *)filename
{
    NSString *path = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:filename];
    if ([[NSFileManager defaultManager] fileExistsAtPath:path])
    {
        NSDictionary *design = [NSJSONSerialization JSONObjectWithData:[NSData dataWithContentsOfFile:path]
                                                               options:kNilOptions
                                                                 error:nil];

        [[TSMessageView notificationDesign] addEntriesFromDictionary:design];
    }
    else
    {
        NSAssert(NO, @"Error loading design file with name %@", filename);
    }
}

- (CGFloat)padding
{
    // Adds 10 padding to to cover navigation bar
    return self.messagePosition == TSMessageNotificationPositionNavBarOverlay ? TSMessageViewMinimumPadding + 10.0f : TSMessageViewMinimumPadding;
}

- (id)initWithTitle:(NSString *)title
           subtitle:(NSString *)subtitle
              image:(UIImage *)image
               type:(TSMessageNotificationType)aNotificationType
           duration:(CGFloat)duration
   inViewController:(UIViewController *)viewController
           callback:(void (^)(void))callback
        buttonTitle:(NSString *)buttonTitle
     buttonCallback:(void (^)(void))buttonCallback
         atPosition:(TSMessageNotificationPosition)position
canBeDismissedByUser:(BOOL)dismissingEnabled
{
    NSDictionary *notificationDesign = [TSMessageView notificationDesign];

    if ((self = [self init]))
    {
        _title = title;
        _subtitle = subtitle;
        _buttonTitle = buttonTitle;
        _duration = duration;
        _viewController = viewController;
        _messagePosition = position;
        self.callback = callback;
        self.buttonCallback = buttonCallback;

        CGSize screenSize = [UIScreen mainScreen].bounds.size;
        CGFloat screenWidth = screenSize.width;
        CGFloat padding = [self padding];

        NSDictionary *current;
        NSString *currentString;
        notificationType = aNotificationType;
        switch (notificationType)
        {
            case TSMessageNotificationTypeMessage:
            {
                currentString = @"message";
                break;
            }
            case TSMessageNotificationTypeError:
            {
                currentString = @"error";
                break;
            }
            case TSMessageNotificationTypeSuccess:
            {
                currentString = @"success";
                break;
            }
            case TSMessageNotificationTypeWarning:
            {
                currentString = @"warning";
                break;
            }

            default:
                break;
        }

        current = [notificationDesign valueForKey:currentString];


        if (!image && [[current valueForKey:@"imageName"] length])
        {
            image = [self bundledImageNamed:[current valueForKey:@"imageName"]];
        }
        if (!image && [[current valueForKey:@"imageName"] length])
        {
            image = [UIImage imageNamed:[current valueForKey:@"imageName"]];
        }

        if (![TSMessage iOS7StyleEnabled])
        {
            self.alpha = 0.0;

            // add background image here
            UIImage *backgroundImage = [self bundledImageNamed:[current valueForKey:@"backgroundImageName"]];
            backgroundImage = [backgroundImage stretchableImageWithLeftCapWidth:0.0 topCapHeight:0.0];
            
            _backgroundImageView = [[UIImageView alloc] initWithImage:backgroundImage];
            self.backgroundImageView.autoresizingMask = (UIViewAutoresizingFlexibleWidth);
            [self addSubview:self.backgroundImageView];
        }
        else
        {
            // On iOS 7 and above use a blur layer instead (not yet finished)
            _backgroundBlurView = [[TSBlurView alloc] init];
            self.backgroundBlurView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
            [self addSubview:self.backgroundBlurView];
            self.backgroundBlurView.layer.shadowOffset = CGSizeMake(0, 2);
            self.backgroundBlurView.layer.shouldRasterize = YES;
            self.backgroundBlurView.layer.rasterizationScale = [UIScreen mainScreen].scale;
        }

        UIColor *fontColor = [UIColor colorWithHexString:[current valueForKey:@"textColor"]];


        self.textSpaceLeft = 2 * padding;
        if (image) self.textSpaceLeft += image.size.width + padding;

        // Set up title label
        _titleLabel = [[UILabel alloc] init];
        [self.titleLabel setText:title];
        [self.titleLabel setTextColor:fontColor];
        [self.titleLabel setBackgroundColor:[UIColor clearColor]];
        CGFloat fontSize = [[current valueForKey:@"titleFontSize"] floatValue];
        NSString *fontName = [current valueForKey:@"titleFontName"];
        if (fontName != nil) {
            [self.titleLabel setFont:[UIFont fontWithName:fontName size:fontSize]];
        } else {
            [self.titleLabel setFont:[UIFont boldSystemFontOfSize:fontSize]];
        }
        
        //        [self.titleLabel setShadowColor:[UIColor colorWithHexString:[current valueForKey:@"shadowColor"]]];
        //        [self.titleLabel setShadowOffset:CGSizeMake([[current valueForKey:@"shadowOffsetX"] floatValue],
        //                                                    [[current valueForKey:@"shadowOffsetY"] floatValue])];

        self.titleLabel.numberOfLines = 0;
        self.titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
        [self addSubview:self.titleLabel];

        // Set up content label (if set)
        if ([subtitle length])
        {
            _contentLabel = [[UILabel alloc] init];
            [self.contentLabel setText:subtitle];

            UIColor *contentTextColor = [UIColor colorWithHexString:[current valueForKey:@"contentTextColor"]];
            if (!contentTextColor)
            {
                contentTextColor = fontColor;
            }
            [self.contentLabel setTextColor:contentTextColor];
            [self.contentLabel setBackgroundColor:[UIColor clearColor]];
            CGFloat fontSize = [[current valueForKey:@"contentFontSize"] floatValue];
            NSString *fontName = [current valueForKey:@"contentFontName"];
            if (fontName != nil) {
                [self.contentLabel setFont:[UIFont fontWithName:fontName size:fontSize]];
            } else {
                [self.contentLabel setFont:[UIFont systemFontOfSize:fontSize]];
            }
            [self.contentLabel setShadowColor:self.titleLabel.shadowColor];
            [self.contentLabel setShadowOffset:self.titleLabel.shadowOffset];
            // Restricting Notification subtitle(Content) to 2 lines. 
            self.contentLabel.numberOfLines = 2;

            [self addSubview:self.contentLabel];
        }

        if (image)
        {
            _iconImageView = [[UIImageView alloc] initWithImage:image];

            CGFloat topPadding = self.padding;
            if (@available(iOS 11.0, *)) {
                topPadding = topPadding + self.safeAreaInsets.top;
            }
            self.iconImageView.frame = CGRectMake(padding * 2,
                                                  topPadding,
                                                  image.size.width,
                                                  image.size.height);
            
            self.iconImageView.layer.cornerRadius = image.size.width/2;
            self.iconImageView.layer.masksToBounds = YES;
            [self addSubview:self.iconImageView];
            
        }

        // Set up button (if set)
        if ([buttonTitle length])
        {
            _button = [UIButton buttonWithType:UIButtonTypeCustom];


            UIImage *buttonBackgroundImage = [self bundledImageNamed:[current valueForKey:@"buttonBackgroundImageName"]];

            buttonBackgroundImage = [buttonBackgroundImage resizableImageWithCapInsets:UIEdgeInsetsMake(15.0, 12.0, 15.0, 11.0)];

            if (!buttonBackgroundImage)
            {
                buttonBackgroundImage = [self bundledImageNamed:[current valueForKey:@"NotificationButtonBackground"]];
                buttonBackgroundImage = [buttonBackgroundImage resizableImageWithCapInsets:UIEdgeInsetsMake(15.0, 12.0, 15.0, 11.0)];
            }

            [self.button setBackgroundImage:buttonBackgroundImage forState:UIControlStateNormal];
            [self.button setTitle:self.buttonTitle forState:UIControlStateNormal];

            UIColor *buttonTitleShadowColor = [UIColor colorWithHexString:[current valueForKey:@"buttonTitleShadowColor"]];
            if (!buttonTitleShadowColor)
            {
                buttonTitleShadowColor = self.titleLabel.shadowColor;
            }

            [self.button setTitleShadowColor:buttonTitleShadowColor forState:UIControlStateNormal];

            UIColor *buttonTitleTextColor = [UIColor colorWithHexString:[current valueForKey:@"buttonTitleTextColor"]];
            if (!buttonTitleTextColor)
            {
                buttonTitleTextColor = fontColor;
            }

            [self.button setTitleColor:buttonTitleTextColor forState:UIControlStateNormal];
            self.button.titleLabel.font = [UIFont boldSystemFontOfSize:14.0];
            self.button.titleLabel.shadowOffset = CGSizeMake([[current valueForKey:@"buttonTitleShadowOffsetX"] floatValue],
                                                             [[current valueForKey:@"buttonTitleShadowOffsetY"] floatValue]);
            [self.button addTarget:self
                            action:@selector(buttonTapped:)
                  forControlEvents:UIControlEventTouchUpInside];

            self.button.contentEdgeInsets = UIEdgeInsetsMake(0.0, 5.0, 0.0, 5.0);
            [self.button sizeToFit];
            self.button.frame = CGRectMake(screenWidth - padding - self.button.frame.size.width,
                                           0.0,
                                           self.button.frame.size.width,
                                           31.0);

            [self addSubview:self.button];

            self.textSpaceRight = self.button.frame.size.width + padding;
        }

        // Add a border on the bottom (or on the top, depending on the view's postion)
        if (![TSMessage iOS7StyleEnabled])
        {
            _borderView = [[UIView alloc] initWithFrame:CGRectMake(0.0,
                                                                   0.0, // will be set later
                                                                   screenWidth,
                                                                   [[current valueForKey:@"borderHeight"] floatValue])];
            self.borderView.backgroundColor = [UIColor colorWithHexString:[current valueForKey:@"borderColor"]];
            self.borderView.autoresizingMask = (UIViewAutoresizingFlexibleWidth);
            [self addSubview:self.borderView];
        }


        CGFloat actualHeight = [self updateHeightOfMessageView]; // this call also takes care of positioning the labels
        CGFloat topPosition = -actualHeight;

        if (self.messagePosition == TSMessageNotificationPositionBottom)
        {
            topPosition = self.viewController.view.bounds.size.height;
        }

        self.frame = CGRectMake(0.0, topPosition, screenWidth, actualHeight);

        if (self.messagePosition == TSMessageNotificationPositionTop)
        {
            self.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        }
        else
        {
            self.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin);
        }

        if (dismissingEnabled)
        {
            UISwipeGestureRecognizer *gestureRec = [[UISwipeGestureRecognizer alloc] initWithTarget:self
                                                                                             action:@selector(fadeMeOut)];
            [gestureRec setDirection:(self.messagePosition == TSMessageNotificationPositionTop ?
                                      UISwipeGestureRecognizerDirectionUp :
                                      UISwipeGestureRecognizerDirectionDown)];
            [self addGestureRecognizer:gestureRec];

            UITapGestureRecognizer *tapRec = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                     action:@selector(fadeMeOut)];
            [self addGestureRecognizer:tapRec];
        }

        if (self.callback) {
            UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
            tapGesture.delegate = self;
            [self addGestureRecognizer:tapGesture];
        }
    }
    return self;
}


- (CGFloat)updateHeightOfMessageView {
    CGFloat currentHeight = 0.0;
    CGFloat padding = [self padding];
    CGFloat screenWidth = CGRectGetWidth([UIScreen mainScreen].bounds);
    CGFloat textSpaceWidth = screenWidth - (padding * 2) - self.textSpaceLeft - self.textSpaceRight;

    if (self.title.length > 0) {
        CGSize titleSize = [self.titleLabel sizeThatFits:CGSizeMake(textSpaceWidth, CGFLOAT_MAX)];
        self.titleLabel.frame = CGRectMake(self.textSpaceLeft, padding * 2 + self.safeAreaInsets.top, textSpaceWidth, titleSize.height);
        currentHeight += titleSize.height + padding;
    }

    if (self.subtitle.length > 0) {
        CGFloat contentLabelHeight = [self.contentLabel sizeThatFits:CGSizeMake(textSpaceWidth, CGFLOAT_MAX)].height;
        self.contentLabel.frame = CGRectMake(self.textSpaceLeft, CGRectGetMaxY(self.titleLabel.frame) + padding - 10, textSpaceWidth, contentLabelHeight);
        currentHeight += contentLabelHeight + padding;
    }

    if (self.iconImageView) {
        CGFloat iconY = self.safeAreaInsets.top + (currentHeight / 4) + (padding / 2);
        CGFloat iconX = self.textSpaceLeft / 1.7 - CGRectGetWidth(self.iconImageView.frame) / 2;
        self.iconImageView.frame = CGRectMake(iconX, iconY, CGRectGetWidth(self.iconImageView.frame), CGRectGetHeight(self.iconImageView.frame));
    }

    if (self.button) {
        CGFloat buttonX = screenWidth - padding - CGRectGetWidth(self.button.frame);
        CGFloat buttonY = currentHeight + padding;
        self.button.frame = CGRectMake(buttonX, buttonY, CGRectGetWidth(self.button.frame), CGRectGetHeight(self.button.frame));
        currentHeight += CGRectGetHeight(self.button.frame) + padding;
    }

    if (self.messagePosition == TSMessageNotificationPositionTop) {
        self.borderView.frame = CGRectMake(self.borderView.frame.origin.x, currentHeight, CGRectGetWidth(self.borderView.frame), CGRectGetHeight(self.borderView.frame));
    }

    currentHeight += CGRectGetHeight(self.borderView.frame);
    self.frame = CGRectMake(0.0, self.frame.origin.y, screenWidth, currentHeight);

    UIWindow *keyWindow = [UIApplication.sharedApplication.windows firstObject];
    CGFloat statusBarHeight = keyWindow.windowScene.statusBarManager.statusBarFrame.size.height;
    
    CGRect backgroundFrame = CGRectMake(padding, statusBarHeight + padding, screenWidth - padding * 2, currentHeight + padding);
    self.backgroundImageView.frame = backgroundFrame;
    self.backgroundBlurView.frame = backgroundFrame;

    return currentHeight;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    [self updateHeightOfMessageView];
}

- (void)fadeMeOut
{
    [[TSMessage sharedMessage] performSelectorOnMainThread:@selector(fadeOutNotification:) withObject:self waitUntilDone:NO];
}

- (void)didMoveToWindow
{
    [super didMoveToWindow];
    if (self.duration == TSMessageNotificationDurationEndless && self.superview && !self.window )
    {
        // view controller was dismissed, let's fade out
        [self fadeMeOut];
    }
}
#pragma mark - Target/Action

- (void)buttonTapped:(id) sender
{
    if (self.buttonCallback)
    {
        self.buttonCallback();
    }

    [self fadeMeOut];
}

- (void)handleTap:(UITapGestureRecognizer *)tapGesture
{
    if (tapGesture.state == UIGestureRecognizerStateRecognized)
    {
        if (self.callback)
        {
            self.callback();
        }
    }
}

#pragma mark - UIGestureRecognizerDelegate

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    return ! ([touch.view isKindOfClass:[UIControl class]]);
}

#pragma mark - Grab Image From Pod Bundle
- (UIImage *)bundledImageNamed:(NSString*)name{
    NSBundle *bundle = [ALUtilityClass getBundle];
    NSString *imagePath = [bundle pathForResource:name ofType:nil];
    return [[UIImage alloc] initWithContentsOfFile:imagePath];
}

@end
