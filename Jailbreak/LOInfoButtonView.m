#import <UIKit/UIKit.h>
#import <UIKit/UIImage.h>
#import <UIKit/UIView-Geometry.h>
#import <UIKit/UIView-Rendering.h>

#import "LOInfoButtonView.h"

#import "LOController.h"
#import "LOView.h"

@implementation LOInfoButtonView


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
    
    [[self superview] showInfo];
}

#pragma mark UIView

- (void)drawRect:(CGRect)rect;
{
    if (!pressed) {
        static UIImage *infoButtonImage;
        if (!infoButtonImage)
            infoButtonImage = [[UIImage applicationImageNamed:@"lo-button-info.png"] retain];
        [infoButtonImage draw1PartImageInRect:rect];
    } else {
        static UIImage *infoButtonPressedImage;
        if (!infoButtonPressedImage)
            infoButtonPressedImage = [[UIImage applicationImageNamed:@"lo-button-info-press.png"] retain];
        [infoButtonPressedImage draw1PartImageInRect:rect];
    }
}

@end
