#import <UIKit/UIKit.h>
#import "../../headers/libWeatherManager/RSWeatherCity.h"
#import "../../headers/Weather/Weather.h"
#import <objc/runtime.h>

#define deg2rad(angle) ((angle) / 180.0 * M_PI)

@class RSWeatherCity;

@interface RSWeatherConditionView : UIView {
	IBOutlet UILabel* currentCondition;
	IBOutlet UILabel* cityName;
	
	IBOutlet UILabel* currentTemperature;
	IBOutlet UILabel* highTemp;
	IBOutlet UILabel* lowTemp;
	
	IBOutlet UIImageView* windIcon;
	IBOutlet UILabel *percentPrecipitation;
	IBOutlet UILabel *windSpeed;
}

- (void)updateForCity:(RSWeatherCity*)city;

@end
