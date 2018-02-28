//
//  LightsOffTouchAppDelegate.m
//  LightsOffTouch
//
//  Created by Craig Hockenberry on 6/6/08.
//  Copyright The Iconfactory 2008. All rights reserved.
//

#import "LightsOffTouchAppDelegate.h"

#import "LOButtonView.h"
#import "LOGlareView.h"
#import "LOHighlightView.h"
#import "LOView.h"

@interface LightsOffTouchAppDelegate (Private)
- (void)_executeLightSequence:(unsigned int *)lightSequence count:(unsigned int)count delayBetweenLights:(NSTimeInterval)lightDelay totalDelay:(NSTimeInterval *)totalDelay;
- (void)_setCurrentLevelString:(NSString *)string;
- (void)_setUpNextLevel;
- (void)_showLightFlourishWithTotalDelay:(NSTimeInterval *)totalDelay;
- (void)_showWinFlourishAndSetUpNextLevel;
- (void)_toggleButtonView:(LOButtonView *)buttonView;
- (void)_turnOffAllLights;
@end

@implementation LightsOffTouchAppDelegate

/*
 During the Jailbreak era, no one had any idea what they were doing. The original LOController is reinterpreted here
 as both an application delegate and a view controller. See what I mean?
 
 The window and view hierarchy is simple, yet many changes were needed to adapt this code to the a more modern environment.
 For example, windows are now required to have a root view controller (the one here does nothing except host the LOView.)
 I've also added a simulated status bar that mimics how the views were managed prior to iOS 7 and the fullscreenification.
 
 I've also tried to follow coding conventions from the original code. Remember that back in 2007, there were no things like
 Objective-C properties and hard coding constants using #defines was de rigueur. It's also fun to look back fondly on the
 joys of retain and release.
 
 And who needs NIB files, much less storyboards and segues?
 
 Anyway, enjoy this look at the past and remember, this is NOT how you should do things now :-)
 */

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{	
    puzzles = [[[[NSDictionary dictionaryWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"puzzles" ofType:@"plist"]] allValues] lastObject] retain];
	
	NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
	currentLevel = [userDefaults integerForKey:@"currentLevel"];

#define STATUS_BAR_HEIGHT (20.0)

	CGRect bounds = [[UIScreen mainScreen] bounds];
	CGRect frame = bounds;
	frame.origin.y += STATUS_BAR_HEIGHT;
	frame.size.height -= STATUS_BAR_HEIGHT;
	
	window = [[UIWindow alloc] initWithFrame:bounds];
	view = [[LOView alloc] initWithFrame:frame controller:self];
	
	// a root view controller on the window is now a requirement after the app is launched
	UIViewController *viewController = [[[UIViewController alloc] init] autorelease];
	viewController.view = view;
	[window setRootViewController:viewController];

	[window makeKeyAndVisible];
	
	// to look a little less ridiculous on the iPhone X, simulate the old school status bar from early (non-fullscreen) versions of iOS
	[view setFrame:frame];
	UIView *statusBarView = [[[UIView alloc] initWithFrame:CGRectMake(0, 0, bounds.size.width, STATUS_BAR_HEIGHT)] autorelease];
	statusBarView.backgroundColor = [UIColor colorWithWhite:0.2 alpha:1.0];
	[window insertSubview:statusBarView aboveSubview:view];
	[application setStatusBarStyle: UIStatusBarStyleLightContent];
	
    NSTimeInterval totalDelay;
    [self _showLightFlourishWithTotalDelay:&totalDelay];
    [self performSelector:@selector(_setUpNextLevel) withObject:nil afterDelay:totalDelay];
	
	return YES;
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
	NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
	[userDefaults setInteger:(currentLevel - 1) forKey:@"currentLevel"];
	[userDefaults synchronize];
}

- (void)applicationWillTerminate:(UIApplication *)application
{
	NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
	[userDefaults setInteger:(currentLevel - 1) forKey:@"currentLevel"];
	[userDefaults synchronize];
}

- (void)dealloc
{
	[window release];
    [view release];
	[super dealloc];
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
        glareImage = [[UIImage imageNamed:@"lo-button-glare"] retain];
    
    // show glare and add fade animation
    CGPoint buttonCenter = [buttonView frame].origin;
    buttonCenter.x -= CGRectGetWidth([buttonView frame]) - 8.0;
    buttonCenter.y -= (CGRectGetHeight([buttonView frame]) / 2.0) + 40.0;
    LOGlareView *glareView = [[[LOGlareView alloc] initWithFrame:(CGRect){buttonCenter, {175.0, 175.0}}] autorelease];
    [glareView setBackgroundColor:[UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.0]];
    [view addSubview:glareView];
#define GLARE_FADE_ANIMATION (0.4)
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:GLARE_FADE_ANIMATION]; {
        [glareView setAlpha:0.0];
    } [UIView commitAnimations];
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
    NSUInteger levelCount = [puzzles count];
    if ((currentLevel + 1) > levelCount)
        currentLevel = 0;
    NSTimeInterval totalDelay;
    [self _showLightFlourishWithTotalDelay:&totalDelay];
    [self performSelector:@selector(_setUpNextLevel) withObject:nil afterDelay:totalDelay];
}

- (void)skipToPreviousLevel;
{
    isAcceptingInput = NO;
    [self _turnOffAllLights];
    currentLevel -= 2;
	if (currentLevel < 0) {
		NSUInteger levelCount = [puzzles count];
        currentLevel = levelCount - 1;
	}
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
    NSUInteger levelCount = [puzzles count];
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
    
    [self _setCurrentLevelString:[NSString stringWithFormat:@"%zd", currentLevel]];
    
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
