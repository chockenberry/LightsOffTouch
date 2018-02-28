#import <UIKit/UIKit.h>
#import <UIKit/UIImage.h>
#import <UIKit/UIView-Geometry.h>
#import <UIKit/UIView-Rendering.h>

#import "LOHighlightView.h"

#import "LOButtonView.h"
#import "LOController.h"

@implementation LOHighlightView

#pragma mark API

- (id)initWithFrame:(CGRect)frame buttonView:(LOButtonView *)button;
{
    if (![super initWithFrame:frame])
        return nil;
    buttonView = button; // non-retained
    return self;
}


#pragma mark UIResponder

// pass the events though
- (void)mouseDown:(GSEvent *)event;
{ [buttonView mouseDown:event]; }
- (void)mouseUp:(GSEvent *)event;
{ [buttonView mouseUp:event]; }


#pragma mark UIView

- (void)drawRect:(CGRect)rect;
{
    static UIImage *buttonGlowImage;
    if (!buttonGlowImage)
        buttonGlowImage = [[UIImage applicationImageNamed:@"lo-button-fullglow.png"] retain];
    [buttonGlowImage draw1PartImageInRect:rect];
}

@end
