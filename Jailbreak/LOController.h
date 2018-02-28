#import <Foundation/Foundation.h>
#import <Foundation/NSObject.h>

#import <GraphicsServices/GraphicsServices.h>
#import <CoreGraphics/CoreGraphics.h> // hack

#import <UIKit/UIKit.h>
#import <UIKit/UIApplication.h>

//extern void GSEventPlaySoundAtPath();
//3098d28c T _GSEventGetAccessoryKeyStateInfo
//3098c160 T _GSEventGetCharacterSet
//3098c07c T _GSEventGetClickCount
//3098bfcc T _GSEventGetDeltaX
//3098bfec T _GSEventGetDeltaY
//3098db90 T _GSEventGetEventNumber
//3098bf40 T _GSEventGetHandInfo
//3098d7b4 T _GSEventGetInnerMostPathPosition
//3098d9b4 T _GSEventGetKeyCode
//3098c1d4 T _GSEventGetKeyWindow
//3098bf84 T _GSEventGetLocationInWindow
//3098c168 T _GSEventGetModifierFlags
//3098d7e4 T _GSEventGetOuterMostPathPosition
//3098bf60 T _GSEventGetPathInfoAtIndex
//3098bfb0 T _GSEventGetSubType
//3098c084 T _GSEventGetTimestamp
//3098bc70 T _GSEventGetType
//3098bddc T _GSEventGetTypeID
//3098dbac T _GSEventGetWindow

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