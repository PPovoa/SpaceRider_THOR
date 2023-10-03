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
        if(isAffecting_SCI_operations(storedErrors)){
            if(isErrorBearable(storedErrors)){
                printf("Emergency message to Ground\n");
                *nextMode = MODE_OBS;
            }
            else{
                *nextMode = MODE_HK;
            }
        }
        else{
            *nextMode = MODE_OBS;
        }

    }
    else{ // unkown error
        if(isAffecting_PL_operations(storedErrors)){
            printf("Emergency message to Ground\n");
            *nextMode = MODE_HK;
        }
        else{
            if(isErrorBearable(storedErrors)){
                printf("Emergency message to Ground\n");
                *nextMode = MODE_OBS;
            }
            else{
                printf("Emergency message to Ground\n");
                *nextMode = MODE_HK;
            }
        }
    }
}

int isErrorKnown(StoredErrors storedErrors){
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