
#import "LOView.h"

//#import "LOController.h"
#import "LightsOffTouchAppDelegate.h"
#import "LOButtonView.h"
#import "LOButtonGlowView.h"
//#import "LOHighlightView.h"
#import "LOInfoButtonView.h"
#import "LOInfoView.h"
#import "LODoneButtonView.h"
#import "LOResetView.h"

@implementation LOView

#pragma mark NSObject

- (void)dealloc;
{
    [buttonNamesToViews release];
    [super dealloc];
}


#pragma mark UIResponder

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    // unpress all buttons?
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    // unpress all buttons?
}


#pragma mark UIView

- (void)drawRect:(CGRect)rect;
{
    static UIImage *backgroundImage;
    if (!backgroundImage)
        backgroundImage = [[UIImage imageNamed:@"lo-background.png"] retain];
    
    [backgroundImage drawInRect:rect];
	
    [levelTextLabel setText:[controller currentLevelString]];
}


#pragma mark API

- (id)initWithFrame:(CGRect)frame controller:(LightsOffTouchAppDelegate *)viewController;
{
	if (![super initWithFrame:frame])
        return nil;
	
    controller = viewController; // non-retained
    
    buttonNamesToViews = [[NSMutableDictionary alloc] init];
    
    UIColor *clearColor = [UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:0.0];
	[self setBackgroundColor:[UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:1.0]];
    
#define MATRIX_DISTANCE_FROM_BOTTOM (56.0)
	unsigned int rowIndex, columnIndex;
    for (rowIndex = 0; rowIndex < ROW_COUNT; rowIndex++) {
        for (columnIndex = 0; columnIndex < COLUMN_COUNT; columnIndex++) {
            LOButtonView *buttonView = [[[LOButtonView alloc] initWithFrame:CGRectOffset(CGRectMake(rowIndex * 64.0, columnIndex * 64.0, 63.0, 57.0), 0.0, MATRIX_DISTANCE_FROM_BOTTOM)] autorelease];
// TODO:            [buttonView setClipsSubviews:NO]; // make sure the highlight can extend (doesn't actually work)
            //[[buttonView _layer] setMasksToBounds:NO]; // this doesn't work either
            [buttonView setBackgroundColor:clearColor];
            [buttonNamesToViews setObject:buttonView forKey:[NSString stringWithFormat:@"button%d", (columnIndex * ROW_COUNT) + (rowIndex + 1)]];
            [buttonView setLightOn:NO];
            [self addSubview:buttonView];
        }
    }
    
    // add glowing logo
    UIImageView *glowingLogoView = [[[UIImageView alloc] initWithFrame:CGRectMake(17.0, 0.0, 285.0, 50.0)] autorelease];
    [glowingLogoView setImage:[UIImage imageNamed:@"lo-logoglow.png"]];
    [self addSubview:glowingLogoView];
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationRepeatCount:1e7];
    [UIView setAnimationDuration:3.0];
    [UIView setAnimationRepeatAutoreverses:YES];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut]; {
        [glowingLogoView setAlpha:0.0];
    } [UIView commitAnimations];
    
    // add info button
    LOInfoButtonView *infoButton = [[[LOInfoButtonView alloc] initWithFrame:CGRectMake(226.0, 387.0, 76.0, 24.0)] autorelease];
    [infoButton setBackgroundColor:clearColor];
    [self addSubview:infoButton];
    
    // add reset button
    LOResetView *resetButton = [[[LOResetView alloc] initWithFrame:CGRectMake(226.0, 422.0, 76.0, 24.0)] autorelease];
    [resetButton setBackgroundColor:clearColor];
    [self addSubview:resetButton];
    
    // add level skip buttons
    LOButtonGlowView *leftButtonGlow = [[[LOButtonGlowView alloc] initWithFrame:CGRectMake(40.0, 410.0, 40.0, 40.0)] autorelease];
    [leftButtonGlow setButtonType:LOButtonGlowLeft];
    [leftButtonGlow setBackgroundColor:clearColor];
    [self addSubview:leftButtonGlow];
    LOButtonGlowView *rightButtonGlow = [[[LOButtonGlowView alloc] initWithFrame:CGRectMake(112.0, 411.0, 40.0, 40.0)] autorelease];
    [rightButtonGlow setButtonType:LOButtonGlowRight];
    [rightButtonGlow setBackgroundColor:clearColor];
    [self addSubview:rightButtonGlow];
    
    // add the level text
    levelTextLabel = [[[UILabel alloc] initWithFrame:CGRectMake(54.0, 390.0, 84.0, 22.0)] autorelease]; // non-retained
    [levelTextLabel setTextColor:[UIColor colorWithRed:(242.0 / 255.0) green:(84.0 / 255.0) blue:(83.0 / 255.0) alpha:1.0]];
    [levelTextLabel setBackgroundColor:clearColor];
    [levelTextLabel setShadowColor:[UIColor colorWithRed:(205.0 / 255.0) green:(33.0 / 255.0) blue:(31.0 / 255.0) alpha:1.0]];
    [levelTextLabel setShadowOffset:CGSizeMake(1.0, 1.0)];
    [levelTextLabel setTextAlignment:NSTextAlignmentCenter];
    [self addSubview:levelTextLabel];
    
    // add hidden info window
    infoView = [[[LOInfoView alloc] initWithFrame:CGRectOffset([self bounds], 0.0, -CGRectGetHeight([self bounds]))] autorelease]; // non-retained
    [self addSubview:infoView];
    
    // add done button to info window
    LODoneButtonView *doneButtonView = [[[LODoneButtonView alloc] initWithFrame:CGRectMake(125.0, 420.0, 76.0, 24.0)] autorelease];
    [doneButtonView setBackgroundColor:clearColor];
    [infoView addSubview:doneButtonView];
    
	return self;
}

- (NSDictionary *)buttonNamesToViews;
{
    return buttonNamesToViews;
}

- (void)pressButtonView:(LOButtonView *)buttonView;
{
    // unpress all other buttons...
    NSEnumerator *buttonEnumerator = [buttonNamesToViews objectEnumerator];
    LOButtonView *currentButtonView = nil;
    while ((currentButtonView = [buttonEnumerator nextObject]))
        if (currentButtonView != buttonView && [currentButtonView isPressed])
            [currentButtonView setPressed:NO];
    
    // send on to the controller for game logic
    [controller pressButtonView:buttonView]; 
}

- (void)showInfo;
{
    [UIView beginAnimations:nil context:NULL]; {
        [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
        [UIView setAnimationDuration:0.75];
        [infoView setFrame:[self bounds]];
    } [UIView commitAnimations];
}

- (void)hideInfo;
{
    [UIView beginAnimations:nil context:NULL]; {
        [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
        [UIView setAnimationDuration:0.75];
        [infoView setFrame:CGRectOffset([self bounds], 0.0, -CGRectGetHeight([self bounds]))];
    } [UIView commitAnimations];
}

- (void)reset;
{
    [controller reset];
}

- (void)skipToNextLevel;
{
    if ([controller isAcceptingInput])
        [controller skipToNextLevel];
}

- (void)skipToPreviousLevel;
{
    if ([controller isAcceptingInput])
        [controller skipToPreviousLevel];
}

@end
