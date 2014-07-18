//
//  UNRCustomScrollIndicator.m
//  unread
//
//  Created by Jared Sinclair on 11/11/13.
//  Copyright (c) 2013 Nice Boy LLC. All rights reserved.
//

#import "UNRCustomScrollIndicator.h"

#import "UNRDisplayPreferencesManager.h"

static CGFloat indicatorWidth = 2.5f;
static CGFloat minIndicatorHeightWhenCompressed = 8.0f;
static CGFloat minIndicatorHeightWhenScrolling = 37.0f;
static CGFloat indicatorRightMargin = 2.5f;
static UIEdgeInsets inherentInset;

@interface UNRCustomScrollIndicator ()

@property (strong, nonatomic) NSTimer *hidingTimer;
@property (assign, nonatomic) BOOL shouldHide;
@property (assign, nonatomic) BOOL isScrollingToTop;
@property (weak, nonatomic) UIScrollView *scrollView;

@end

@implementation UNRCustomScrollIndicator

+ (CGRect)targetRectForScrollView:(UIScrollView *)scrollView {
    CGRect underlyingRect = [self underlyingIndicatorRectForScrollView:scrollView];
    CGRect adjustedRect = [self adjustUnderlyingRect:underlyingRect forScrollView:scrollView];
    return adjustedRect;
}

+ (CGRect)underlyingIndicatorRectForScrollView:(UIScrollView *)scrollView {
    CGRect underlyingRect = CGRectZero;
    CGFloat contentHeight = scrollView.contentSize.height;
    UIEdgeInsets indicatorInsets = scrollView.scrollIndicatorInsets;
    CGFloat frameHeight = scrollView.frame.size.height;
    UIEdgeInsets contentInset = scrollView.contentInset;
    CGPoint contentOffset = scrollView.contentOffset;
    CGFloat contentHeightWithInsets = contentHeight + contentInset.top + contentInset.bottom;
    CGFloat frameHeightWithoutScrollIndicatorInsets = (frameHeight - indicatorInsets.top - indicatorInsets.bottom - inherentInset.top);
    
    underlyingRect.size.width = indicatorWidth;
    underlyingRect.origin.x = scrollView.frame.size.width - indicatorWidth - indicatorRightMargin;
    
    CGFloat ratio = (contentHeightWithInsets != 0) ? frameHeightWithoutScrollIndicatorInsets / contentHeightWithInsets : 1.0f;
    
    underlyingRect.size.height = frameHeight * ratio;
    underlyingRect.origin.y = contentOffset.y + ((contentOffset.y+contentInset.top) * ratio) + indicatorInsets.top;
    
    if (underlyingRect.size.height < minIndicatorHeightWhenScrolling) {
        CGFloat contentHeightWithoutLastFrame = contentHeightWithInsets - frameHeight;
        CGFloat percentageScrolled = (contentOffset.y+contentInset.top) / contentHeightWithoutLastFrame;
        underlyingRect.origin.y -= (minIndicatorHeightWhenScrolling - underlyingRect.size.height) * percentageScrolled;
        underlyingRect.size.height = minIndicatorHeightWhenScrolling;
    }
    
    underlyingRect.size.height -= inherentInset.top;
    underlyingRect.origin.y += inherentInset.top;
    
    return underlyingRect;
}

+ (CGRect)adjustUnderlyingRect:(CGRect)underlyingRect forScrollView:(UIScrollView *)scrollView {
    CGRect adjustedRect = underlyingRect;
    
    CGFloat contentHeight = scrollView.contentSize.height;
    UIEdgeInsets contentInset = scrollView.contentInset;
    UIEdgeInsets indicatorInset = scrollView.scrollIndicatorInsets;
    CGFloat frameHeight = scrollView.frame.size.height;
    CGPoint contentOffset = scrollView.contentOffset;
    CGFloat contentHeightWithInsets = contentHeight + contentInset.top + contentInset.bottom;
    
    if (contentOffset.y < 0-contentInset.top
     || adjustedRect.origin.y < (0-contentInset.top + indicatorInset.top) + inherentInset.top) {
        CGFloat heightAdjustment = fabsf(contentInset.top - fabsf(contentOffset.y));
        adjustedRect.size.height -= heightAdjustment;
        adjustedRect.size.height = MAX(adjustedRect.size.height, minIndicatorHeightWhenCompressed);
        adjustedRect.origin.y = contentOffset.y + indicatorInset.top + inherentInset.top;
    }
    else if (contentOffset.y + frameHeight > contentHeight + contentInset.bottom
        || adjustedRect.origin.y + adjustedRect.size.height > contentOffset.y + frameHeight - indicatorInset.bottom - inherentInset.bottom) {
        adjustedRect.origin.y = contentHeightWithInsets - underlyingRect.size.height - indicatorInset.bottom;
        CGFloat heightAdjustment = (contentOffset.y + frameHeight) - (contentHeight + contentInset.bottom);
        adjustedRect.size.height -= heightAdjustment;
        adjustedRect.size.height = MAX(adjustedRect.size.height, minIndicatorHeightWhenCompressed);
        adjustedRect.origin.y = contentOffset.y + frameHeight - adjustedRect.size.height - indicatorInset.bottom - inherentInset.bottom;
    }
    
    return adjustedRect;
}

+ (BOOL)indicatorShouldBeVisibleForScrollView:(UIScrollView *)scrollView {
    
    if (scrollView.decelerating == NO && scrollView.dragging == NO) {
        return NO;
    }
    
    CGFloat contentHeight = scrollView.contentSize.height;
    CGFloat frameHeight = scrollView.frame.size.height;
    UIEdgeInsets contentInset = scrollView.contentInset;
    CGFloat contentHeightWithInsets = contentHeight + contentInset.top + contentInset.bottom;
    return (contentHeightWithInsets > frameHeight * 1.1 && contentHeight > 0);
}

#pragma mark - UIView

- (void)dealloc {
    [self cancelHidingTimer];
    [self removeThemeChangeObservation];
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.layer.cornerRadius = indicatorWidth * 0.75;
        self.clipsToBounds = YES;
        self.alpha = 0;
        _shouldHide = YES;
        inherentInset = UIEdgeInsetsMake(2.5, 0, 2.5, 0);
        [self addThemeChangeObservation];
        [self resetColors];
    }
    return self;
}

- (void)setKeepHidden:(BOOL)keepHidden {
    if (_keepHidden != keepHidden) {
        _keepHidden = keepHidden;
        if (_keepHidden) {
            [self setShouldHide:YES immediately:YES];
        }
    }
}

#pragma mark - Scroll View Changes

- (void)reset {
    if (self.scrollView) {
        [self setFrame:[self.class targetRectForScrollView:self.scrollView]];
        [self cancelHidingTimer];
        _isScrollingToTop = NO;
        _keepHidden = NO;
        _shouldHide = YES;
        [self hide:NO];
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (self.scrollView == nil) {
        [self setScrollView:scrollView];
    }
    
    [self setFrame:[self.class targetRectForScrollView:scrollView]];
    
    if (self.isScrollingToTop == NO && self.keepHidden == NO) {
        if ([self.class indicatorShouldBeVisibleForScrollView:scrollView]) {
            [self setShouldHide:NO immediately:YES];
            [self resetHidingTimer];
        } else {
            [self setShouldHide:YES immediately:NO];
        }
    } else {
        [self setShouldHide:YES immediately:NO];
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    if (decelerate == NO) {
        [self setShouldHide:YES immediately:YES];
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    [self setShouldHide:YES immediately:YES];
}

- (void)scrollViewWillScrollToTop:(UIScrollView *)scrollView {
    [self setIsScrollingToTop:YES];
    [self setShouldHide:YES immediately:YES];
    
    // ScrollViewDidScrollToTop: is not called sometimes, goddamn UIKit. :-/
    __weak UNRCustomScrollIndicator *weakSelf = self;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.35 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        [weakSelf setIsScrollingToTop:NO];
    });
}

- (void)scrollViewDidScrollToTop:(UIScrollView *)scrollView {
    [self setIsScrollingToTop:NO];
}

#pragma mark - Animations

- (void)setShouldHide:(BOOL)shouldHide immediately:(BOOL)immediately {
    
    if (_shouldHide != shouldHide) {
        _shouldHide = shouldHide;
        if (_shouldHide == NO) {
            [self show:YES];
        }
        else if (immediately) {
            [self hide:YES];
        }
        else {
            [self resetHidingTimer];
        }
    }
}

- (void)show:(BOOL)animated {
    [self setAlpha:1];
}

- (void)hide:(BOOL)animated {
    __weak UNRCustomScrollIndicator *weakSelf = self;
    UIViewAnimationOptions options = UIViewAnimationOptionBeginFromCurrentState;
    [UIView animateWithDuration:0.33 delay:0 options:options animations:^{
        [weakSelf setAlpha:0];
    } completion:nil];
}

#pragma mark - Hiding Timer

- (void)resetHidingTimer {
    
#warning Don't need the hiding timer anymore, probably
    /*
    
    if ([_hidingTimer isValid] == NO) {
        [self setHidingTimer:nil];
    }
    
    if (_hidingTimer == nil) {
        NSTimer *timer = [[NSTimer alloc] initWithFireDate:[NSDate dateWithTimeIntervalSinceNow:0.5]
                                                interval:0
                                                  target:self
                                                selector:@selector(hidingTimerFired:)
                                                userInfo:nil
                                                 repeats:NO];
        [self setHidingTimer:timer];
        [[NSRunLoop mainRunLoop] addTimer:timer forMode:NSRunLoopCommonModes];
    }
    else {
        [_hidingTimer setFireDate:[NSDate dateWithTimeIntervalSinceNow:0.5]];
    }
     */
}

- (void)cancelHidingTimer {
#warning Don't need the hiding timer anymore, probably
    /*
    [_hidingTimer invalidate];
    _hidingTimer = nil;
     */
}

- (void)hidingTimerFired:(NSTimer *)timer {
#warning Don't need the hiding timer anymore, probably
    /*
    if (self.scrollView.dragging == NO) {
        [self setShouldHide:YES immediately:YES];
    }
    */
}

#pragma mark - Colors

- (void)addThemeChangeObservation {
    __weak UNRCustomScrollIndicator *weakSelf = self;
    
    [[NSNotificationCenter defaultCenter]
     addObserverForName:UNRDisplayPreferencesManagerDidChangeThemeNotification
     object:nil
     queue:[NSOperationQueue mainQueue]
     usingBlock:^(NSNotification *note) {
         [weakSelf resetColors];
     }];
}

- (void)removeThemeChangeObservation {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UNRDisplayPreferencesManagerDidChangeThemeNotification object:nil];
}

- (void)resetColors {
    self.backgroundColor = [UNRDisplayPreferencesManager sharedInstance].currentTheme.color_scrollIndicator;
}

@end










