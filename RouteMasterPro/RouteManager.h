//
//  RouteManager.h
//  RouteMasterPro
//
//  Created by Jason Rush on 1/13/13.
//  Copyright (c) 2013 Flush Software LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Route.h"

@interface RouteManager : NSObject

- (Route *)match:(Route *)inRoute;

@end