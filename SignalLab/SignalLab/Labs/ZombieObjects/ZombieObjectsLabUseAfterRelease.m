//
//  ZombieObjectsLabUseAfterRelease.m
//  SignalLab
//
//  ARC is ON; `__unsafe_unretained` models a stale reference for teaching (undefined behavior if Zombies are off).
//

#import "ZombieObjectsLabUseAfterRelease.h"

void ZombieObjectsLabTriggerUnsafeUseAfterRelease(void) {
    NSObject *__unsafe_unretained dangling = nil;
    @autoreleasepool {
        NSObject *temporary = [[NSObject alloc] init];
        dangling = temporary;
    }
    [dangling description];
}

void ZombieObjectsLabTriggerSafeUse(void) {
    @autoreleasepool {
        NSObject *temporary = [[NSObject alloc] init];
        [temporary description];
    }
}
