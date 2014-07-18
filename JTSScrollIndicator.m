//
//  JTSScrollIndicator.m
//
//
//  Created by Jared Sinclair on 11/11/13.
//  Copyright (c) 2013 Nice Boy LLC. All rights reserved.
//

#import "JTSScrollIndicator.h"

static CGFloat JTSScrollIndicator_IndicatorWidth = 2.5f;
static CGFloat JTSScrollIndicator_MinIndicatorHeightWhenCompressed = 8.0f;
static CGFloat JTSScrollIndicator_MinIndicatorHeightWhenScrolling = 37.0f;
static CGFloat JTSScrollIndicator_IndicatorRightMargin = 2.5f;
static UIEdgeInsets JTSScrollIndicator_InherentInset;

@interface JTSScrollIndicator ()

@property (assign, nonatomic) BOOL shouldHide;
@property (assign, nonatomic) BOOL isScrollingToTop;
@property (weak, nonatomic, readwrite) UIScrollView *scrollView;

@end

@implementation JTSScrollIndicator

#pragma mark - Public

- (instancetype)initWithScrollView:(UIScrollView *)scrollView {
    CGRect startingFrame = CGRectZero;
    self = [super initWithFrame:startingFrame];
    if (self) {
        _scrollView = scrollView;
        self.layer.cornerRadius = JTSScrollIndicator_IndicatorWidth * 0.75;
        self.clipsToBounds = YES;
        self.alpha = 0;
        _shouldHide = YES;
        JTSScrollIndicator_InherentInset = UIEdgeInsetsMake(2.5, 0, 2.5, 0);
        [scrollView addSubview:self];
        [self reset];
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

- (void)reset {
    if (self.scrollView) {
        [self setFrame:[self.class targetRectForScrollView:self.scrollView]];
        _isScrollingToTop = NO;
        _keepHidden = NO;
        _shouldHide = YES;
        [self hide:NO];
    }
}

#pragma mark - Math

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
    CGFloat frameHeightWithoutScrollIndicatorInsets = (frameHeight - indicatorInsets.top - indicatorInsets.bottom - JTSScrollIndicator_InherentInset.top);
    
    underlyingRect.size.width = JTSScrollIndicator_IndicatorWidth;
    underlyingRect.origin.x = scrollView.frame.size.width - JTSScrollIndicator_IndicatorWidth - JTSScrollIndicator_IndicatorRightMargin;
    
    CGFloat ratio = (contentHeightWithInsets != 0) ? frameHeightWithoutScrollIndicatorInsets / contentHeightWithInsets : 1.0f;
    
    underlyingRect.size.height = frameHeight * ratio;
    underlyingRect.origin.y = contentOffset.y + ((contentOffset.y+contentInset.top) * ratio) + indicatorInsets.top;
    
    if (underlyingRect.size.height < JTSScrollIndicator_MinIndicatorHeightWhenScrolling) {
        CGFloat contentHeightWithoutLastFrame = contentHeightWithInsets - frameHeight;
        CGFloat percentageScrolled = (contentOffset.y+contentInset.top) / contentHeightWithoutLastFrame;
        underlyingRect.origin.y -= (JTSScrollIndicator_MinIndicatorHeightWhenScrolling - underlyingRect.size.height) * percentageScrolled;
        underlyingRect.size.height = JTSScrollIndicator_MinIndicatorHeightWhenScrolling;
    }
    
    underlyingRect.size.height -= JTSScrollIndicator_InherentInset.top;
    underlyingRect.origin.y += JTSScrollIndicator_InherentInset.top;
    
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
     || adjustedRect.origin.y < (0-contentInset.top + indicatorInset.top) + JTSScrollIndicator_InherentInset.top) {
        CGFloat heightAdjustment = fabsf(contentInset.top - fabsf(contentOffset.y));
        adjustedRect.size.height -= heightAdjustment;
        adjustedRect.size.height = MAX(adjustedRect.size.height, JTSScrollIndicator_MinIndicatorHeightWhenCompressed);
        adjustedRect.origin.y = contentOffset.y + indicatorInset.top + JTSScrollIndicator_InherentInset.top;
    }
    else if (contentOffset.y + frameHeight > contentHeight + contentInset.bottom
        || adjustedRect.origin.y + adjustedRect.size.height > contentOffset.y + frameHeight - indicatorInset.bottom - JTSScrollIndicator_InherentInset.bottom) {
        adjustedRect.origin.y = contentHeightWithInsets - underlyingRect.size.height - indicatorInset.bottom;
        CGFloat heightAdjustment = (contentOffset.y + frameHeight) - (contentHeight + contentInset.bottom);
        adjustedRect.size.height -= heightAdjustment;
        adjustedRect.size.height = MAX(adjustedRect.size.height, JTSScrollIndicator_MinIndicatorHeightWhenCompressed);
        adjustedRect.origin.y = contentOffset.y + frameHeight - adjustedRect.size.height - indicatorInset.bottom - JTSScrollIndicator_InherentInset.bottom;
    }
    
    adjustedRect.origin.x = underlyingRect.origin.x + indicatorInset.left;
    adjustedRect.origin.x = underlyingRect.origin.x - indicatorInset.right;
    
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

#pragma mark - Scroll View Changes

#pragma mark - Required for Implementers

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (self.scrollView == nil) {
        [self setScrollView:scrollView];
    }
    
    [self setFrame:[self.class targetRectForScrollView:scrollView]];
    
    if (self.isScrollingToTop == NO && self.keepHidden == NO) {
        if ([self.class indicatorShouldBeVisibleForScrollView:scrollView]) {
            [self setShouldHide:NO immediately:YES];
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
    __weak JTSScrollIndicator *weakSelf = self;
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
    }
}

- (void)show:(BOOL)animated {
    [self setAlpha:1];
}

- (void)hide:(BOOL)animated {
    __weak JTSScrollIndicator *weakSelf = self;
    UIViewAnimationOptions options = UIViewAnimationOptionBeginFromCurrentState;
    [UIView animateWithDuration:0.33 delay:0 options:options animations:^{
        [weakSelf setAlpha:0];
    } completion:nil];
}

@end




