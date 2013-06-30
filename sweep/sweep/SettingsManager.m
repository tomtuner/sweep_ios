//
//  SettingsManager.m
//  Sweep
//
//  Created by Thomas DeMeo on 5/6/13.
//  Copyright (c) 2013 Thomas DeMeo. All rights reserved.
//

#import "SettingsManager.h"

@interface SettingsManager()

@property (nonatomic, strong) NSUserDefaults *userDefaults;

@end

static SettingsManager *globalSettingsManager = nil;
static BOOL initialized = NO;

@implementation SettingsManager

+ (SettingsManager *) sharedSettingsManager {
    if (!globalSettingsManager) {
        globalSettingsManager = [[SettingsManager alloc] init];
    }
    
    return globalSettingsManager;
}

- (id)init
{
    if (initialized) {
        return globalSettingsManager;
    }
    self = [super init];
    if (self) {
        
        _userDefaults = [NSUserDefaults standardUserDefaults];
//        self.versionNumber = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"];
        
        
        NSObject *setting = [_userDefaults objectForKey:SETTING_FIRST_TIME_RUN];
        if (setting == nil) {
            // Do any first time initialization here
            [_userDefaults setObject:[NSNumber numberWithInt:9] forKey:SETTING_FIRST_TIME_RUN];
//            self.useSelfSignedSSLCertificates = NO;
//            [self.userDefaults setObject:SERVER_URL forKey:SETTING_SERVER];
            [_userDefaults synchronize];
        }
    }else {
        settingsManager = nil;
        initialized = YES;
    }
    return self;
}

-(NSString *) theme
{
    return [_userDefaults stringForKey:SETTING_THEME];
}

-(NSNumber *) percent_visible
{
    return [_userDefaults objectForKey:SETTING_PERCENT_VISIBLE];
}

@end
