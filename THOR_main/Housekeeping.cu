#include "THOR.hpp"

void Housekeeping_Start(StoredErrors storedErrors, int* previousMode, int error_fromMode, int* nextMode){

    printf("\nHousekeeping mode ====\n");

    printf("Turn off PDU DET Outputs\n");//storedErrors.addError(ErrorHandler::SR_MMU_CantConnect);

    printf("-Monitor PDU\n");
    printf("  Get Output state\n");//storedErrors.addError(ErrorHandler::PDU_ErrorGetOuputState);
    printf("  Get Temperature\n");//storedErrors.addError(ErrorHandler::PDU_ErrorGetTemperature);
    printf("  Get Current drawn\n");//storedErrors.addError(ErrorHandler::PDU_ErrorGetCurrent);
    printf("  Get Voltages levels\n");//storedErrors.addError(ErrorHandler::PDU_ErrorGetVoltage);

    printf("-Monitor Detector\n");
    printf("  Get Temperature\n");//storedErrors.addError(ErrorHandler::DET_ErrorGetTemperature);

    switch (*previousMode)
    {
    case MODE_COMMI:
        if(!storedErrors.hasNoErrors()){
            printf("Emergency message to Ground\n");
            if(!IsErrorManageable(storedErrors.getThrownErrors()))
                printf("Wait for Ground Intervention\n"); // THEN RECEIVE THE NEXT MODE
        }
        *previousMode = *nextMode;
        *nextMode = MODE_OBS;
        printf("Enter observational mode\n");
        break;

    case MODE_DEBUG:
        printf("Emergency message to Ground\n");
        if(IsErrorManageable(storedErrors.getThrownErrors())){
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
}

// Adaptar funcao
int IsErrorManageable(std::vector<std::pair<ErrorHandler::ErrorSource, uint16_t>> error){
    return 1;
}

int IsAnError(int error){
    if(error != NO_error)
        return 1;
    else
        return 0;
}
