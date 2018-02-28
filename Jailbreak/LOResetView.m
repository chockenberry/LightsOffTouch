#import <UIKit/UIKit.h>
#import <UIKit/UIImage.h>
#import <UIKit/UIView-Geometry.h>
#import <UIKit/UIView-Rendering.h>

#import "LOResetView.h"

#import "LOController.h"

@implementation LOResetView


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
    
    [[self superview] reset];
}

#pragma mark UIView

- (void)drawRect:(CGRect)rect;
{
    if (!pressed) {
        static UIImage *resetImage;
        if (!resetImage)
            resetImage = [[UIImage applicationImageNamed:@"lo-button-reset.png"] retain];
        [resetImage draw1PartImageInRect:rect];
    } else {
        static UIImage *resetPressedImage;
        if (!resetPressedImage)
            resetPressedImage = [[UIImage applicationImageNamed:@"lo-button-reset-press.png"] retain];
        [resetPressedImage draw1PartImageInRect:rect];
    }
}

@end
