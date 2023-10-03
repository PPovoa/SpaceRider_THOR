#include "THOR.hpp"

int Debug_Start(int* previousMode, int error_fromMode, int* nextMode){
    int error = NO_error;

    printf("\nDebug mode ====\n");

    printf("-Monitor PDU\n");
    printf("  Get Temperature\n");
    printf("  Get Current drawn\n");
    printf("  Get Voltages levels\n");
    if(error!=NO_error)
        return error;

    printf("-Monitor OBC\n");
    printf("  Get Temperature\n");
    if(error!=NO_error)
        return error;


    // DEFINIR CONDICAO PARA "KNOWN ERROR" !!!!!!!!!!!
    if(error_fromMode >=1 & error_fromMode <= 5){ // known error
        if(isAffecting_SCI_operations(error_fromMode)){
            if(isErrorBearable(error_fromMode)){
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
        if(isAffecting_PL_operations(error_fromMode)){
            printf("Emergency message to Ground\n");
            *nextMode = MODE_HK;
        }
        else{
            if(isErrorBearable(error_fromMode)){
                printf("Emergency message to Ground\n");
                *nextMode = MODE_OBS;
            }
            else{
                printf("Emergency message to Ground\n");
                *nextMode = MODE_HK;
            }
        }
    }
    return error;
}

// to finish
int isAffecting_SCI_operations(int error){
    return 0;
}

// to finish
int isAffecting_PL_operations(int error){
    return 0;
}

// to finish
int isErrorBearable(int error){
    return 0;
}