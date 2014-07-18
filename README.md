JTSScrollIndicator
==================

*A substitute scroll indicator for iOS UIScrollViews. Looks and behaves identically to the native iOS scroll indicator, but allows custom colors.*

## As Seen In

- **Unread - an RSS Reader** – Unread, both for iPhone and iPad, uses JTSScrollIndicator to allow the scroll indicator to subtly change to an appropriate color for each of the many color themes in the app.

- **Unnamed Time Zone App** _ A time zone app I'm working on. I made it look garishly yellow for the screenshot below, but you can choose any color you like.

## Screenshot

<img src="http://www.jaredsinclair.com/img/scroll-mockup.png"/>

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
    [self.indicator scrollViewDidScrollToTop:scrollView];
}
```

That's it. 

## Notes

- JTSScrollIndicator only works with vertically-scrolling content. 
- JTSScrollIndicator will respect your scroll view's scrollIndicatorInsets.
- JTSScrollIndicator does not support bordered state, though I suppose you could try simulating one with a CALayer border.
