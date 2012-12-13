//
//  custom-kvc-operators.m
//
//  Created by Nicolas on 22/11/12.
//  Copyright (c) 2012 Pixel Serious. All rights reserved.
//

#import <Foundation/Foundation.h>


@implementation NSNumber (Opposite)

- (NSNumber*) opposite
{
    return @(-[self doubleValue]);
}

@end

#pragma mark -

@implementation NSArray (Reverse)

- (id) reverse
{
    return [[self reverseObjectEnumerator] allObjects];
}

@end

@implementation NSArray (Sorted)

- (id) sorted
{
    return [self sortedArrayUsingSelector:@selector(compare:)];
}

@end

@implementation NSArray (StandardDeviation)

- (id) _standardDeviationForKeyPath:(NSString*)keyPath
{
    NSNumber * avg = [self valueForKeyPath:[@"@avg." stringByAppendingString:keyPath]];
    
    double temp = 0.;
    for (id obj in self) {
        double deviation = fabs([obj doubleValue]-[avg doubleValue]);
        temp += deviation*deviation;
    }
    
    return @(sqrt(temp/[self count]));
}

@end

@implementation NSArray (UnionOfPresentObjects)

- (id) _unionOfPresentObjectsForKeyPath:(NSString*)keyPath
{
    NSMutableArray * values = [NSMutableArray new];
    for (id obj in self) {
        @try {
            id value = [obj valueForKeyPath:keyPath];
            if(value && value!=[NSNull null])
                [values addObject:value];
        }
        @catch (NSException *exception) {
        }
    }
    return [NSArray arrayWithArray:values];
}

@end

#pragma mark -

@implementation NSArray (CustomKVCOperators)

- (id) _differentialForKeyPath:(NSString*)keyPath
{
    NSArray * values = [self valueForKeyPath:keyPath];
    if([values count]==0)
        return @[];
    
    double previousValue = [values[0] doubleValue];
    if([values count]==1)
        return @[@(previousValue)];
    
    NSMutableArray * result = [NSMutableArray new];
    for (id v in [values subarrayWithRange:NSMakeRange(1, [values count]-1)])
    {
        double value = [v doubleValue];
        double d = value - previousValue;
        [result addObject:@(d)];
        previousValue = value;
    }
    return [NSArray arrayWithArray:result];
}


@end

#pragma mark -

int main ()
{
    @autoreleasepool {
        
        // Basic use : a path in entities relationships, then an attribute
        //
        // Actually, any method returning an object will do. (the last may return a scalar)
        //
        // Array and Set operators :
        // Work on collection of collections
        //
        // start with @
        // <optional keypath returning a collection>.@operation.<keypath returning a collection>
        //
        // "self" and @self
        
        id positions =  @[@0,
                          @2,
                          @5,
                          @12,
                          @22,
                          @33,
                          @48,
                          @68,
                          @93,
                          @120,
                          @152,
                          @189,
                          @231,
                          @274,
                          @322,
                          @373,
                          @428,
                          @478,
                          @518,
                          @543,
                          @553,
                          @554,
                          @554,
                          ];
        
        // [positions valueForKeyPath:@"@self"]
        // [positions valueForKeyPath:@"self"]
//        id pencils = @[@{@"color": @"blue"},
//                       @{@"color": @"red"},
//                       @{@"color": @"blue"},
//                       @{@"notacolor": @"white"}];
//        id markers = @[@{@"color": @"purple"},
//                       @{@"color": @"blue"},
//                       @{@"color": @"green"}];
//        NSLog(@"%@",[@[pencils, markers] valueForKeyPath:@"@distinctUnionOfArrays.color"]);

        id objects = @[@{@"color": @"blue"},
                       @{@"color": @"red"},
                       @{@"color": @"green"},
                       @"notacolor"];
        NSLog(@"%@",[objects valueForKeyPath:@"@unionOfPresentObjects.[Mm]ozilla"]);
        return 1;

        // Custom Simple Operator, operating on objects of a collections (simplest case)
        NSLog(@"(custom selector) opposite = %@",[positions valueForKeyPath:@"opposite"]);

        // Custom Simple Collection operator, returning a collection
        NSLog(@"reverse array = %@",[positions valueForKeyPath:@"@reverse"]);

        // Custom Simple Collection operator, returning a collection (another)
        NSLog(@"sorted array = %@",[positions valueForKeyPath:@"@sorted"]);

        // Using "self" on objects, with a (system) Simple Collection operator, returning a scalar.
        NSLog(@"simple avg = %@",[positions valueForKeyPath:@"@avg.self"]);

        // Custom Simple Collection operator, returning a scalar (boxed)
        NSLog(@"standard deviation = %@",[positions valueForKeyPath:@"@standardDeviation.self"]);

        // Custom Collection Object Operator
        NSLog(@"(custom collection operator) speeds = %@", [positions valueForKeyPath:@"@differential.@self"]);
        // Custom Collection Object Operator, chained
        NSLog(@"(custom collection operator) accelerations = %@", [positions valueForKeyPath:@"@differential.@differential.@self"]);

    }
    return 0;
}
