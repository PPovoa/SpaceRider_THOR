#include "THOR.hpp"

void Commissioning_Start(StoredErrors storedErrors, int* previousMode, int* nextMode){

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
    if(Detector_setup()){
        storedErrors.addError(ErrorHandler::DET_CantConnect);
        return;
    }
    
    printf("-Check individual subsystem of detector unit\n");
    //storedErrors.addError(ErrorHandler::DET_Subsytem_Cantconnect);

    printf("-Monitor Detector\n");
    printf("  Get Dead pixels\n");//storedErrors.addError(ErrorHandler::DET_ErrorGetDeadPixels);
    printf("  Get Temperature\n");//storedErrors.addError(ErrorHandler::DET_ErrorGetTemperature);
    printf("  Get Current drawn\n");//storedErrors.addError(ErrorHandler::DET_ErrorGetCurrent);
    printf("  Get Voltages levels\n");//storedErrors.addError(ErrorHandler::DET_ErrorGetVoltage);

    printf("Commissioning done!\n\n");

    *previousMode = *nextMode;
    *nextMode = MODE_HK;
}

int Detector_setup(void){
    int deviceIndex=0;

    // Initializes the Pixet and all connected devices
    int rc = pxcInitialize();
    if (rc) {
        printf("Could not initialize Pixet:\n");
        printErrors("pxcInitialize", rc);
        return 1;
    }

    int connectedDevicesCount = pxcGetDevicesCount();
    printf("Connected devices: %d\n", connectedDevicesCount);

    if (connectedDevicesCount == 0){pxcExit(); return 1;}

    for (unsigned devIdx = 0; (signed)devIdx < connectedDevicesCount; devIdx++){
        char deviceName[256];
        for (int n=0; n<256; n++) deviceName[n]=0;
        pxcGetDeviceName(devIdx, deviceName, 256);

        char chipID[256];
        for (int n=0; n<256; n++) chipID[n]=0;
        pxcGetDeviceChipID(devIdx, 0, chipID, 256);
        printf("Device %d: Name %s, (first ChipID: %s)\n", devIdx, deviceName, chipID);
    }

    pxcLoadDeviceConfiguration(deviceIndex, "./configs/MiniPIX-G05-W0085.xml");

    return 0;
}