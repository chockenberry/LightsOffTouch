#import <UIKit/UIKit.h>
#import <UIKit/UIImage.h>
#import <UIKit/UIView-Geometry.h>
#import <UIKit/UIView-Rendering.h>

#import "LODoneButtonView.h"

#import "LOController.h"
#import "LOView.h"

@implementation LODoneButtonView


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
    
    [[[self superview] superview] hideInfo];
}

#pragma mark UIView

- (void)drawRect:(CGRect)rect;
{
    if (!pressed) {
        static UIImage *doneButtonImage;
        if (!doneButtonImage)
            doneButtonImage = [[UIImage applicationImageNamed:@"lo-button-done.png"] retain];
        [doneButtonImage draw1PartImageInRect:rect];
    } else {
        static UIImage *doneButtonPressedImage;
        if (!doneButtonPressedImage)
            doneButtonPressedImage = [[UIImage applicationImageNamed:@"lo-button-done-press.png"] retain];
        [doneButtonPressedImage draw1PartImageInRect:rect];
    }
}

@end
