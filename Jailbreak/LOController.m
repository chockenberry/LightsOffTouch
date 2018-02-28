#import <UIKit/UIKit.h>
#import <UIKit/UIAlphaAnimation.h>
#import <UIKit/UIView.h>
#import <UIKit/UIView-Animation.h>
#import <UIKit/UIView-Geometry.h>
#import <UIKit/UIView-Rendering.h>
#import <UIKit/UIHardware.h>
#import <UIKit/UIWindow.h>

#import <LayerKit/LKLayer.h>

#import "LOController.h"

#import "LOButtonView.h"
#import "LOGlareView.h"
#import "LOHighlightView.h"
#import "LOView.h"

#pragma mark -

@implementation UIView(Color)

- (CGColorRef)colorWithRed:(float)red green:(float)green blue:(float)blue alpha:(float)alpha;
{
	float rgba[4];
	rgba[0] = red;
	rgba[1] = green;
	rgba[2] = blue;
	rgba[3] = alpha;
	CGColorRef color = (CGColorRef)[(id)CGColorCreate((CGColorSpaceRef)[(id)CGColorSpaceCreateDeviceRGB() autorelease], rgba) autorelease];
	return color;
}

@end

#pragma mark -

@interface LOController (Private)
- (void)_executeLightSequence:(unsigned int *)lightSequence count:(unsigned int)count delayBetweenLights:(NSTimeInterval)lightDelay totalDelay:(NSTimeInterval *)totalDelay;
- (void)_setCurrentLevelString:(NSString *)string;
- (void)_setUpNextLevel;
- (void)_showLightFlourishWithTotalDelay:(NSTimeInterval *)totalDelay;
- (void)_showWinFlourishAndSetUpNextLevel;
- (void)_toggleButtonView:(LOButtonView *)buttonView;
- (void)_turnOffAllLights;
@end

#pragma mark -

@implementation LOController


#pragma mark NSObject

- (void)dealloc;
{
    [window release];
    [view release];
    [super dealloc];
}

- (void)awakeFromNib;
{
}

#pragma mark UIApplication

- (void)applicationDidFinishLaunching:(NSNotification *)notification;
{
    puzzles = [[[[NSDictionary dictionaryWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"puzzles" ofType:@"plist"]] allValues] lastObject] retain];
    
	window = [[UIWindow alloc] initWithContentRect:[UIHardware fullScreenApplicationContentRect]];
    view = [[LOView alloc] initWithFrame:[window bounds] controller:self];
    [window setContentView:view];
	[window orderFront:self];
	[window makeKey:self];
    
    NSTimeInterval totalDelay;
    [self _showLightFlourishWithTotalDelay:&totalDelay];
    [self performSelector:@selector(_setUpNextLevel) withObject:nil afterDelay:totalDelay];
}

- (void)applicationWillTerminate:(NSNotification *)notification;
{
    [puzzles release];
}


#pragma mark API

- (BOOL)isAcceptingInput;
{
    return isAcceptingInput;
}

- (NSString *)currentLevelString;
{
    return currentLevelString;
}

- (void)pressButtonView:(LOButtonView *)buttonView;
{
    if (!isAcceptingInput)
        return;
    
    NSString *buttonName = [[[view buttonNamesToViews] allKeysForObject:buttonView] lastObject];
    
    // do the Lights Out! logic
    [self _toggleButtonView:buttonView];
    unsigned int buttonNumber = [[buttonName substringFromIndex:[@"button" length]] intValue];
    if ((buttonNumber % ROW_COUNT) != 1) // left
        [self _toggleButtonView:[[view buttonNamesToViews] objectForKey:[NSString stringWithFormat:@"button%d", (buttonNumber - 1)]]];
    if ((buttonNumber % ROW_COUNT) != 0) // right
        [self _toggleButtonView:[[view buttonNamesToViews] objectForKey:[NSString stringWithFormat:@"button%d", (buttonNumber + 1)]]];
    if (buttonNumber > ROW_COUNT) // up if > 5
        [self _toggleButtonView:[[view buttonNamesToViews] objectForKey:[NSString stringWithFormat:@"button%d", (buttonNumber - ROW_COUNT)]]];
    if (buttonNumber <= (ROW_COUNT * COLUMN_COUNT) - ROW_COUNT) // down if <= 20
        [self _toggleButtonView:[[view buttonNamesToViews] objectForKey:[NSString stringWithFormat:@"button%d", (buttonNumber + ROW_COUNT)]]];
    
    // show the glare if the button is being lit
    static UIImage *glareImage;
    if (!glareImage)
        glareImage = [[UIImage applicationImageNamed:@"lo-button-glare"] retain];
    
    // show glare and add fade animation
    CGPoint buttonCenter = [buttonView frame].origin;
    buttonCenter.x -= CGRectGetWidth([buttonView frame]) - 8.0;
    buttonCenter.y -= (CGRectGetHeight([buttonView frame]) / 2.0) + 40.0;
    LOGlareView *glareView = [[[LOGlareView alloc] initWithFrame:(CGRect){buttonCenter, {175.0, 175.0}}] autorelease];
    [glareView setBackgroundColor:[glareView colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.0]];
    [view addSubview:glareView];
#define GLARE_FADE_ANIMATION (0.4)
    [UIView beginAnimations:nil];
    [UIView setAnimationDuration:GLARE_FADE_ANIMATION]; {
        [glareView setAlpha:0.0];
    } [UIView endAnimations];
    [glareView performSelector:@selector(removeFromSuperview) withObject:nil afterDelay:GLARE_FADE_ANIMATION];
    
    // check for a win
    BOOL didWin = YES;
    NSEnumerator *buttonEnumerator = [[view buttonNamesToViews] objectEnumerator];
    LOButtonView *currentButtonView = nil;
    while ((currentButtonView = [buttonEnumerator nextObject]))
        didWin &= ![currentButtonView isLightOn];
    if (didWin) {
        [self _setCurrentLevelString:@"Nice!"];
        [self _showWinFlourishAndSetUpNextLevel];
    }
}

- (void)reset;
{
    isAcceptingInput = NO;
    [self _turnOffAllLights];
    currentLevel--;
    NSTimeInterval totalDelay;
    [self _showLightFlourishWithTotalDelay:&totalDelay];
    [self performSelector:@selector(_setUpNextLevel) withObject:nil afterDelay:totalDelay];
}

- (void)skipToNextLevel;
{
    isAcceptingInput = NO;
    [self _turnOffAllLights];
    NSTimeInterval totalDelay;
    [self _showLightFlourishWithTotalDelay:&totalDelay];
    [self performSelector:@selector(_setUpNextLevel) withObject:nil afterDelay:totalDelay];
}

- (void)skipToPreviousLevel;
{
    isAcceptingInput = NO;
    [self _turnOffAllLights];
    currentLevel -= 2;
    NSTimeInterval totalDelay;
    [self _showLightFlourishWithTotalDelay:&totalDelay];
    [self performSelector:@selector(_setUpNextLevel) withObject:nil afterDelay:totalDelay];
}

#pragma mark Private API

- (void)_executeLightSequence:(unsigned int *)lightSequence count:(unsigned int)count delayBetweenLights:(NSTimeInterval)lightDelay totalDelay:(NSTimeInterval *)totalDelay;
{
    NSTimeInterval currentDelay = 0.0;
    unsigned int lightIndex = 0;
    while (lightIndex < count) {
        LOButtonView *buttonView = [[view buttonNamesToViews] objectForKey:[NSString stringWithFormat:@"button%d", lightSequence[lightIndex++]]];
        [self performSelector:@selector(_toggleButtonView:) withObject:buttonView afterDelay:currentDelay];
        currentDelay += lightDelay;
        [self performSelector:@selector(_toggleButtonView:) withObject:buttonView afterDelay:currentDelay];
    }
    currentDelay += lightDelay;
    if (totalDelay)
        *totalDelay = currentDelay;
}

- (void)_setCurrentLevelString:(NSString *)string;
{
    [currentLevelString autorelease];
    currentLevelString = [string retain];
    [view setNeedsDisplay];
}

- (void)_setUpNextLevel;
{
    unsigned int levelCount = [puzzles count];
    if ((currentLevel + 1) > levelCount)
        currentLevel = 0;
    else if (currentLevel < 1)
        currentLevel = 0;
    
    NSString *layoutString = [puzzles objectAtIndex:currentLevel++];
    unsigned int indexInLayoutString = 0, rowIndex, columnIndex;
    for (rowIndex = 0; rowIndex < ROW_COUNT; rowIndex++) {
        for (columnIndex = 0; columnIndex < COLUMN_COUNT; columnIndex++) {
            unichar layoutCharacter = [layoutString characterAtIndex:indexInLayoutString++];
            if (layoutCharacter == 'x')
                [self _toggleButtonView:[[view buttonNamesToViews] objectForKey:[NSString stringWithFormat:@"button%d", (((ROW_COUNT - 1) - rowIndex) * ROW_COUNT) + (columnIndex + 1)]]];
        }
        
        // skip divider
        indexInLayoutString++;
    }
    
    [self _setCurrentLevelString:[NSString stringWithFormat:@"%d", currentLevel]];
    
    isAcceptingInput = YES;
}

- (void)_showLightFlourishWithTotalDelay:(NSTimeInterval *)totalDelay;
{
    isAcceptingInput = NO;
    
    NSTimeInterval lightDelay = 0.0;
    unsigned int rowIndex, columnIndex;
    
    // up lit
    for (rowIndex = 0; rowIndex < ROW_COUNT; rowIndex++) {
        for (columnIndex = 0; columnIndex < COLUMN_COUNT; columnIndex++) {
            [self performSelector:@selector(_toggleButtonView:) withObject:[[view buttonNamesToViews] objectForKey:[NSString stringWithFormat:@"button%d", (rowIndex * ROW_COUNT) + (columnIndex + 1)]] afterDelay:lightDelay];
        }
        lightDelay += 0.05;
    }
    
    // up dark
    for (rowIndex = 0; rowIndex < ROW_COUNT; rowIndex++) {
        for (columnIndex = 0; columnIndex < COLUMN_COUNT; columnIndex++) {
            [self performSelector:@selector(_toggleButtonView:) withObject:[[view buttonNamesToViews] objectForKey:[NSString stringWithFormat:@"button%d", (rowIndex * ROW_COUNT) + (columnIndex + 1)]] afterDelay:lightDelay];
        }
        lightDelay += 0.05;
    }
    
    // left lit
    for (columnIndex = 0; columnIndex < COLUMN_COUNT; columnIndex++) {
        for (rowIndex = 0; rowIndex < ROW_COUNT; rowIndex++) {
            [self performSelector:@selector(_toggleButtonView:) withObject:[[view buttonNamesToViews] objectForKey:[NSString stringWithFormat:@"button%d", (rowIndex * ROW_COUNT) + (columnIndex + 1)]] afterDelay:lightDelay];
        }
        lightDelay += 0.05;
    }
    
    // left dark
    for (columnIndex = 0; columnIndex < COLUMN_COUNT; columnIndex++) {
        for (rowIndex = 0; rowIndex < ROW_COUNT; rowIndex++) {
            [self performSelector:@selector(_toggleButtonView:) withObject:[[view buttonNamesToViews] objectForKey:[NSString stringWithFormat:@"button%d", (rowIndex * ROW_COUNT) + (columnIndex + 1)]] afterDelay:lightDelay];
        }
        lightDelay += 0.05;
    }
    
    // one by one lit
    NSTimeInterval previousDelay = lightDelay;
    for (columnIndex = 0; columnIndex < COLUMN_COUNT; columnIndex++) {
        for (rowIndex = 0; rowIndex < ROW_COUNT; rowIndex++) {
            [self performSelector:@selector(_toggleButtonView:) withObject:[[view buttonNamesToViews] objectForKey:[NSString stringWithFormat:@"button%d", (rowIndex * ROW_COUNT) + (columnIndex + 1)]] afterDelay:lightDelay];
            lightDelay += 0.05;
        }
    }
    lightDelay = previousDelay + 0.05;
    for (columnIndex = 0; columnIndex < COLUMN_COUNT; columnIndex++) {
        for (rowIndex = 0; rowIndex < ROW_COUNT; rowIndex++) {
            [self performSelector:@selector(_toggleButtonView:) withObject:[[view buttonNamesToViews] objectForKey:[NSString stringWithFormat:@"button%d", (rowIndex * ROW_COUNT) + (columnIndex + 1)]] afterDelay:lightDelay];
            lightDelay += 0.05;
        }
    }
    
    if (totalDelay)
        *totalDelay = lightDelay;
}

- (void)_showWinFlourishAndSetUpNextLevel;
{
    isAcceptingInput = NO;
    
    // spiral sequence
    static unsigned int winLightSequence[] = {1, 6, 11, 16, 21, 22, 23, 24, 25, 20, 15, 10, 5, 4, 3, 2, 7, 12, 17, 18, 19, 14, 9, 8, 7, 12, 13};
    NSTimeInterval winLightSequenceDelay;
    [self _executeLightSequence:winLightSequence count:(sizeof(winLightSequence) / sizeof(*winLightSequence)) delayBetweenLights:0.03 totalDelay:&winLightSequenceDelay];
    [self performSelector:@selector(_setUpNextLevel) withObject:nil afterDelay:winLightSequenceDelay];
}

- (void)_toggleButtonView:(LOButtonView *)buttonView;
{
    [buttonView setLightOn:![buttonView isLightOn]];
}

- (void)_turnOffAllLights;
{
    NSEnumerator *buttonEnumerator = [[view buttonNamesToViews] objectEnumerator];
    LOButtonView *currentButtonView = nil;
    while ((currentButtonView = [buttonEnumerator nextObject]))
        if ([currentButtonView isLightOn])
            [currentButtonView setLightOn:NO];
}

@end
