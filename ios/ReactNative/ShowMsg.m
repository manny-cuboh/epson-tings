#import "ShowMsg.h"

@interface ShowMsg()
+ (NSString *)getEposErrorText:(int)error;
+ (NSString *)getEposBtErrorText:(int)error;
+ (NSString *)getEposResultText:(int)result;
@end

@implementation ShowMsg

+ (void)showErrorEpos:(int)resultCode method:(NSString *)method
{
    NSString *msg = [NSString stringWithFormat:@"%@\n%@\n\n%@\n%@\n",
                     NSLocalizedString(@"methoderr_errcode", @""),
                     [self getEposErrorText:resultCode],
                     NSLocalizedString(@"methoderr_method", @""),
                     method];
    [self show:msg];
}

+ (void)showErrorEposBt:(int)resultCode method:(NSString *)method
{
    NSString *msg = [NSString stringWithFormat:@"%@\n%@\n\n%@\n%@\n",
                     NSLocalizedString(@"methoderr_errcode", @""),
                     [self getEposBtErrorText:resultCode],
                     NSLocalizedString(@"methoderr_method", @""),
                     method];
    [self show:msg];
}

+ (void)showResult:(int)code errMsg:(NSString *)errMsg
{
    NSString *msg = @"";

    if ([errMsg isEqualToString:@""]) {
        msg = [NSString stringWithFormat:@"%@\n%@\n",
               NSLocalizedString(@"statusmsg_result", @""),
               [self getEposResultText:code]];
    }
    else {
        msg = [NSString stringWithFormat:@"%@\n%@\n\n%@\n%@\n",
               NSLocalizedString(@"statusmsg_result", @""),
               [self getEposResultText:code],
               NSLocalizedString(@"statusmsg_description", @""),
               errMsg];
    }

    [self show:msg];
}

//show alart view
+ (void)show:(NSString *)msg
{
    [self performSelectorOnMainThread:@selector(showOnMainThread:) withObject:msg waitUntilDone:YES];
}

+ (void)showOnMainThread:(NSString *)msg
{
  UIAlertView *alert = [[UIAlertView alloc]
                        initWithTitle:nil
                        message:msg
                        delegate:nil
                        cancelButtonTitle:nil
                        otherButtonTitles:@"OK", nil
                        ];
  [alert show];
}

//convert Epos2Printer Error to text
+ (NSString *)getEposErrorText:(int)error
{
    NSString *errText = @"";
    switch (error) {
        case EPOS2_SUCCESS:
            errText = @"SUCCESS";
            break;
        case EPOS2_ERR_PARAM:
            errText = @"ERR_PARAM";
            break;
        case EPOS2_ERR_CONNECT:
            errText = @"ERR_CONNECT";
            break;
        case EPOS2_ERR_TIMEOUT:
            errText = @"ERR_TIMEOUT";
            break;
        case EPOS2_ERR_MEMORY:
            errText = @"ERR_MEMORY";
            break;
        case EPOS2_ERR_ILLEGAL:
            errText = @"ERR_ILLEGAL";
            break;
        case EPOS2_ERR_PROCESSING:
            errText = @"ERR_PROCESSING";
            break;
        case EPOS2_ERR_NOT_FOUND:
            errText = @"ERR_NOT_FOUND";
            break;
        case EPOS2_ERR_IN_USE:
            errText = @"ERR_IN_USE";
            break;
        case EPOS2_ERR_TYPE_INVALID:
            errText = @"ERR_TYPE_INVALID";
            break;
        case EPOS2_ERR_DISCONNECT:
            errText = @"ERR_DISCONNECT";
            break;
        case EPOS2_ERR_ALREADY_OPENED:
            errText = @"ERR_ALREADY_OPENED";
            break;
        case EPOS2_ERR_ALREADY_USED:
            errText = @"ERR_ALREADY_USED";
            break;
        case EPOS2_ERR_BOX_COUNT_OVER:
            errText = @"ERR_BOX_COUNT_OVER";
            break;
        case EPOS2_ERR_BOX_CLIENT_OVER:
            errText = @"ERR_BOXT_CLIENT_OVER";
            break;
        case EPOS2_ERR_UNSUPPORTED:
            errText = @"ERR_UNSUPPORTED";
            break;
        case EPOS2_ERR_FAILURE:
            errText = @"ERR_FAILURE";
            break;
        default:
            errText = [NSString stringWithFormat:@"%d", error];
            break;
    }
    return errText;
}

//convert Epos2BluetoothConnection Error to text
+ (NSString *)getEposBtErrorText:(int)error
{
    NSString *errText = @"";
    switch (error) {
        case EPOS2_BT_SUCCESS:
            errText = @"SUCCESS";
            break;
        case EPOS2_BT_ERR_PARAM:
            errText = @"ERR_PARAM";
            break;
        case EPOS2_BT_ERR_UNSUPPORTED:
            errText = @"ERR_UNSUPPORTED";
            break;
        case EPOS2_BT_ERR_CANCEL:
            errText = @"ERR_CANCEL";
            break;
        case EPOS2_BT_ERR_ALREADY_CONNECT:
            errText = @"ERR_ALREADY_CONNECT";
            break;
        case EPOS2_BT_ERR_ILLEGAL_DEVICE:
            errText = @"ERR_ILLEGAL_DEVICE";
            break;
        case EPOS2_BT_ERR_FAILURE:
            errText = @"ERR_FAILURE";
            break;
        default:
            errText = [NSString stringWithFormat:@"%d", error];
            break;
    }
    return errText;
}

//convert Epos2 Result code to text
+ (NSString *)getEposResultText:(int)resultCode
{
    NSString *result = @"";
    switch (resultCode) {
        case EPOS2_CODE_SUCCESS:
            result = @"PRINT_SUCCESS";
            break;
        case EPOS2_CODE_PRINTING:
            result = @"PRINTING";
            break;
        case EPOS2_CODE_ERR_AUTORECOVER:
            result = @"ERR_AUTORECOVER";
            break;
        case EPOS2_CODE_ERR_COVER_OPEN:
            result = @"ERR_COVER_OPEN";
            break;
        case EPOS2_CODE_ERR_CUTTER:
            result = @"ERR_CUTTER";
            break;
        case EPOS2_CODE_ERR_MECHANICAL:
            result = @"ERR_MECHANICAL";
            break;
        case EPOS2_CODE_ERR_EMPTY:
            result = @"ERR_EMPTY";
            break;
        case EPOS2_CODE_ERR_UNRECOVERABLE:
            result = @"ERR_UNRECOVERABLE";
            break;
        case EPOS2_CODE_ERR_FAILURE:
            result = @"ERR_FAILURE";
            break;
        case EPOS2_CODE_ERR_NOT_FOUND:
            result = @"ERR_NOT_FOUND";
            break;
        case EPOS2_CODE_ERR_SYSTEM:
            result = @"ERR_SYSTEM";
            break;
        case EPOS2_CODE_ERR_PORT:
            result = @"ERR_PORT";
            break;
        case EPOS2_CODE_ERR_TIMEOUT:
            result = @"ERR_TIMEOUT";
            break;
        case EPOS2_CODE_ERR_JOB_NOT_FOUND:
            result = @"ERR_JOB_NOT_FOUND";
            break;
        case EPOS2_CODE_ERR_SPOOLER:
            result = @"ERR_SPOOLER";
            break;
        case EPOS2_CODE_ERR_BATTERY_LOW:
            result = @"ERR_BATTERY_LOW";
            break;
        case EPOS2_CODE_ERR_TOO_MANY_REQUESTS:
            result = @"ERR_TOO_MANY_REQUESTS";
            break;
        case EPOS2_CODE_ERR_REQUEST_ENTITY_TOO_LARGE:
            result = @"ERR_REQUEST_ENTITY_TOO_LARGE";
            break;
        default:
            result = [NSString stringWithFormat:@"%d", resultCode];
            break;
    }

    return result;
}

@end
