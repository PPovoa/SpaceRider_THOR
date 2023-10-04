#include "THOR.hpp"

void Debug_Start(StoredErrors storedErrors, int* previousMode, int* nextMode){

    printf("\nDebug mode ====\n");

    printf("-Monitor PDU\n");
    printf("  Get Temperature\n");//storedErrors.addError(ErrorHandler::PDU_ErrorGetTemperature);
    printf("  Get Current drawn\n");//storedErrors.addError(ErrorHandler::PDU_ErrorGetCurrent);
    printf("  Get Voltages levels\n");//storedErrors.addError(ErrorHandler::PDU_ErrorGetVoltage);

    printf("-Monitor OBC\n");
    printf("  Get Temperature\n");//storedErrors.addError(ErrorHandler::DET_ErrorGetTemperature);

    // DEFINIR CONDICAO PARA "KNOWN ERROR" !!!!!!!!!!!
    if(isErrorKnown(storedErrors)){ // known error
        ManageErrors(storedErrors, previousMode, nextMode);
        storedErrors.resetErrors();
        /*if(isAffecting_SCI_operations(storedErrors)){
            if(isErrorBearable(storedErrors)){
                printf("Emergency message to Ground\n");
                *previousMode = *nextMode;
                *nextMode = MODE_OBS;
            }
            else{
                *previousMode = *nextMode;
                *nextMode = MODE_HK;
            }
        }
        else{
            *previousMode = *nextMode;
            *nextMode = MODE_OBS;
        }*/
        
    }
    else{ // unkown error
        if(isAffecting_PL_operations(storedErrors)){
            printf("Emergency message to Ground\n");
            *previousMode = *nextMode;
            *nextMode = MODE_HK;
            storedErrors.resetErrors();
            return;
        }

        if(isErrorBearable(storedErrors)){
            printf("Emergency message to Ground\n");
            *previousMode = *nextMode;
            *nextMode = MODE_OBS;
            storedErrors.resetErrors();
            return;
        }
        
        printf("Emergency message to Ground\n");
        *previousMode = *nextMode;
        *nextMode = MODE_HK;
        storedErrors.resetErrors();
    }
}

void ManageErrors(StoredErrors storedErrors, int* previousMode, int* nextMode){

    std::vector<std::pair<ErrorHandler::ErrorSource, uint16_t>> CurrErrors = storedErrors.getThrownErrors();

    for (const auto& error : CurrErrors) {
        //ErrorHandler::ErrorSource errorSource = error.first;
        uint16_t errorCode = error.second;

        switch (errorCode)
        {
        case ErrorHandler::SR_MMU_CantConnect:
            printf("SR_MMU error\n");
            break;
        case ErrorHandler::OBC_MMU_CantConnect:
            printf("OBC_MMU error\n");
            break;
        case ErrorHandler::PDU_CantConnect:
            printf("PDU error\n");
            break;
        case ErrorHandler::DET_CantConnect:
            printf("DET error\n");
            break;
        case ErrorHandler::DET_Subsytem_Cantconnect:
            printf("DET_Subsys error\n");
            break;
        case ErrorHandler::PDU_ErrorGetOuputState:
            printf("PDU_GetOuputState error\n");
            break;
        case ErrorHandler::PDU_ErrorGetTemperature:
            printf("PDU_GetTemperature error\n");
            break;
        case ErrorHandler::PDU_ErrorGetCurrent:
            printf("PDU_GetCurrent error\n");
            break;
        case ErrorHandler::PDU_ErrorGetVoltage:
            printf("PDU_GetVoltage error\n");
            break;
        case ErrorHandler::DET_ErrorGetDeadPixels:
            printf("DET_GetDeadPixels error\n");
            break;
        case ErrorHandler::DET_ErrorGetTemperature:
            printf("DET_GetTemperature error\n");
            break;
        case ErrorHandler::DET_ErrorGetCurrent:
            printf("DET_GetCurrent error\n");
            break;
        case ErrorHandler::DET_ErrorGetVoltage:
            printf("DET_GetVoltage error\n");
            break;            

        default:
            printf("????????\n\n");
            break;
        }

        storedErrors.showErrors();
        
        *previousMode = *nextMode;
        *nextMode = EXIT_PROG;//MODE_HK;
    }
}


int isErrorKnown(StoredErrors storedErrors){

    std::vector<std::pair<ErrorHandler::ErrorSource, uint16_t>> CurrErrors = storedErrors.getThrownErrors();

    for (const auto& error : CurrErrors) {
        //ErrorHandler::ErrorSource errorSource = error.first;
        uint16_t errorCode = error.second;
        if (errorCode == 0) return 0;
    }
    return 1;
}

// to finish
int isAffecting_SCI_operations(StoredErrors storedErrors){
    return 0;
}

// to finish
int isAffecting_PL_operations(StoredErrors storedErrors){
    return 0;
}

// to finish
int isErrorBearable(StoredErrors storedErrors){
    return 0;
}
