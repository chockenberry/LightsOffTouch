#import <UIKit/UIKit.h>
#import <UIKit/UIImage.h>
#import <UIKit/UIView-Rendering.h>

#import "LOButtonGlowView.h"

#import "LOController.h"

@implementation LOButtonGlowView


#pragma mark UIResponder

- (void)mouseDown:(GSEvent *)event;
{
    pressed = YES;
    [self setNeedsDisplay];
}

- (void)mouseUp:(GSEvent *)event;
{
    pressed = NO;
    [self setNeedsDisplay];
    
    (type == LOButtonGlowLeft) ? [[self superview] skipToPreviousLevel] : [[self superview] skipToNextLevel];
}


#pragma mark UIView

- (void)drawRect:(CGRect)rect;
{
    if (pressed) {
        static UIImage *buttonGlowImage;
        if (!buttonGlowImage)
            buttonGlowImage = [[UIImage applicationImageNamed:@"lo-glowpress.png"] retain];
        [buttonGlowImage draw1PartImageInRect:rect];
    }
}


#pragma mark API

- (void)setButtonType:(LOButtonGlowType)buttonType;
{
    type = buttonType;
}

@end
