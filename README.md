# Touchposé

![Touchposé with four fingers on the screen.](http://reactionsoftware.com.s3.amazonaws.com/images/Touchpos%C3%A9%20screen%20shot.png)

Touchposé is a set of classes for iOS that renders screen touches when
a device is connected to a mirrored display. Touchposé adds a
transparent overlay to your app’s UI; all touch events cause
semi-transparent circles to be rendered on the overlay--an essential
tool when demoing an app with a projector (with an iPad 2 or iPhone
4S).

To use Touchposé in your own app, copy the `QTouchposeApplication`
class to your project.

Touchposé should work for most apps. It’s implemented by a single
class: `QTouchposeApplication`, a `UIApplication` subclass which
overrides `‑sendEvent:` and is responsible for rendering touches on
the overlay view.

To use Touchposé with an app:

- Use `QTouchposeApplication` instead of UIApplication. This is done by specifying the application class in UIApplicationMain:

        int main(int argc, char *argv[])
        {
            @autoreleasepool
            {
                return UIApplicationMain(argc, argv,
                                         NSStringFromClass([QTouchposeApplication class]),
                                         NSStringFromClass([QAppDelegate class]));
            }
        }

No other steps are needed. By default, touch events are only displayed
when actually connected to an external device. If you want to always
show touch events, set the alwaysShowTouches property of
QTouchposeApplication to YES.

## Known Issues

- When Touchposé is enabled and the keyboard is displayed, the
  keyboard performance is severely impacted. Because of this,
  Touchposé is automatically disabled when the keyboard is shown and
  renabled when the keyboard is hidden.

- The finger touch views are not always removed when a touch
  ends. This appears to be caused by a bug in iOS: we don't get
  notified of all `UITouch` instances ending. See
  [here](https://discussions.apple.com/thread/1507669?start=0&tstart=0)
  for a discussion of this issue. I haven't investigated this issue
  extensively—it may only occur on versions of iOS prior to 5.

## License

Touchposé is licensed under the Apache License, Version 2.0.
