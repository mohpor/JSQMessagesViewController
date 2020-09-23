//
//  Created by Jesse Squires
//  http://www.jessesquires.com
//
//
//  Documentation
//  http://cocoadocs.org/docsets/JSQMessagesViewController
//
//
//  GitHub
//  https://github.com/jessesquires/JSQMessagesViewController
//
//
//  License
//  Copyright (c) 2014 Jesse Squires
//  Released under an MIT license: http://opensource.org/licenses/MIT
//

#import "JSQMessagesInputToolbar.h"

#import "JSQMessagesComposerTextView.h"

#import "JSQMessagesToolbarButtonFactory.h"

#import "UIColor+JSQMessages.h"
#import "UIImage+JSQMessages.h"
#import "UIView+JSQMessages.h"

static void * kJSQMessagesInputToolbarKeyValueObservingContext = &kJSQMessagesInputToolbarKeyValueObservingContext;


@interface JSQMessagesInputToolbar ()

@property (assign, nonatomic) BOOL jsq_isObserving;

@end



@implementation JSQMessagesInputToolbar

@dynamic delegate;

#pragma mark - Initialization

- (void)awakeFromNib
{
    
    [super awakeFromNib];
    [self setTranslatesAutoresizingMaskIntoConstraints:NO];
    
    self.jsq_isObserving = NO;
    self.sendButtonOnRight = YES;
    
    
    self.preferredDefaultHeight = 44.0f;
    self.maximumHeight = 180;
    
    self.backgroundColor = [UIColor clearColor];
    self.layer.borderWidth = 0.0f;
    self.clipsToBounds = YES;
    [self setBackgroundImage:[UIImage new] forToolbarPosition:UIToolbarPositionAny barMetrics:UIBarMetricsDefault];
    [self setShadowImage:[UIImage new] forToolbarPosition:UIToolbarPositionAny];
    
    JSQMessagesToolbarContentView *toolbarContentView = [self loadToolbarContentView];
//    CGRect frame = self.frame;
//    frame.size.height = 44.0f;
    
    toolbarContentView.frame = self.frame;
    toolbarContentView.backgroundColor = [UIColor whiteColor];
    toolbarContentView.clipsToBounds = YES;
    //toolbarContentView.layer.cornerRadius = toolbarContentView.frame.size.height/2;
    toolbarContentView.layer.borderWidth = 0.0f;
    
    [self addSubview:toolbarContentView];
    [self jsq_pinAllEdgesOfSubview:toolbarContentView];
    [self setNeedsUpdateConstraints];
    _contentView = toolbarContentView;
    
    [self jsq_addObservers];
    
    self.contentView.rightBarButtonItem = [JSQMessagesToolbarButtonFactory defaultSendButtonItem];
   // self.contentView.leftBarButtonItem = [JSQMessagesToolbarButtonFactory fileButtonItem];
    
    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(leftLongPress)];
    longPress.minimumPressDuration = 0.5;
   // [self.contentView.timerBarButtonItem addGestureRecognizer:longPress];
    
    
    [self toggleSendButtonEnabled];
    
    
    
    
//    [super awakeFromNib];
//    [self setTranslatesAutoresizingMaskIntoConstraints:NO];
//
//    self.jsq_isObserving = NO;
//    self.sendButtonOnRight = YES;
//
//    self.preferredDefaultHeight = 44.0f;
//    self.maximumHeight = NSNotFound;
//
//    JSQMessagesToolbarContentView *toolbarContentView = [self loadToolbarContentView];
//    toolbarContentView.frame = self.frame;
//    [self addSubview:toolbarContentView];
//    [self jsq_pinAllEdgesOfSubview:toolbarContentView];
//    [self setNeedsUpdateConstraints];
//    _contentView = toolbarContentView;
//
//    [self jsq_addObservers];
//
//    self.contentView.leftBarButtonItem = [JSQMessagesToolbarButtonFactory defaultAccessoryButtonItem];
//    self.contentView.rightBarButtonItem = [JSQMessagesToolbarButtonFactory defaultSendButtonItem];
//
//    [self toggleSendButtonEnabled];
}

- (JSQMessagesToolbarContentView *)loadToolbarContentView
{
    NSArray *nibViews = [[NSBundle bundleForClass:[JSQMessagesInputToolbar class]] loadNibNamed:NSStringFromClass([JSQMessagesToolbarContentView class])
                                                                                          owner:nil
                                                                                        options:nil];
    return nibViews.firstObject;
}

- (void)dealloc
{
    [self jsq_removeObservers];
}

#pragma mark - Setters

- (void)setPreferredDefaultHeight:(CGFloat)preferredDefaultHeight
{
    NSParameterAssert(preferredDefaultHeight > 0.0f);
    _preferredDefaultHeight = preferredDefaultHeight;
}

#pragma mark - Actions

- (void)jsq_leftBarButtonPressed:(UIButton *)sender
{
    [self.delegate messagesInputToolbar:self didPressLeftBarButton:sender];
}

- (void)jsq_rightBarButtonPressed:(UIButton *)sender
{
    [self.delegate messagesInputToolbar:self didPressRightBarButton:sender];
}

#pragma mark - Input toolbar

- (void)toggleSendButtonEnabled
{
    BOOL hasText = [self.contentView.textView hasText];
    UIImage *btnCameraImage = [UIImage imageNamed:@"ic_Camera"];
    UIImage *btnSend = [UIImage imageNamed:@"Send_enable"];

    if (self.sendButtonOnRight) {
        if (hasText) {
            [self.contentView.rightBarButtonItem setImage:btnSend forState:UIControlStateNormal];
            self.contentView.rightBarButtonItem.tag = 101;
        }else{
            [self.contentView.rightBarButtonItem setImage:btnCameraImage forState:UIControlStateNormal];
            self.contentView.rightBarButtonItem.tag = 102;
        }
    }
    else {
        if (hasText) {
            [self.contentView.leftBarButtonItem setImage:btnSend forState:UIControlStateNormal];
            self.contentView.leftBarButtonItem.tag = 101;
        }else{
            [self.contentView.leftBarButtonItem setImage:btnCameraImage forState:UIControlStateNormal];
            self.contentView.leftBarButtonItem.tag = 102;
        }
    }
}

#pragma mark - Key-value observing

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if (context == kJSQMessagesInputToolbarKeyValueObservingContext) {
        if (object == self.contentView) {

            if ([keyPath isEqualToString:NSStringFromSelector(@selector(leftBarButtonItem))]) {

                [self.contentView.leftBarButtonItem removeTarget:self
                                                          action:NULL
                                                forControlEvents:UIControlEventTouchUpInside];

                [self.contentView.leftBarButtonItem addTarget:self
                                                       action:@selector(jsq_leftBarButtonPressed:)
                                             forControlEvents:UIControlEventTouchUpInside];
            }
            else if ([keyPath isEqualToString:NSStringFromSelector(@selector(rightBarButtonItem))]) {

                [self.contentView.rightBarButtonItem removeTarget:self
                                                           action:NULL
                                                 forControlEvents:UIControlEventTouchUpInside];

                [self.contentView.rightBarButtonItem addTarget:self
                                                        action:@selector(jsq_rightBarButtonPressed:)
                                              forControlEvents:UIControlEventTouchUpInside];
            }

            [self toggleSendButtonEnabled];
        }
    }
}

- (void)jsq_addObservers
{
    if (self.jsq_isObserving) {
        return;
    }

    [self.contentView addObserver:self
                       forKeyPath:NSStringFromSelector(@selector(leftBarButtonItem))
                          options:0
                          context:kJSQMessagesInputToolbarKeyValueObservingContext];

    [self.contentView addObserver:self
                       forKeyPath:NSStringFromSelector(@selector(rightBarButtonItem))
                          options:0
                          context:kJSQMessagesInputToolbarKeyValueObservingContext];

    self.jsq_isObserving = YES;
}

- (void)jsq_removeObservers
{
    if (!_jsq_isObserving) {
        return;
    }

    @try {
        [_contentView removeObserver:self
                          forKeyPath:NSStringFromSelector(@selector(leftBarButtonItem))
                             context:kJSQMessagesInputToolbarKeyValueObservingContext];

        [_contentView removeObserver:self
                          forKeyPath:NSStringFromSelector(@selector(rightBarButtonItem))
                             context:kJSQMessagesInputToolbarKeyValueObservingContext];
    }
    @catch (NSException *__unused exception) { }
    
    _jsq_isObserving = NO;
}

@end
