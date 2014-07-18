//
//  UNRCustomScrollIndicator.h
//  unread
//
//  Created by Jared Sinclair on 11/11/13.
//  Copyright (c) 2013 Nice Boy LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UNRCustomScrollIndicator : UIView

@property (assign, nonatomic) BOOL keepHidden;

- (void)reset;
- (void)scrollViewDidScroll:(UIScrollView *)scrollView;
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate;
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView;
- (void)scrollViewWillScrollToTop:(UIScrollView *)scrollView;
- (void)scrollViewDidScrollToTop:(UIScrollView *)scrollView;

@end
