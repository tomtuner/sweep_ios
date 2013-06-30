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

@interface SettingsManager : NSObject {
    SettingsManager * settingsManager;

}

+ (SettingsManager *) sharedSettingsManager;

-(NSString *) theme;
-(NSNumber *) percent_visible;

@end
