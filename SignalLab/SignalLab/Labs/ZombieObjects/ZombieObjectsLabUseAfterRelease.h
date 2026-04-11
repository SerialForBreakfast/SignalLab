//
//  ZombieObjectsLabUseAfterRelease.h
//  SignalLab
//
//  Minimal Objective-C helpers for Zombie Objects Lab: unsafe_unretained dangling send vs safe pool-scoped use.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/// Messages an `NSObject` instance after its last strong reference is gone (`__unsafe_unretained`).
///
/// With **Zombie Objects** enabled in the scheme, this typically becomes a clear zombie trap instead of a vague `EXC_BAD_ACCESS`.
void ZombieObjectsLabTriggerUnsafeUseAfterRelease(void);

/// Allocates an `NSObject`, uses it inside one autorelease pool, and returns—no dangling reference.
void ZombieObjectsLabTriggerSafeUse(void);

NS_ASSUME_NONNULL_END
