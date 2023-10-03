#include "THOR.hpp"

int main(){
    int previousMode = 0, nextMode = MODE_COMMI;
    int error = NO_error;

    printf("Booting...\n\n");

    while(nextMode != EXIT_PROG){ // TEMP!!!!!!!!! to define!
        switch (nextMode)
        {
        case MODE_COMMI:
            error = Commissioning_Start(&previousMode, error, &nextMode);
            // What to do if commissioning has an error??
            break;
        
        case MODE_HK:
            error = Housekeeping_Start(&previousMode, error, &nextMode);
            break;
        
        case MODE_OBS:
            error = Observational_Start(&previousMode, error, &nextMode);
            break;
        
        case MODE_DEBUG:
            error = Debug_Start(&previousMode, error, &nextMode);
            nextMode = EXIT_PROG;
            break;
        
        case MODE_TEST://======================
            break;
        
        case MODE_REBOOT:
            printf("Rebooting...\n");
            nextMode = EXIT_PROG;
            break;
        
        default:// ?????????
            printf("default - THOR ????????\n\n");
            break;
        }
    }

    printf("\nExit Program\n");
    return 0;
}