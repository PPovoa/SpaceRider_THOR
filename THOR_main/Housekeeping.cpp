#include "THOR.hpp"

int Housekeeping_Start(int* previousMode, int error_fromMode, int* nextMode){
    int error = NO_error;

    printf("\nHousekeeping mode ====\n");

    printf("Turn off PDU DET Outputs\n");

    printf("-Monitor PDU\n");
    printf("  Get Output state\n");
    printf("  Get Temperature\n");
    printf("  Get Current drawn\n");
    printf("  Get Voltages levels\n");
    if(error!=NO_error)
        return error;

    printf("-Monitor Detector\n");
    printf("  Get Temperature\n");
    if(error!=NO_error)
        return error;

    switch (*previousMode)
    {
    case MODE_COMMI:
        if(IsAnError(error_fromMode)){
            printf("Emergency message to Ground\n");
            if(!IsErrorManageable(error_fromMode))
                printf("Wait for Ground Intervention\n"); // THEN RECEIVE THE NEXT MODE
        }
        *previousMode = *nextMode;
        *nextMode = MODE_OBS;
        printf("Enter observational mode\n");
        break;

    case MODE_DEBUG:
        printf("Emergency message to Ground\n");
        if(IsErrorManageable(error_fromMode)){
            *previousMode = *nextMode;
            *nextMode = MODE_OBS;
            printf("Enter observational mode\n");
            break;
        }
        else
            printf("Wait for Ground Intervention\n"); // THEN RECEIVE THE NEXT MODE
            *previousMode = *nextMode;
            *nextMode = MODE_TEST;
        break;

    case MODE_TEST:
        *previousMode = *nextMode;
        *nextMode = MODE_OBS;
        printf("Enter observational mode\n");
        break;

    case MODE_REBOOT:
        *previousMode = *nextMode;
        *nextMode = MODE_REBOOT;
        printf("Rebooting...\n");
        break;

    default:// ?????????
        printf("default - HK ????????\n\n");
        *previousMode = *nextMode;
        *nextMode = MODE_REBOOT;
        break;
    }

    return error;
}

int IsErrorManageable(int error){
    if(error >= 1 && error <= 5)
        return 1;
    else
        return 0;
}

int IsAnError(int error){
    if(error != NO_error)
        return 1;
    else
        return 0;
}