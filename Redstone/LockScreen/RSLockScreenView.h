#import <UIKit/UIKit.h>

@class RSNowPlayingControls, RSLockScreenPasscodeEntryView;

@interface RSLockScreenView : UIView <UIScrollViewDelegate> {
	UIImageView* wallpaperView;
	UIImageView* fakeHomeScreenWallpaperView;
	UIView* wallpaperOverlay;
	
	UIScrollView* unlockScrollView;
	UIView* timeAndDateView;
	
	UILabel* timeLabel;
	UILabel* dateLabel;
	
	RSNowPlayingControls* nowPlayingControls;
}

@property (nonatomic, assign) BOOL isScrolling;
@property (nonatomic, assign) BOOL isUnlocking;
@property (nonatomic, strong) RSLockScreenPasscodeEntryView* passcodeEntryView;

- (void)setContentOffset:(CGPoint)contentOffset;
- (void)setContentOffset:(CGPoint)contentOffset animated:(BOOL)animated;
- (CGPoint)contentOffset;

- (void)setTime:(NSString*)time;
- (void)setDate:(NSString*)date;
- (void)reset;

@end
