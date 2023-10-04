#include "THOR.hpp"

std::multimap<std::pair<ErrorHandler::ErrorSource, uint16_t>, bool> StoredErrors::thrownErrors;

int main(){
    int previousMode = 0, nextMode = MODE_COMMI;
    int error = NO_error;
    StoredErrors storedErrors;

    printf("Booting...\n\n");

    while(nextMode != EXIT_PROG){
        switch (nextMode)
        {
        case MODE_COMMI:
            Commissioning_Start(storedErrors, &previousMode, &nextMode);
            // What to do if commissioning has an error??
            break;
        
        case MODE_HK:
            Housekeeping_Start(storedErrors, &previousMode, error, &nextMode);
            break;
        
        case MODE_OBS:
            Observational_Start(storedErrors, &previousMode, &nextMode);
            break;
        
        case MODE_DEBUG:
            Debug_Start(storedErrors, &previousMode, &nextMode);
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

        if(!storedErrors.hasNoErrors()){
            nextMode = MODE_DEBUG;
        }
    }

    printf("\nExit Program\n");
    return 0;
}