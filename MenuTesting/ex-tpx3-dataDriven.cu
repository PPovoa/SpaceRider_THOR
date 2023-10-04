/**
 * Copyright (C) 2021 ADVACAM
 * @authors    Jan Ingerle <jan.ingerle@advacam.com>
 *             Pavel Hudecek <pavel.hudecek@advacam.com>
 * 
 * Data driven measuring examples
 */

#include "Funcs_DD.h"

// ARRANJAR FORMA DE PARAR A ACQUISIÇÃO DE DADOS ( pxcAbortMeasurement(unsigned deviceIndex) )

// use to show fn name, return code, and last error message
void printErrors(const char* fName, int rc) { // ===============================================
    const int ERRMSG_BUFF_SIZE = 512;
    char errorMsg[ERRMSG_BUFF_SIZE];

    pxcGetLastError(errorMsg, ERRMSG_BUFF_SIZE);
    if (errorMsg[0]>0) {
        printf("%s %d err: %s\n", fName, rc, errorMsg);
    } else {
        printf("%s %d err: ---\n", fName, rc);
    }
}

void Thread_Processing(const char *FilePath){
    DataProcessing(FilePath);
}

// callback function for data processing, used by pxcMeasureTpx3DataDrivenMode
void onTpx3Data(intptr_t eventData, intptr_t userData) { // ====================================
    int deviceIndex = *((unsigned*)userData);
    unsigned pixelCount = 0;
    static unsigned long long pixelSum = 0;
    static int calls=0;
    int rc; // return code
    rc = pxcGetMeasuredTpx3PixelsCount(deviceIndex, &pixelCount);
    if(rc!=0) printErrors("pxcGetMeasuredTpx3PixelsCount", rc);

    
    static unsigned char maskMatrix[256*256];
    rc = pxcGetPixelMaskMatrix(deviceIndex, maskMatrix, sizeof(maskMatrix));
    if(rc!=0) printErrors("pxcGetPixelMaskMatrix", rc);


    calls++;
    pixelSum += pixelCount;
    if (eventData!=0) { //eventData!=NULL
        printf("(rc= %d, eventData=(pointer: %lu, view method not defined)) PixelCount: %u PixelSum: %llu\n", rc, (unsigned long)eventData, pixelCount, pixelSum);
    } else {
        printf("(rc= %d, eventData=NULL) calls: %d pxCnt: %u pxSum: %llu\n", rc, calls, pixelCount, pixelSum);
    }
    
    static Tpx3Pixel pxData[1000000];
    rc = pxcGetMeasuredTpx3Pixels(deviceIndex, pxData, 1000000);
    if(rc!=0) printErrors("pxcGetMeasuredTpx3Pixels", rc);



    // Check for pixels that were called two time in a row.
    std::vector<int>::iterator it, ls;
    static std::vector<int> OldValues(1000000);
    std::vector<int> DupPixels(1000000);

    std::vector<int> NewValues(pixelCount);
    std::transform(pxData, pxData+pixelCount, NewValues.begin(),
                [](const Tpx3Pixel& pixel) { return pixel.index; });

    std::sort(NewValues.begin(), NewValues.end());

    ls = std::set_intersection(OldValues.begin(), OldValues.end(), NewValues.begin(), NewValues.end(), DupPixels.begin());

    OldValues.clear(); // clear all values
    OldValues.insert(OldValues.begin(), NewValues.begin(), NewValues.end()); // copy NewValues to OldValues
    
    OldValues.erase(std::unique(OldValues.begin(), OldValues.end()), OldValues.end()); //remove duplicates
    //DupPixels.erase(std::unique(DupPixels.begin(), DupPixels.end()), DupPixels.end()); //remove duplicates

    // Print all duplicates
    long int numDuplicates=ls-DupPixels.begin();
    if(numDuplicates != 0){
        pxcAbortMeasurement(deviceIndex); // ABORT MEASUREMENT!!!!!
        printf("\tDuplicates: %ld\n\t", numDuplicates);
        for (it=DupPixels.begin(); it!=ls; ++it){
            //maskMatrix[*it]=PXC_PIXEL_MASKED;
            //rc = pxcSetPixelMaskMatrix(deviceIndex, maskMatrix, sizeof(maskMatrix));
            //if(rc!=0) printErrors("pxcSetPixelMatrix", rc);
            printf("%d ", *it);
        }
        printf("\n");
    }
    
}


// test of pxcMeasureTpx3DataDrivenMode - using callback
// ======================================================
// Parameters:
//      deviceIndex - Device ID
//      measTime    - Measure Time in seconds
//      FilePath    - File path to store the data
// ======================================================
void timepix3DataDrivenGetPixelsTest(unsigned deviceIndex, double measTime, const char *FilePath) { // ================================
    int rc; // return codes
    int devIdx = deviceIndex; // transmitted over pointer for use in the callback function 

    // working with TOA, TOATOT, TOT_NOTOA, not working with EVENT_ITOT
    // with TOT_NOTOA be carefully for threshold value
    rc = pxcSetTimepix3Mode(deviceIndex, PXC_TPX3_OPM_TOATOT);
    if(rc!=0) printErrors("pxcSetTimepix3Mode", rc);

    rc = pxcSetDeviceParameter(deviceIndex, PAR_DD_BLOCK_SIZE, 6000);
    printf("pxcSetDeviceParameter %d\n", rc);
    rc = pxcSetDeviceParameter(deviceIndex, PAR_DD_BUFF_SIZE, 100);
    //printf(", %d", rc);
    //rc = pxcSetDeviceParameter(deviceIndex, PAR_DCC_LEVEL, 80); 
    if(rc!=0) printErrors(",", rc);

    // First do the sensor refresh: Clean the chip for free charges.
    // In data-driven/callbacks mode, some chips can sometimes stop producing data
    //    in first measurement, if not refreshed before.
    // Alternatively can be used dummy measurement.
    printf("Refreshing sensor...\n");
    rc = pxcDoSensorRefresh(deviceIndex);
    if(rc!=0) printErrors("pxcDoSensorRefresh", rc);

    printf("Capturing...\n");
    //rc = pxcMeasureTpx3DataDrivenMode(deviceIndex, measTime, FilePath, PXC_TRG_NO, onTpx3Data, (intptr_t)&devIdx);
    rc = pxcMeasureTpx3DataDrivenMode(deviceIndex, measTime, FilePath, PXC_TRG_NO, 0, (intptr_t)&devIdx);
    if(rc!=0) printErrors("pxcMeasureTpx3DataDrivenMode", rc);
}

// ======================================================
// Parameters:
//      measTime    - Measure Time in seconds
//      FilePath    - File path to store the data
// ======================================================
int ScientificData (double measTime, const char *FilePath) { // ###################################################
    int deviceIndex=0;

    // Initializes the Pixet and all connected devices
    int rc = pxcInitialize();
    if (rc) {
        printf("Could not initialize Pixet:\n");
        printErrors("pxcInitialize", rc);
        return -1;
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


    pxcLoadDeviceConfiguration(deviceIndex, "/home/ppovoa/Work/Space_Rider/Programs/MenuTesting/configs/MiniPIX-G05-W0085.xml");


    // Mask pixel with index 50904
    unsigned char maskMatrix[256*256];
    rc = pxcGetPixelMaskMatrix(deviceIndex, maskMatrix, sizeof(maskMatrix));
    if(rc!=0) printErrors("pxcGetPixelMaskMatrix", rc);
    maskMatrix[50904]=PXC_PIXEL_MASKED;
    rc = pxcSetPixelMaskMatrix(deviceIndex, maskMatrix, sizeof(maskMatrix));
    if(rc!=0) printErrors("pxcSetPixelMaskMatrix", rc);
    

    // Performs a measurement in Data driven mode
    timepix3DataDrivenGetPixelsTest(deviceIndex, measTime, FilePath);


    //std::thread t(Thread_Processing, FilePath); // processing the last file created
    //if (t.joinable()) t.join(); // wait until the processing is done

    return pxcExit(); // Exit Pixet
}




/*
    static unsigned char maskMatrix[256*256];
    rc = pxcGetPixelMaskMatrix(deviceIndex, maskMatrix, sizeof(maskMatrix));
    if(rc!=0) printErrors("pxcGetPixelMaskMatrix", rc);

    // Check for pixels that were called two time in a row.
    std::vector<int>::iterator it, ls;
    static std::vector<int> OldValues(1000000);
    std::vector<int> DupPixels(1000000);

    std::vector<int> NewValues(pixelCount);
    std::transform(pxData, pxData+pixelCount, NewValues.begin(),
                [](const Tpx3Pixel& pixel) { return pixel.index; });

    std::sort(NewValues.begin(), NewValues.end());

    ls = std::set_intersection(OldValues.begin(), OldValues.end(), NewValues.begin(), NewValues.end(), DupPixels.begin());

    OldValues.clear(); // clear all values
    OldValues.insert(OldValues.begin(), NewValues.begin(), NewValues.end()); // copy NewValues to OldValues
    
    OldValues.erase(std::unique(OldValues.begin(), OldValues.end()), OldValues.end()); //remove duplicates
    //DupPixels.erase(std::unique(DupPixels.begin(), DupPixels.end()), DupPixels.end()); //remove duplicates

    // Print all duplicates
    long int numDuplicates=ls-DupPixels.begin();
    if(numDuplicates != 0){
        printf("\tDuplicates: %ld\n\t", numDuplicates);
        for (it=DupPixels.begin(); it!=ls; ++it){
            //maskMatrix[*it]=PXC_PIXEL_MASKED;
            //rc = pxcSetPixelMaskMatrix(deviceIndex, maskMatrix, sizeof(maskMatrix));
            //if(rc!=0) printErrors("pxcSetPixelMatrix", rc);
            printf("%d ", *it);
        }
        printf("\n");
    }
*/