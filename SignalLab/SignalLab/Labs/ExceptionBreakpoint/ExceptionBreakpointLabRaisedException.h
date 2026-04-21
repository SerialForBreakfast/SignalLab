//
//  ExceptionBreakpointLabRaisedException.h
//  SignalLab
//
//  Objective-C exception helper for Exception Breakpoint Lab.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/// Raises an Objective-C exception with readable local context for the debugger.
void ExceptionBreakpointLabTriggerInvalidSelectionException(void);

/// Catches the selection exception and returns the generic app-level symptom.
NSString *ExceptionBreakpointLabRunCaughtSelection(void);

NS_ASSUME_NONNULL_END
