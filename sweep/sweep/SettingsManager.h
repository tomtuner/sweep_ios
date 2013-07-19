//
//  SettingsManager.h
//  Sweep
//
//  Created by Thomas DeMeo on 5/6/13.
//  Copyright (c) 2013 Thomas DeMeo. All rights reserved.
//

#import <Foundation/Foundation.h>

static NSString *SETTING_FIRST_TIME_RUN = @"SETTING_FIRST_TIME_RUN";
static NSString *SETTING_THEME = @"THEME";
static NSString *SETTING_PERCENT_VISIBLE = @"PERCENT_VISIBLE";
static NSString *HOCKEY_APP_BETA_ID = @"HOCKEY_APP_BETA_ID";
static NSString *HOCKEY_APP_ID = @"HOCKEY_APP_ID";
static NSString *SETTING_LAST_EVENT_INDEX = @"SETTING_LAST_EVENT_INDEX";

@interface SettingsManager : NSObject {
    SettingsManager * settingsManager;

}

+ (SettingsManager *) sharedSettingsManager;

-(NSString *) theme;
-(NSNumber *) percent_visible;
-(NSString *) hockeyAppID;
-(NSString *) hockeyAppBetaID;
-(NSInteger) indexOfLastViewedEvent;
-(void) setIndexOfLastViewedEvent:(NSInteger) index;

@end
