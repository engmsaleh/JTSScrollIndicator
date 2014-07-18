//
//  JTSScrollIndicator.h
//  
//
//  Created by Jared Sinclair on 11/11/13.
//  Copyright (c) 2013 Nice Boy LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

///-----------------------------------------------------------
/// JTSScrollIndicator - Interface
///-----------------------------------------------------------

/**
 JTSScrollIndicator inherits directly from UIView. To change it's
 color, just set its `backgroundColor` property. That's it.
 
 @note Only works as a vertical scroll indicator.
 */
@interface JTSScrollIndicator : UIView

/**
 Use this to keep the indicator hidden indefinitely, if needed.
 */
@property (assign, nonatomic, readwrite) BOOL keepHidden;

/**
 The scroll view passed in the init method.
 */
@property (weak, nonatomic, readonly) UIScrollView *scrollView;

/**
 The designated initializer.
 */
- (instancetype)initWithScrollView:(UIScrollView *)scrollView;

/**
 Forces a reset if something has caused the indicator to get into 
 an inconsistent state. You shouldn't ever need this in normal
 operation.
 */
- (void)reset;

@end

///-----------------------------------------------------------
/// Implementers Must Call These Methods
///-----------------------------------------------------------
/**
 JTSScrollIndicator will not set itself as its scroll view's delegate.
 Instead, your app is responsible for forwarding the relevant scroll view
 delegate methods via these similarly-named methods below:
 */
@interface JTSScrollIndicator (ImplementersMustCallThese)

- (void)scrollViewDidScroll:(UIScrollView *)scrollView;
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate;
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView;
- (void)scrollViewWillScrollToTop:(UIScrollView *)scrollView;
- (void)scrollViewDidScrollToTop:(UIScrollView *)scrollView;

@end


