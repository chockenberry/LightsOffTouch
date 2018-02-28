#import <UIKit/UIKit.h>
#import <UIKit/UIImage.h>
#import <UIKit/UIView-Geometry.h>
#import <UIKit/UIView-Rendering.h>

#import "LOButtonView.h"

#import "LOController.h"
#import "LOView.h"

@implementation LOButtonView

#pragma mark UIView

- (void)drawRect:(CGRect)rect;
{
    if (!pressed) {
        static UIImage *buttonOffImage;
        if (!buttonOffImage)
            buttonOffImage = [[UIImage applicationImageNamed:@"lo-button-off.png"] retain];
        [buttonOffImage draw1PartImageInRect:rect];
        
        if (lightOn) {
            static UIImage *buttonGlowImage;
            if (!buttonGlowImage)
                buttonGlowImage = [[UIImage applicationImageNamed:@"lo-button-fullglow.png"] retain];
            [buttonGlowImage draw1PartImageInRect:CGRectInset(rect, -8.0, -10.0)];
        }
    } else {
        if (!lightOn) {
            static UIImage *buttonPressedImage;
            if (!buttonPressedImage)
                buttonPressedImage = [[UIImage applicationImageNamed:@"lo-button-press.png"] retain];
            [buttonPressedImage draw1PartImageInRect:rect];
        } else {
            static UIImage *buttonOnPressedImage;
            if (!buttonOnPressedImage)
                buttonOnPressedImage = [[UIImage applicationImageNamed:@"lo-button-on-press.png"] retain];
            [buttonOnPressedImage draw1PartImageInRect:rect];
        }
    }
}


#pragma mark UIResponder

- (void)mouseDown:(GSEvent *)event;
{
    [self setPressed:YES];
}

- (void)mouseUp:(GSEvent *)event;
{
    [self setPressed:NO];
    [(LOView *)[self superview] pressButtonView:self];
}


#pragma mark API

- (void)setLightOn:(BOOL)isOn;
{
    lightOn = isOn;
    [self setNeedsDisplay];
}

- (BOOL)isLightOn;
{
    return lightOn;
}

- (void)setPressed:(BOOL)isPressed;
{
    pressed = isPressed;
    [self setNeedsDisplay];
}

- (BOOL)isPressed;
{
    return pressed;
}

@end
