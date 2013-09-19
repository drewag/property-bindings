//
//  PBLogging.h
//  PropertyBindings
//
//  Created by Andrew Wagner on 9/19/13.
//  Copyright (c) 2013 Drewag. All rights reserved.
//

#import <Foundation/Foundation.h>

#if NO_PB_LOGS
    #define PBLog(format,...) do {} while(0)
#else
    #define PBLog(format,...) NSLog(format,##__VA_ARGS__)
#endif

// SMDLog, only show in debug mode
#if DEBUG
    #define PBDLog(format,...) PBLog(format,##__VA_ARGS__)
#else
    #define PBDLog(format,...) do {} while (0)
#endif