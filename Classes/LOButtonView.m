
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
            buttonOffImage = [[UIImage imageNamed:@"lo-button-off.png"] retain];
        [buttonOffImage drawInRect:rect];
        
        if (lightOn) {
            static UIImage *buttonGlowImage;
            if (!buttonGlowImage)
                buttonGlowImage = [[UIImage imageNamed:@"lo-button-fullglow.png"] retain];
            [buttonGlowImage drawInRect:CGRectInset(rect, -8.0, -10.0)];
        }
    } else {
        if (!lightOn) {
            static UIImage *buttonPressedImage;
            if (!buttonPressedImage)
                buttonPressedImage = [[UIImage imageNamed:@"lo-button-press.png"] retain];
            [buttonPressedImage drawInRect:rect];
        } else {
            static UIImage *buttonOnPressedImage;
            if (!buttonOnPressedImage)
                buttonOnPressedImage = [[UIImage imageNamed:@"lo-button-on-press.png"] retain];
            [buttonOnPressedImage drawInRect:rect];
        }
    }
}


#pragma mark UIResponder

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self setPressed:YES];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
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
