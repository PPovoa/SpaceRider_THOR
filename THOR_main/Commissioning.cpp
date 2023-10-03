#include "THOR.hpp"

int Commissioning_Start(int* previousMode, int error_fromMode, int* nextMode){
    int error = Connections_checkup();

    switch (error_fromMode)
    {
    case NO_error:
        printf("Commissioning done!\n\n");
        *previousMode = *nextMode;
        *nextMode = MODE_HK;
        break;
    case SR_MMU_error:
        printf("SR_MMU error\n");
        break;
    case OBC_MMU_error:
        printf("OBC_MMU error\n");
        break;
    case PDU_error:
        printf("PDU error\n");
        break;
    case DET_error:
        printf("DET error\n");
        break;
    case DET_Subsys_error:
        printf("DET_Subsys error\n");
        break;
    default:
        printf("????????\n\n");
        break;
    }

    return error;
}

int Connections_checkup(void){
    int error = NO_error;

    printf("\nCommissioning mode ====\n");

    printf("-Check Connection to SR_MMU\n");
    printf("  Time sync with SR_MMU\n");
    if(error!=NO_error)
        return error;

    printf("-Check access to OBC_MMU\n");
    if(error!=NO_error)
        return error;

    printf("-Check Connection to PDU\n");
    if(error!=NO_error)
        return error;

    printf("-Monitor PDU\n");
    printf("  Get Output state\n");
    printf("  Get Temperature\n");
    printf("  Get Current drawn\n");
    printf("  Get Voltages levels\n");
    if(error!=NO_error)
        return error;

    printf("-Check connection to the detector unit\n");
    if(error!=NO_error)
        return error;

    printf("-Check individual subsystem of detector unit\n");
    if(error!=NO_error)
        return error;

    printf("-Monitor Detector\n");
    printf("  Get Dead pixels\n");
    printf("  Get Temperature\n");
    printf("  Get Current drawn\n");
    printf("  Get Voltages levels\n");
    if(error!=NO_error)
        return error;

    return error;
}