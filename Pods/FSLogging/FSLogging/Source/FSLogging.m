//
//  FSLogging.m
//  FSLogging
//
//  Created by Dean Chang on 4/20/18.
//  Copyright © 2018 Freestar. All rights reserved.
//

#import "FSLogging.h"

static FSLogLevel FSLOG_LEVEL = FSLogLevelOff;   //FSLogLevelAll

@implementation FSLogManager

+ (FSLogLevel)getFSLogLevel {
    return FSLOG_LEVEL;
}

+ (void)setFSLogLevel:(FSLogLevel)level {
    FSLOG_LEVEL = level;
}

@end

void _FSLog(FSLogLevel level, NSString *levelString, char const *logContext, NSString *format, ...) {
    if ([FSLogManager getFSLogLevel] >= level) {
        format = [NSString stringWithFormat:@" FREESTAR %@  %s -- %@", levelString, logContext, format];
        va_list args;
        va_start(args, format);
        NSString *fullString = [[NSString alloc] initWithFormat:format arguments:args];
        va_end(args);        
        NSLog(@"%@", fullString);
    }
}

