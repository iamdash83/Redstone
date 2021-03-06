#import "Redstone.h"

@implementation RSVolumeHUD

- (id)initWithFrame:(CGRect)frame {
	if (self = [super initWithFrame:frame]) {
		[self setBackgroundColor:[RSAesthetics colorForCurrentThemeByCategory:@"backgroundColor"]];
		[self setClipsToBounds:YES];
		[self.layer setAnchorPoint:CGPointMake(0.5, 0)];
		[self setFrame:frame];
		
		ringerVolumeView = [[RSVolumeView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, 100) forCategory:@"Ringtone"];
		[ringerVolumeView.slider addTarget:self action:@selector(ringerVolumeChanged) forControlEvents:UIControlEventValueChanged];
		[self addSubview:ringerVolumeView];
		
		ringerMuteButton = [[RSTiltView alloc] initWithFrame:CGRectMake(10, 31, 36, 36)];
		[ringerMuteButton.titleLabel setTextColor:[RSAesthetics colorForCurrentThemeByCategory:@"foregroundColor"]];
		[ringerMuteButton.titleLabel setFont:[UIFont fontWithName:@"SegoeMDL2Assets" size:24]];
		[ringerMuteButton setHighlightEnabled:YES];
		[ringerMuteButton addTarget:self action:@selector(toggleRingerMuted)];
		[ringerVolumeView addSubview:ringerMuteButton];
		
		mediaVolumeView = [[RSVolumeView alloc] initWithFrame:CGRectMake(0, 110, frame.size.width, 100) forCategory:@"Audio/Video"];
		[mediaVolumeView.slider addTarget:self action:@selector(mediaVolumeChanged) forControlEvents:UIControlEventValueChanged];
		[self addSubview:mediaVolumeView];
		
		mediaMuteButton = [[RSTiltView alloc] initWithFrame:CGRectMake(10, 31, 36, 36)];
		[mediaMuteButton.titleLabel setTextColor:[RSAesthetics colorForCurrentThemeByCategory:@"foregroundColor"]];
		[mediaMuteButton.titleLabel setFont:[UIFont fontWithName:@"SegoeMDL2Assets" size:24]];
		[mediaMuteButton setHighlightEnabled:YES];
		[mediaMuteButton addTarget:self action:@selector(toggleMediaMuted)];
		[mediaVolumeView addSubview:mediaMuteButton];
		
		headphoneVolumeView = [[RSVolumeView alloc] initWithFrame:CGRectMake(0, 110, frame.size.width, 100) forCategory:@"Headphones"];
		[headphoneVolumeView.slider addTarget:self action:@selector(mediaVolumeChanged) forControlEvents:UIControlEventValueChanged];
		[self addSubview:headphoneVolumeView];
		
		headphoneMuteButton = [[RSTiltView alloc] initWithFrame:CGRectMake(10, 31, 36, 36)];
		[headphoneMuteButton.titleLabel setTextColor:[RSAesthetics colorForCurrentThemeByCategory:@"foregroundColor"]];
		[headphoneMuteButton.titleLabel setFont:[UIFont fontWithName:@"SegoeMDL2Assets" size:24]];
		[headphoneMuteButton setTitle:@"\uE7F6"];
		[headphoneMuteButton setUserInteractionEnabled:NO];
		[headphoneVolumeView addSubview:headphoneMuteButton];
		
		extendButton = [[RSTiltView alloc] initWithFrame:CGRectMake(frame.size.width - 46, 10, 36, 18)];
		[extendButton setTiltEnabled:NO];
		[extendButton.titleLabel setTextColor:[RSAesthetics colorForCurrentThemeByCategory:@"foregroundColor"]];
		[extendButton.titleLabel setFont:[UIFont fontWithName:@"SegoeMDL2Assets" size:18]];
		[extendButton setTitle:@"\uE70D"];
		[extendButton addTarget:self action:@selector(toggleExtended)];
		[self addSubview:extendButton];
		
		vibrationButton = [UIButton buttonWithType:UIButtonTypeSystem];
		[vibrationButton addTarget:self action:@selector(toggleVibrationEnabled) forControlEvents:UIControlEventTouchUpInside];
		[vibrationButton.titleLabel setFont:[UIFont fontWithName:@"SegoeUI" size:14]];
		[self addSubview:vibrationButton];
		[self updateVibrateButtonStatus];
		
		ringerButton = [UIButton buttonWithType:UIButtonTypeSystem];
		[ringerButton addTarget:self action:@selector(toggleRingerMuted) forControlEvents:UIControlEventTouchUpInside];
		[ringerButton.titleLabel setFont:[UIFont fontWithName:@"SegoeUI" size:14]];
		[self addSubview:ringerButton];
		[self updateRingerButtonStatus];
		
		nowPlayingControls = [[RSNowPlayingControls alloc] initWithFrame:CGRectMake(0, 100, frame.size.width, 120)];
		[self addSubview:nowPlayingControls];
		[nowPlayingControls setHidden:YES];
		
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(disappear) name:@"RedstoneDeviceLocked" object:nil];
		
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(accentColorChanged) name:@"RedstoneAccentColorChanged" object:nil];
	}
	
	return self;
}

- (void)setFrame:(CGRect)frame {
	[super setFrame:frame];
	
	[ringerVolumeView setFrame:CGRectMake(0, ringerVolumeView.frame.origin.y, frame.size.width, 100)];
	[mediaVolumeView setFrame:CGRectMake(0, mediaVolumeView.frame.origin.y, frame.size.width, 100)];
	[headphoneVolumeView setFrame:CGRectMake(0, headphoneVolumeView.frame.origin.y, frame.size.width, 100)];
	[extendButton setFrame:CGRectMake(frame.size.width - 46, extendButton.frame.origin.y, 36, 18)];
	[ringerButton setFrame:CGRectMake(frame.size.width - ringerButton.frame.size.width - 10, ringerButton.frame.origin.y, ringerButton.frame.size.width, 18)];
	[nowPlayingControls setFrame:CGRectMake(0, nowPlayingControls.frame.origin.y, frame.size.width, 120)];
}

- (void)accentColorChanged {
	[self updateVibrateButtonStatus];
	[self updateRingerButtonStatus];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
	[super touchesBegan:touches withEvent:event];
	
	[self resetAnimationTimer];
}

- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
	[super touchesMoved:touches withEvent:event];
	
	[self resetAnimationTimer];
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
	[super touchesEnded:touches withEvent:event];
	
	[self resetAnimationTimer];
}

- (void)updateVolumeValues {
	[ringerVolumeView setVolumeValue:[[[RSCore sharedInstance] audioController] ringerVolume]];
	[ringerVolumeView.slider setValue:[[[RSCore sharedInstance] audioController] ringerVolume]];
	
	if ([[[RSCore sharedInstance] audioController] ringerVolume] >= 1.0/16.0) {
		[ringerMuteButton setTitle:@"\uEA8F"];
	} else {
		if ([self getVibrationEnabled]) {
			[ringerMuteButton setTitle:@"\uE877"];
		} else {
			[ringerMuteButton setTitle:@"\uE7ED"];
		}
	}
	
	[mediaVolumeView setVolumeValue:[[[RSCore sharedInstance] audioController] mediaVolume]];
	[mediaVolumeView.slider setValue:[[[RSCore sharedInstance] audioController] mediaVolume]];
	
	if ([[[RSCore sharedInstance] audioController] mediaVolume] >= 1.0/16.0) {
		[mediaMuteButton setTitle:@"\uE767"];
	} else {
		[mediaMuteButton setTitle:@"\uE74F"];
	}
	
	[headphoneVolumeView setVolumeValue:[[[RSCore sharedInstance] audioController] mediaVolume]];
	[headphoneVolumeView.slider setValue:[[[RSCore sharedInstance] audioController] mediaVolume]];
}

#pragma mark Animations

- (void)appear {
	self.isExtended = NO;
	self.isVisible = YES;
	[self setFrame:CGRectMake(0, -self.frame.size.height, self.frame.size.width, self.frame.size.height)];
	
	[UIView animateWithDuration:0.3 animations:^{
		[self setEasingFunction:easeOutCubic forKeyPath:@"frame"];
		[self setFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
	} completion:^(BOOL finished) {
		[self removeEasingFunctionForKeyPath:@"frame"];
	}];
}

- (void)disappear {
	[animationTimer invalidate];
	animationTimer = nil;
	self.isVisible = NO;
	
	[self setFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
	
	[UIView animateWithDuration:0.3 animations:^{
		[self setEasingFunction:easeInCubic forKeyPath:@"frame"];
		[self setFrame:CGRectMake(0, -self.frame.size.height, self.frame.size.width, self.frame.size.height)];
	} completion:^(BOOL finished) {
		[self removeEasingFunctionForKeyPath:@"frame"];
		
		[[[[RSCore sharedInstance] audioController] window] setHidden:YES];
	}];
}

- (void)resetAnimationTimer {
	[animationTimer invalidate];
	animationTimer = [NSTimer scheduledTimerWithTimeInterval:5 target:self selector:@selector(disappear) userInfo:nil repeats:NO];
}

- (void)toggleExtended {
	[self resetAnimationTimer];
	[self setIsExtended:!self.isExtended];
}

- (void)setIsExtended:(BOOL)isExtended {
	_isExtended = isExtended;
	
	if (isExtended) {
		if (self.isShowingHeadphoneVolume) {
			[mediaVolumeView setHidden:YES];
			[headphoneVolumeView setHidden:NO];
		} else {
			[mediaVolumeView setHidden:NO];
			[headphoneVolumeView setHidden:YES];
		}
		
		if (self.isShowingNowPlayingControls) {
			[nowPlayingControls setHidden:YES];
			[extendButton setFrame:CGRectMake(self.frame.size.width - 46, 162, 36, 18)];
			[vibrationButton setFrame:CGRectMake(10, 110, vibrationButton.frame.size.width, 18)];
			
			[ringerButton setHidden:NO];
		} else {
			[extendButton setFrame:CGRectMake(self.frame.size.width - 46, 216, 36, 18)];
			[vibrationButton setFrame:CGRectMake(10, 216, vibrationButton.frame.size.width, 18)];
			
			[ringerButton setHidden:YES];
		}
		
		[extendButton setTransform:CGAffineTransformMakeRotation(deg2rad(180))];
		
		[vibrationButton setHidden:NO];
	} else {
		if (self.isShowingNowPlayingControls) {
			if (self.isShowingHeadphoneVolume) {
				[mediaVolumeView setHidden:YES];
				[headphoneVolumeView setHidden:NO];
			} else {
				[mediaVolumeView setHidden:NO];
				[headphoneVolumeView setHidden:YES];
			}
			
			[nowPlayingControls setHidden:NO];
			[vibrationButton setHidden:YES];
		} else {
			[mediaVolumeView setHidden:YES];
			[headphoneVolumeView setHidden:YES];
		}
		
		[extendButton setFrame:CGRectMake(self.frame.size.width - 46, 10, 36, 18)];
		[extendButton setTransform:CGAffineTransformIdentity];
		
		[ringerButton setHidden:YES];
	}
	
	if (self.isVisible) {
		[UIView animateWithDuration:0.25 animations:^{
			[self setEasingFunction:easeOutExpo forKeyPath:@"frame"];
			
			if (self.isShowingNowPlayingControls) {
				if (self.isExtended) {
					[self setBounds:CGRectMake(0, 0, self.frame.size.width, 190)];
					[self.window setFrame:CGRectMake(0, 0, self.frame.size.width, 190)];
				} else {
					[self setBounds:CGRectMake(0, 0, self.frame.size.width, 220)];
					[self.window setFrame:CGRectMake(0, 0, self.frame.size.width, 220)];
				}
			} else {
				if (self.isExtended) {
					[self setBounds:CGRectMake(0, 0, self.frame.size.width, 244)];
					[self.window setFrame:CGRectMake(0, 0, self.frame.size.width, 244)];
				} else {
					[self setBounds:CGRectMake(0, 0, self.frame.size.width, 100)];
					[self.window setFrame:CGRectMake(0, 0, self.frame.size.width, 100)];
				}
			}
		} completion:^(BOOL finished){
			[self removeEasingFunctionForKeyPath:@"frame"];
		}];
	} else {
		if (self.isShowingNowPlayingControls) {
			if (self.isExtended) {
				[self setBounds:CGRectMake(0, 0, self.frame.size.width, 190)];
				[self.window setFrame:CGRectMake(0, 0, self.frame.size.width, 190)];
			} else {
				[self setBounds:CGRectMake(0, 0, self.frame.size.width, 220)];
				[self.window setFrame:CGRectMake(0, 0, self.frame.size.width, 220)];
			}
		} else {
			if (self.isExtended) {
				[self setBounds:CGRectMake(0, 0, self.frame.size.width, 244)];
				[self.window setFrame:CGRectMake(0, 0, self.frame.size.width, 244)];
			} else {
				[self setBounds:CGRectMake(0, 0, self.frame.size.width, 100)];
				[self.window setFrame:CGRectMake(0, 0, self.frame.size.width, 100)];
			}
		}
	}
}

- (void)setIsShowingNowPlayingControls:(BOOL)isShowingNowPlayingControls {
	_isShowingNowPlayingControls = isShowingNowPlayingControls;
	
	if (isShowingNowPlayingControls) {
		[ringerVolumeView setHidden:YES];
		[nowPlayingControls setHidden:self.isExtended];
		
		[mediaVolumeView setFrame:CGRectMake(0, 0, self.frame.size.width, 100)];
		[headphoneVolumeView setFrame:CGRectMake(0, 0, self.frame.size.width, 100)];
		
		if (self.isShowingHeadphoneVolume) {
			[mediaVolumeView setHidden:YES];
			[headphoneVolumeView setHidden:NO];
		} else {
			[mediaVolumeView setHidden:NO];
			[headphoneVolumeView setHidden:YES];
		}
	} else {
		[ringerVolumeView setHidden:NO];
		[nowPlayingControls setHidden:YES];
		
		[mediaVolumeView setFrame:CGRectMake(0, 110, self.frame.size.width, 100)];
		[headphoneVolumeView setFrame:CGRectMake(0, 110, self.frame.size.width, 100)];
	}
	
	if (self.isVisible) {
		[UIView animateWithDuration:0.25 animations:^{
			[self setEasingFunction:easeOutExpo forKeyPath:@"frame"];
			
			if (self.isShowingNowPlayingControls) {
				if (self.isExtended) {
					[self setBounds:CGRectMake(0, 0, self.frame.size.width, 190)];
					[self.window setFrame:CGRectMake(0, 0, self.frame.size.width, 190)];
				} else {
					[self setBounds:CGRectMake(0, 0, self.frame.size.width, 220)];
					[self.window setFrame:CGRectMake(0, 0, self.frame.size.width, 220)];
				}
			} else {
				if (self.isExtended) {
					[self setBounds:CGRectMake(0, 0, self.frame.size.width, 244)];
					[self.window setFrame:CGRectMake(0, 0, self.frame.size.width, 244)];
				} else {
					[self setBounds:CGRectMake(0, 0, self.frame.size.width, 100)];
					[self.window setFrame:CGRectMake(0, 0, self.frame.size.width, 100)];
				}
			}
		} completion:^(BOOL finished) {
			[self removeEasingFunctionForKeyPath:@"frame"];
		}];
	} else {
		if (self.isShowingNowPlayingControls) {
			if (self.isExtended) {
				[self setBounds:CGRectMake(0, 0, self.frame.size.width, 190)];
				[self.window setFrame:CGRectMake(0, 0, self.frame.size.width, 190)];
			} else {
				[self setBounds:CGRectMake(0, 0, self.frame.size.width, 220)];
				[self.window setFrame:CGRectMake(0, 0, self.frame.size.width, 220)];
			}
		} else {
			if (self.isExtended) {
				[self setBounds:CGRectMake(0, 0, self.frame.size.width, 244)];
				[self.window setFrame:CGRectMake(0, 0, self.frame.size.width, 244)];
			} else {
				[self setBounds:CGRectMake(0, 0, self.frame.size.width, 100)];
				[self.window setFrame:CGRectMake(0, 0, self.frame.size.width, 100)];
			}
		}
	}
}

- (void)setIsShowingHeadphoneVolume:(BOOL)isShowingHeadphoneVolume {
	_isShowingHeadphoneVolume = isShowingHeadphoneVolume;
	
	if (isShowingHeadphoneVolume) {
		[mediaVolumeView setHidden:YES];
		[headphoneVolumeView setHidden:NO];
	} else {
		[mediaVolumeView setHidden:NO];
		[headphoneVolumeView setHidden:YES];
	}
	
	[self updateVolumeValues];
}

#pragma mark Volume Change

- (void)ringerVolumeChanged {
	[self resetAnimationTimer];
	
	float ringerVolume = [[NSString stringWithFormat:@"%.04f", [ringerVolumeView.slider currentValue]] floatValue];
	ringerVolume = roundf(ringerVolume * 16) / 16;
	
	if (ringerVolume >= 1.0/16.0) {
		[ringerMuteButton setTitle:@"\uEA8F"];
		
		[[objc_getClass("SBMediaController") sharedInstance] setRingerMuted:NO];
		[[objc_getClass("AVSystemController") sharedAVSystemController] setVolumeTo:ringerVolume forCategory:@"Ringtone"];
	} else {
		if ([self getVibrationEnabled]) {
			[ringerMuteButton setTitle:@"\uE877"];
		} else {
			[ringerMuteButton setTitle:@"\uE7ED"];
		}
		
		[[objc_getClass("SBMediaController") sharedInstance] setRingerMuted:YES];
		[[objc_getClass("AVSystemController") sharedAVSystemController] setVolumeTo:0.0 forCategory:@"Ringtone"];
	}
	
	[ringerVolumeView setVolumeValue:ringerVolume];
	[[[RSCore sharedInstance] audioController] setRingerVolume:ringerVolume];
}

- (void)mediaVolumeChanged {
	[self resetAnimationTimer];
	
	float mediaVolume = [[NSString stringWithFormat:@"%.04f", [mediaVolumeView.slider currentValue]] floatValue];
	mediaVolume = roundf(mediaVolume * 16) / 16;
	
	[[objc_getClass("AVSystemController") sharedAVSystemController] setVolumeTo:mediaVolume forCategory:@"Audio/Video"];
	if (mediaVolume >= 1.0/16.0) {
		[mediaMuteButton setTitle:@"\uE767"];
	} else {
		[mediaMuteButton setTitle:@"\uE74F"];
	}
	
	[mediaVolumeView setVolumeValue:mediaVolume];
	[[[RSCore sharedInstance] audioController] setMediaVolume:mediaVolume];
}

- (void)headphoneVolumeChanged {
	[self resetAnimationTimer];
	
	float headphoneVolume = [[NSString stringWithFormat:@"%.04f", [headphoneVolumeView.slider currentValue]] floatValue];
	headphoneVolume = roundf(headphoneVolume * 16) / 16;
	
	[[objc_getClass("AVSystemController") sharedAVSystemController] setVolumeTo:headphoneVolume forCategory:@"Headphones"];
	
	[headphoneVolumeView setVolumeValue:headphoneVolume];
	[[[RSCore sharedInstance] audioController] setMediaVolume:headphoneVolume];
}

#pragma mark Vibration

- (BOOL)getVibrationEnabled {
	if ([[objc_getClass("SBMediaController") sharedInstance] isRingerMuted]) {
		BOOL silentVibrate = [[[NSUserDefaults standardUserDefaults] objectForKey:@"silent-vibrate"] boolValue];
		[[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:silentVibrate] forKey:@"ring-vibrate"];
		
		return silentVibrate;
	} else {
		BOOL ringerVibrate = [[[NSUserDefaults standardUserDefaults] objectForKey:@"ring-vibrate"] boolValue];
		[[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:ringerVibrate] forKey:@"silent-vibrate"];
		
		return ringerVibrate;
	}
	
	return NO;
}

- (void)toggleVibrationEnabled {
	[self resetAnimationTimer];
	
	if ([[objc_getClass("SBMediaController") sharedInstance] isRingerMuted]) {
		BOOL silentVibrate = [[[NSUserDefaults standardUserDefaults] objectForKey:@"silent-vibrate"] boolValue];
		[[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:!silentVibrate] forKey:@"silent-vibrate"];
		[[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:!silentVibrate] forKey:@"slient-vibrate"];
		
	} else {
		BOOL ringerVibrate = [[[NSUserDefaults standardUserDefaults] objectForKey:@"ring-vibrate"] boolValue];
		[[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:!ringerVibrate] forKey:@"ring-vibrate"];
		[[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:!ringerVibrate] forKey:@"ring-vibrate"];
	}
	
	[self updateVibrateButtonStatus];
	[self updateVolumeValues];
}

- (void)updateVibrateButtonStatus {
	[vibrationButton setFrame:CGRectMake(10, 214, self.frame.size.width/2 - 10, 18)];
	
	[UIView performWithoutAnimation:^{
		if ([self getVibrationEnabled]) {
			[vibrationButton.titleLabel setTextColor:[RSAesthetics accentColor]];
			NSString* baseString = [NSString stringWithFormat:@"\uE877 %@", [RSAesthetics localizedStringForKey:@"VIBRATE_ENABLED"]];
			NSMutableAttributedString* attributedString = [[NSMutableAttributedString alloc] initWithString:baseString];
			
			[attributedString addAttribute:NSBaselineOffsetAttributeName value:[NSNumber numberWithFloat:-3.0] range:[baseString rangeOfString:@"\uE877"]];
			[attributedString addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"SegoeMDL2Assets" size:14] range:[baseString rangeOfString:@"\uE877"]];
			[vibrationButton setAttributedTitle:attributedString forState:UIControlStateNormal];
		} else {
			[vibrationButton.titleLabel setTextColor:[RSAesthetics colorForCurrentThemeByCategory:@"foregroundColor"]];
			NSString* baseString = [NSString stringWithFormat:@"\uE877 %@", [RSAesthetics localizedStringForKey:@"VIBRATE_DISABLED"]];
			NSMutableAttributedString* attributedString = [[NSMutableAttributedString alloc] initWithString:baseString];
			
			[attributedString addAttribute:NSBaselineOffsetAttributeName value:[NSNumber numberWithFloat:-3.0] range:[baseString rangeOfString:@"\uE877"]];
			[attributedString addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"SegoeMDL2Assets" size:14] range:[baseString rangeOfString:@"\uE877"]];
			[vibrationButton setAttributedTitle:attributedString forState:UIControlStateNormal];
		}
		
		[vibrationButton layoutIfNeeded];
	}];
	
	CFNotificationCenterPostNotification(CFNotificationCenterGetDarwinNotifyCenter(), CFSTR("com.apple.springboard.silent-vibrate.changed"), NULL, NULL, TRUE);
	CFNotificationCenterPostNotification(CFNotificationCenterGetDarwinNotifyCenter(), CFSTR("com.apple.springboard.ring-vibrate.changed"), NULL, NULL, TRUE);
	
	[vibrationButton sizeToFit];
	
	if (self.isShowingNowPlayingControls) {
		[vibrationButton setFrame:CGRectMake(10, 110, vibrationButton.frame.size.width, 18)];
	} else {
		[vibrationButton setFrame:CGRectMake(10, 216, vibrationButton.frame.size.width, 18)];
	}
}

- (void)updateRingerButtonStatus {
	[ringerButton setFrame:CGRectMake(self.frame.size.width/2, 214, self.frame.size.width/2 - 10, 18)];
	
	SBMediaController* mediaController = [objc_getClass("SBMediaController") sharedInstance];
	
	[UIView performWithoutAnimation:^{
		if (![mediaController isRingerMuted]) {
			[ringerButton.titleLabel setTextColor:[RSAesthetics accentColor]];
			NSString* baseString = [NSString stringWithFormat:@"\uEA8F %@", [RSAesthetics localizedStringForKey:@"RINGER_ENABLED"]];
			NSMutableAttributedString* attributedString = [[NSMutableAttributedString alloc] initWithString:baseString];
			
			[attributedString addAttribute:NSBaselineOffsetAttributeName value:[NSNumber numberWithFloat:-3.0] range:[baseString rangeOfString:@"\uEA8F"]];
			[attributedString addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"SegoeMDL2Assets" size:14] range:[baseString rangeOfString:@"\uEA8F"]];
			[ringerButton setAttributedTitle:attributedString forState:UIControlStateNormal];
		} else {
			NSString* baseString = [NSString stringWithFormat:@"\uE7ED %@", [RSAesthetics localizedStringForKey:@"RINGER_DISABLED"]];
			NSMutableAttributedString* attributedString = [[NSMutableAttributedString alloc] initWithString:baseString];
			
			[attributedString addAttribute:NSBaselineOffsetAttributeName value:[NSNumber numberWithFloat:-3.0] range:[baseString rangeOfString:@"\uE7ED"]];
			[attributedString addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"SegoeMDL2Assets" size:14] range:[baseString rangeOfString:@"\uE7ED"]];
			[ringerButton setAttributedTitle:attributedString forState:UIControlStateNormal];
		}
		
		[ringerButton layoutIfNeeded];
	}];
	
	[ringerButton sizeToFit];
	
	[ringerButton setFrame:CGRectMake(self.frame.size.width - ringerButton.frame.size.width - 10, 110, ringerButton.frame.size.width, 18)];
	if (self.isShowingNowPlayingControls) {
		[ringerButton setHidden:NO];
	} else {
		[ringerButton setHidden:YES];
	}
}

#pragma mark Mute Buttons

- (void)toggleRingerMuted {
	[self resetAnimationTimer];
	SBMediaController* mediaController = [objc_getClass("SBMediaController") sharedInstance];
	
	if ([mediaController isRingerMuted]) {
		[mediaController setRingerMuted:NO];
		[[[RSCore sharedInstance] audioController] setRingerVolume:1.0/16.0];
		[[objc_getClass("AVSystemController") sharedAVSystemController] setVolumeTo:1.0/16.0 forCategory:@"Ringtone"];
	} else {
		[mediaController setRingerMuted:YES];
		[[[RSCore sharedInstance] audioController] setRingerVolume:0.0];
		[[objc_getClass("AVSystemController") sharedAVSystemController] setVolumeTo:0.0 forCategory:@"Ringtone"];
	}
	
	[self updateVolumeValues];
	[self updateRingerButtonStatus];
}

- (void)toggleMediaMuted {
	[self resetAnimationTimer];
	
	if ([[[RSCore sharedInstance] audioController] mediaVolume] >= 1.0/16.0) {
		[[[RSCore sharedInstance] audioController] setMediaVolume:0.0];
		[[objc_getClass("AVSystemController") sharedAVSystemController] setVolumeTo:0.0 forCategory:@"Audio/Video"];
	} else {
		[[[RSCore sharedInstance] audioController] setMediaVolume:1.0/16.0];
		[[objc_getClass("AVSystemController") sharedAVSystemController] setVolumeTo:1.0/16.0 forCategory:@"Audio/Video"];
	}
	
	[self updateVolumeValues];
}

@end
