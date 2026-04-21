//
//  ExceptionBreakpointLabRaisedException.m
//  SignalLab
//
//  Objective-C exception helper for Exception Breakpoint Lab.
//

#import "ExceptionBreakpointLabRaisedException.h"

void ExceptionBreakpointLabTriggerInvalidSelectionException(void) {
    NSString *brokenTableName = @"Archived Shipments";
    NSString *brokenRowID = @"row-404";
    NSString *exceptionReason = [NSString stringWithFormat:@"The app tried to select row '%@' in '%@', but that row does not exist.", brokenRowID, brokenTableName];
    NSDictionary *exceptionContext = @{
        @"brokenTableName": brokenTableName,
        @"brokenRowID": brokenRowID
    };

    @throw [NSException exceptionWithName:NSInvalidArgumentException
                                   reason:exceptionReason
                                 userInfo:exceptionContext];
}

NSString *ExceptionBreakpointLabRunCaughtSelection(void) {
    @try {
        ExceptionBreakpointLabTriggerInvalidSelectionException();
        return @"Selection completed.";
    } @catch (NSException *exception) {
        return @"Selection failed. The app recovered, but hid the table and row details.";
    }
}
