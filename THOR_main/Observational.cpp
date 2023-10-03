#include "THOR.hpp"

int Observational_Start(int* previousMode, int error_fromMode, int* nextMode){
    int error=NO_error;

    printf("\nObservational mode ====\n");

    printf("OBC turns ON Detector Unit & PDUs' power outputs\n");
    printf("Detector Unit operation mode configuration\n");

    while(*nextMode == MODE_OBS){
        printf("-Monitor Detector\n");
        printf("  Get Temperature\n");
        printf("  Get Current drawn\n");
        printf("  Get Voltages levels\n");
        if(error!=NO_error)
            return error;

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

        printf("If bug identified go to Debug mode\n"); // what is consider bug?
        *nextMode = MODE_DEBUG;
        //break;
    }

    return error;
}