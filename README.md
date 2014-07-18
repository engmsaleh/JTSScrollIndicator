JTSScrollIndicator
==================

*A substitute scroll indicator for iOS UIScrollViews. Looks almost identical, but allows custom colors.*

## Usage

First, initialize a new indicator as follows:

```objc
self.indicator = [[JTSScrollIndicator alloc] initWithScrollView:self.scrollView];
```

JTSScrollIndicator inherits from `UIView`, so set a backgrond color as you like:

```objc
self.indicator.backgroundColor = [UIColor purpleColor];
```

Next comes the most important part. JTSScrollIndicator does *not* set itself as its scroll view's delegate, since this could interfere with the normal operation of existing scroll view classes. Instead, your app is responsible for forwarding appropriate messages from the existing scroll view delegate to the JTSScrollIndicator instance.

Here's all you'd need to accomplish this:

```objc
#pragma mark - Scroll View Delegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [self.indicator scrollViewDidScroll:scrollView];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    [self.indicator scrollViewDidEndDragging:scrollView willDecelerate:decelerate];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    [self.indicator scrollViewDidEndDecelerating:scrollView];
}

- (void)scrollViewWillScrollToTop:(UIScrollView *)scrollView {
    [self.indicator scrollViewWillScrollToTop:scrollView];
}

- (void)scrollViewDidScrollToTop:(UIScrollView *)scrollView {
    [self.customScrollIndicator scrollViewDidScrollToTop:scrollView];
}
```

That's it. 

## Notes

- JTSScrollIndicator only works with vertically-scrolling content. 
- JTSScrollIndicator will respect your scroll view's scrollIndicatorInsets.
