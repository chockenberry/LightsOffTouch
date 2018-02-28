
#import <UIKit/UIKit.h>

// Constants
typedef enum {
    kUIAnimationCurveEaseInEaseOut,
    kUIAnimationCurveEaseIn,
    kUIAnimationCurveEaseOut,
    kUIAnimationCurveLinear
} UIAnimationCurve;

@interface UIView(Color)
- (CGColorRef)colorWithRed:(float)red green:(float)green blue:(float)blue alpha:(float)alpha;
@end

@class LOButtonView, LOView;

@interface LOController : UIApplication {
	UIWindow *window;
    LOView *view;
    NSArray *puzzles;
    
    BOOL isAcceptingInput;
    unsigned int currentLevel;
    NSString *currentLevelString;
}

- (NSString *)currentLevelString;
- (BOOL)isAcceptingInput;
- (void)pressButtonView:(LOButtonView *)buttonView;
- (void)reset;
- (void)skipToNextLevel;
- (void)skipToPreviousLevel;
@end

#define ROW_COUNT (5)
#define COLUMN_COUNT (5)