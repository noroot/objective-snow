#import <Cocoa/Cocoa.h>
#import <QuartzCore/QuartzCore.h>

@interface SnowOverlayView : NSView
@property (nonatomic, strong) NSMutableArray *snowflakes;
@property (nonatomic, strong) NSTimer *timer;
@end

@implementation SnowOverlayView

- (instancetype)initWithFrame:(NSRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.snowflakes = [NSMutableArray array];
        [self generateSnowflakes];
        self.timer = [NSTimer scheduledTimerWithTimeInterval:0.029
                                                      target:self
                                                    selector:@selector(updateSnowflakes)
                                                    userInfo:nil
                                                     repeats:YES];
        self.wantsLayer = YES;
        self.layer.backgroundColor = [[NSColor clearColor] CGColor];
    }
    return self;
}

- (void)generateSnowflakes {
    for (int i = 0; i < 2000; i++) {
        NSRect snowflake = NSMakeRect(arc4random_uniform(self.bounds.size.width),
                                      arc4random_uniform(self.bounds.size.height),
                                      arc4random_uniform(4) + 2,
                                      arc4random_uniform(4) + 2);
        [self.snowflakes addObject:[NSValue valueWithRect:snowflake]];
    }
}

- (void)updateSnowflakes {
    for (NSInteger i = 0; i < self.snowflakes.count; i++) {
        NSRect snowflake = [self.snowflakes[i] rectValue];
        snowflake.origin.y -= arc4random_uniform(3) + 1;

        if (snowflake.origin.y < 0) {
            snowflake.origin.y = self.bounds.size.height;
            snowflake.origin.x = arc4random_uniform(self.bounds.size.width);
        }

        self.snowflakes[i] = [NSValue valueWithRect:snowflake];
    }
    [self setNeedsDisplay:YES];
}

- (void)drawRect:(NSRect)dirtyRect {
    [[NSColor clearColor] setFill];
    NSRectFill(self.bounds);

    [[NSColor whiteColor] setFill];
    for (NSValue *value in self.snowflakes) {
        NSRect snowflake = [value rectValue];
        NSBezierPath *circle = [NSBezierPath bezierPathWithOvalInRect:snowflake];
        [circle fill];
    }
}

@end

@interface AppDelegate : NSObject <NSApplicationDelegate>
@property (nonatomic, strong) NSWindow *overlayWindow;
@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)notification {
    NSScreen *mainScreen = [NSScreen mainScreen];
    NSRect screenFrame = mainScreen.frame;

    // Create a borderless, transparent window that stays on top of all other windows
    self.overlayWindow = [[NSWindow alloc] initWithContentRect:screenFrame
                                                     styleMask:NSWindowStyleMaskBorderless
                                                       backing:NSBackingStoreBuffered
                                                         defer:NO];
    self.overlayWindow.backgroundColor = [NSColor clearColor];
    self.overlayWindow.opaque = NO;
    self.overlayWindow.level = NSFloatingWindowLevel; // Stay above all windows
    self.overlayWindow.ignoresMouseEvents = YES; // Allow mouse interactions with underlying windows

    // Add the snow overlay view
    SnowOverlayView *snowView = [[SnowOverlayView alloc] initWithFrame:screenFrame];
    [self.overlayWindow setContentView:snowView];

    // Show the overlay window
    [self.overlayWindow makeKeyAndOrderFront:nil];
}

@end

int main(int argc, const char *argv[]) {
    @autoreleasepool {
        NSApplication *app = [NSApplication sharedApplication];
        AppDelegate *delegate = [[AppDelegate alloc] init];
        app.delegate = delegate;
        [app run];
    }
    return 0;
}

