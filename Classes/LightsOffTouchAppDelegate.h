//
//  LightsOffTouchAppDelegate.h
//  LightsOffTouch
//
//  Created by Craig Hockenberry on 6/6/08.
//  Copyright The Iconfactory 2008. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "LOView.h"

@class LightsOffTouchViewController;

@interface LightsOffTouchAppDelegate : NSObject <UIApplicationDelegate>
{
	UIWindow *window;
	LOView *view;

    NSArray *puzzles;
    
    BOOL isAcceptingInput;
    NSInteger currentLevel;
    NSString *currentLevelString;
}

//@property (nonatomic, retain) UIWindow *window;
//@property (nonatomic, retain) LOView *view;

- (NSString *)currentLevelString;
- (BOOL)isAcceptingInput;
- (void)pressButtonView:(LOButtonView *)buttonView;
- (void)reset;
- (void)skipToNextLevel;
- (void)skipToPreviousLevel;

@end

#define ROW_COUNT (5)
#define COLUMN_COUNT (5)
