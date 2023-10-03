#include "THOR.hpp"

void Commissioning_Start(StoredErrors storedErrors, int* previousMode, int* nextMode){

    Connections_checkup(storedErrors);

    if(storedErrors.hasNoErrors()){
        printf("Commissioning done!\n\n");
        *previousMode = *nextMode;
        *nextMode = MODE_HK;
    }
    else{
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
        }

        storedErrors.showErrors();
        
        *previousMode = *nextMode;
        *nextMode = EXIT_PROG;//MODE_HK;
    }
}

void Connections_checkup(StoredErrors storedErrors){

    printf("\nCommissioning mode ====\n");
    
    printf("-Check Connection to SR_MMU\n");
    printf("  Time sync with SR_MMU\n");
    //storedErrors.addError(ErrorHandler::SR_MMU_CantConnect);

    printf("-Check access to OBC_MMU\n");
    //storedErrors.addError(ErrorHandler::OBC_MMU_CantConnect);

    printf("-Check Connection to PDU\n");
    //storedErrors.addError(ErrorHandler::PDU_CantConnect);

    printf("-Monitor PDU\n");
    printf("  Get Output state\n");//storedErrors.addError(ErrorHandler::PDU_ErrorGetOuputState);
    printf("  Get Temperature\n");//storedErrors.addError(ErrorHandler::PDU_ErrorGetTemperature);
    printf("  Get Current drawn\n");//storedErrors.addError(ErrorHandler::PDU_ErrorGetCurrent);
    printf("  Get Voltages levels\n");//storedErrors.addError(ErrorHandler::PDU_ErrorGetVoltage);

    printf("-Check connection to the detector unit\n");
    //storedErrors.addError(ErrorHandler::DET_CantConnect);

    printf("-Check individual subsystem of detector unit\n");
    //storedErrors.addError(ErrorHandler::DET_Subsytem_Cantconnect);

    printf("-Monitor Detector\n");
    printf("  Get Dead pixels\n");//storedErrors.addError(ErrorHandler::DET_ErrorGetDeadPixels);
    printf("  Get Temperature\n");//storedErrors.addError(ErrorHandler::DET_ErrorGetTemperature);
    printf("  Get Current drawn\n");//storedErrors.addError(ErrorHandler::DET_ErrorGetCurrent);
    printf("  Get Voltages levels\n");//storedErrors.addError(ErrorHandler::DET_ErrorGetVoltage);
}