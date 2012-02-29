# Touchposé

![Touchposé with four fingers on the screen.](http://reactionsoftware.com.s3.amazonaws.com/images/Touchpos%C3%A9%20screen%20shot.png)

Touchposé is a set of classes for iOS that renders screen touches when
a device is connected to a mirrored display. Touchposé adds a
transparent overlay to your app’s UI; all touch events cause
semi-transparent circles to be rendered on the overlay--an essential
tool when demoing an app with a projector (with an iPad 2 or iPhone
4S).

To use Touchposé in your own app, copy the `QTouchposeApplication` and
`QTouchposeWindow` classes to your project.

Touchposé should work for most apps. It’s implemented by two classes:
`QTouchposeApplication`, a `UIApplication` subclass; and
`QTouchposeWindow`, a `UIWindow` subclass. `QTouchApplication`
overrides `‑sendEvent:` and is responsible for rendering touches on
the overlay view. `QTouchposeWindow` should be used as the app’s main
window; it overrides `‑didAddSubview:` and ensures that the overlay
view remains the top-most view.

To use Touchposé with an app:

- Use `UITouchposeApplication` instead of UIApplication. This is done by specifying the application class in UIApplicationMain:

        int main(int argc, char *argv[])
        {
            @autoreleasepool
            {
                return UIApplicationMain(argc, argv,
                                         NSStringFromClass([QTouchposeApplication class]),
                                         NSStringFromClass([QAppDelegate class]));
            }
        }

- Use UITouchposeWindow instead of UIWindow when creating your main window. This might be done in code (typcially ‑application:didFinishLaunchingWithOptions:), or in a nib file.

No other steps are needed. By default, touch events are only displayed
when actually connected to an external device. If you want to always
show touch events, set the alwaysShowTouches property of
QTouchposeApplication to YES.

## Known Issues

- Touchposé doesn’t work correctly with action sheets, alerts, or the
  keyboard. The issue is that these views are not added to the main
  window and end up on top of Touchposé’s overlay view thus obscuring
  the rendering of the touch events. For the keyboard, this isn’t too
  significant, because the keyboard already has a visual effect
  indicating where touches occur. I’d love to hear if there’s a way to
  get this working with alerts and action sheets.

- When Touchposé is enabled and the keyboard is displayed, the
  keyboard performance is severely impacted. Because of this,
  Touchposé is automatically disabled when the keyboard is shown and
  renabled when the keyboard is hidden.

- The finger touch views are not always removed when a touch
  ends. This appears to be caused by a bug in iOS: we don't get
  notified of all `UITouch` instances ending. See
  [here](https://discussions.apple.com/thread/1507669?start=0&tstart=0)
  for a discussion of this issue.

## License

Touchposé is licensed under the Apache License, Version 2.0.
