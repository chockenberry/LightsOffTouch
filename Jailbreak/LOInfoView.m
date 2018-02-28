#import <UIKit/UIKit.h>
#import <UIKit/UIImage.h>
#import <UIKit/UIView-Geometry.h>
#import <UIKit/UIView-Rendering.h>

#import "LOInfoView.h"

#import "LOController.h"

@implementation LOInfoView

#pragma mark UIView

- (void)drawRect:(CGRect)rect;
{
    static UIImage *infoImage;
    if (!infoImage)
        infoImage = [[UIImage applicationImageNamed:@"lo-background-info.png"] retain];
    [infoImage draw1PartImageInRect:rect];
}

@end
