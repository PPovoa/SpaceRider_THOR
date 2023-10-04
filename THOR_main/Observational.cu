#include "THOR.hpp"

void Observational_Start(StoredErrors storedErrors, int* previousMode, int* nextMode){
    
    int measTime = 5; // Measure time in seconds

    printf("\nObservational mode ====\n");

    printf("OBC turns ON Detector Unit\n"); //storedErrors.addError(ErrorHandler::DET_CantConnect);
    printf("PDUs' power outputs\n"); //storedErrors.addError(ErrorHandler::PDU_CantConnect);
    printf("Detector Unit configuration of operation mode\n"); //storedErrors.addError(ErrorHandler::DET_ConfigMode);

    while(*nextMode == MODE_OBS){
        printf("-Monitor Detector\n");
        printf("  Get Temperature\n");//storedErrors.addError(ErrorHandler::DET_ErrorGetTemperature);
        printf("  Get Current drawn\n");//storedErrors.addError(ErrorHandler::DET_ErrorGetCurrent);
        printf("  Get Voltages levels\n");//storedErrors.addError(ErrorHandler::DET_ErrorGetVoltage);

        double DET_temp = 0.0; // Temporary!!!
        double DET_volt = 0.0; // Temporary!!!

        if(DET_temp > DET_MAX_TEMP_THRESH){
            while(DET_temp > DET_MIN_TEMP_THRESH){
                printf("Trun OFF component until certain threshold\n");
                printf("Turn ON component\n");
                printf("report to ground\n");
            }
        }

        if(DET_volt > DET_MAX_VOLT_THRESH){
            printf("Trun OFF components\n");
            printf("report to ground\n");
        }

        printf("If the error is persistence go to Debug mode\n"); // what is consider persistence?
        //*nextMode = MODE_DEBUG;
        //break;

        printf("Scientific Data collection\n");
        printf("  Data storage\n");
        printf("  Data processing\n");
        printf("  Communications with MMU\n");

        
        const char *FilePath = {"./output-files/RawData_5s.t3p"};// Automate name of the file!!!!!!!!!!!
        if(ScientificData(measTime, FilePath))
            storedErrors.addError(ErrorHandler::DET_CantConnect);
        
        printf("If bug identified go to Debug mode\n"); // what is consider a bug?
        *nextMode = MODE_DEBUG;
        //break;
    }
}