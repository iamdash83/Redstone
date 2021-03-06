#import "Redstone.h"

@implementation RSNotificationView

- (id)initWithBulletin:(BBBulletin*)bulletin {
	if (self = [super initWithFrame:CGRectMake(0, 0, 0, 130)]) {
		_bulletin = bulletin;
		_application = [[objc_getClass("SBApplicationController") sharedInstance] applicationWithBundleIdentifier:[bulletin section]];
		
		SBApplication* frontApp = [(SpringBoard*)[UIApplication sharedApplication] _accessibilityFrontMostApplication];
		if (frontApp) {
			if ([frontApp statusBarOrientation] == UIDeviceOrientationPortrait || [frontApp statusBarOrientation] == UIDeviceOrientationPortraitUpsideDown) {
				[self setFrame:CGRectMake(0, 0, screenWidth, 130)];
			} else {
				[self setFrame:CGRectMake(0, 0, screenHeight, 130)];
			}
		} else {
			[self setFrame:CGRectMake(0, 0, screenWidth, 130)];
		}
		
		[self setBackgroundColor:[RSAesthetics colorForCurrentThemeByCategory:@"backgroundColor"]];
		
		RSTileInfo* tileInfo = [[RSTileInfo alloc] initWithBundleIdentifier:[bulletin section]];
		
		// Icon
		
		toastIcon = [[UIImageView alloc] initWithImage:[RSAesthetics imageForTileWithBundleIdentifier:[bulletin section] size:1 colored:(tileInfo.hasColoredIcon || tileInfo.fullSizeArtwork)]];
		[toastIcon setFrame:CGRectMake(12, 15, 32, 32)];
		[toastIcon setTintColor:[UIColor whiteColor]];
		[toastIcon setBackgroundColor:[RSAesthetics accentColorForTile:tileInfo]];
		[self addSubview:toastIcon];
		
		// Notification Title
		
		titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(54, 10, self.frame.size.width - 66, 20)];
		[titleLabel setFont:[UIFont fontWithName:@"SegoeUI-Semibold" size:15]];
		[titleLabel setTextColor:[RSAesthetics colorForCurrentThemeByCategory:@"foregroundColor"]];
		if ([bulletin title] && ![[bulletin title] isEqualToString:@""]) {
			[titleLabel setText:[bulletin title]];
		} else if (tileInfo.localizedDisplayName) {
			[titleLabel setText:tileInfo.localizedDisplayName];
		} else if (tileInfo.displayName) {
			[titleLabel setText:tileInfo.displayName];
		} else {
			[titleLabel setText:[_application displayName]];
		}
		[self addSubview:titleLabel];
		
		// Notification Subtitle
		
		subtitleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
		if ([bulletin subtitle] && ![[bulletin subtitle] isEqualToString:@""]) {
			[subtitleLabel setFrame:CGRectMake(54, 30, self.frame.size.width - 66, 20)];
			[subtitleLabel setFont:[UIFont fontWithName:@"SegoeUI-Semibold" size:15]];
			[subtitleLabel setTextColor:[RSAesthetics colorForCurrentThemeByCategory:@"foregroundColor"]];
			[subtitleLabel setText:[bulletin subtitle]];
		}
		
		// Notification Message
		
		messageLabel = [[UILabel alloc] initWithFrame:CGRectMake(54, 30 + subtitleLabel.frame.size.height, self.frame.size.width - 66, 40)];
		[messageLabel setFont:[UIFont fontWithName:@"SegoeUI" size:15]];
		[messageLabel setTextColor:[RSAesthetics colorForCurrentThemeByCategory:@"foregroundColor"]];
		[messageLabel setText:[bulletin message]];
		[messageLabel setNumberOfLines:2];
		[messageLabel setLineBreakMode:NSLineBreakByTruncatingTail];
		[messageLabel sizeToFit];
		[self addSubview:messageLabel];
		
		// Frame Calculation
		
		CGFloat notificationTextHeight = 10 + titleLabel.frame.size.height + subtitleLabel.frame.size.height + messageLabel.frame.size.height + 10 + 20;
		CGFloat notificationImageHeight = 15 + 32 + 15 + 20;
		[self setFrame:CGRectMake(0, 0, self.frame.size.width, MAX(notificationTextHeight, notificationImageHeight))];
		
		// Fake Grabber Thing
		
		grabberView = [[UIView alloc] initWithFrame:CGRectMake(0, self.frame.size.height-20, self.frame.size.width, 20)];
		[grabberView setBackgroundColor:[RSAesthetics accentColor]];
		[self addSubview:grabberView];
		
		grabberLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, 20)];
		[grabberLabel setFont:[UIFont fontWithName:@"SegoeMDL2Assets" size:18]];
		[grabberLabel setText:@"\uE76F"];
		[grabberLabel setTextAlignment:NSTextAlignmentCenter];
		[grabberLabel setTextColor:[UIColor whiteColor]];
		[grabberView addSubview:grabberLabel];
		
		// Tap Gesture Recognizer
		
		tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapped)];
		[self addGestureRecognizer:tapGestureRecognizer];
		
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(accentColorChanged) name:@"RedstoneAccentColorChanged" object:nil];
	}
	
	return self;
}

- (void)accentColorChanged {
	[grabberView setBackgroundColor:[RSAesthetics accentColor]];
}

- (void)animateIn {
	[self setFrame:CGRectMake(0, -self.frame.size.height, self.frame.size.width, self.frame.size.height)];
	
	[UIView animateWithDuration:0.3 animations:^{
		[self setEasingFunction:easeOutCubic forKeyPath:@"frame"];
		
		[self setFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
	} completion:^(BOOL finished){
		[self removeEasingFunctionForKeyPath:@"frame"];
	}];
}

- (void)animateOut {
	[UIView animateWithDuration:0.3 animations:^{
		[self setEasingFunction:easeInCubic forKeyPath:@"frame"];
		
		[self setFrame:CGRectMake(0, -self.frame.size.height, self.frame.size.width, self.frame.size.height)];
	} completion:^(BOOL finished){
		[self removeEasingFunctionForKeyPath:@"frame"];
		[[[RSCore sharedInstance] notificationController] removeBulletin:_bulletin];
	}];
}

- (void)stopSlideOutTimer {
	if ([slideOutTimer isKindOfClass:[NSTimer class]]) {
		[slideOutTimer invalidate];
		slideOutTimer = nil;
	}
}

- (void)resetSlideOutTimer {
	[self stopSlideOutTimer];
	
	slideOutTimer = [NSTimer scheduledTimerWithTimeInterval:5 target:self selector:@selector(animateOut) userInfo:nil repeats:NO];
}

- (void)tapped {
	[tapGestureRecognizer setEnabled:NO];
	[[[RSCore sharedInstance] notificationController] clearBulletins];
	
	[[(SBBulletinBannerController*)[objc_getClass("SBBulletinBannerController") sharedInstance] observer] sendResponse:[_bulletin responseForDefaultAction]];
}

@end
