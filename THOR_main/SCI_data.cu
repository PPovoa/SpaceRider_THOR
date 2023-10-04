/**
 * Copyright (C) 2021 ADVACAM
 * @authors    Jan Ingerle <jan.ingerle@advacam.com>
 *             Pavel Hudecek <pavel.hudecek@advacam.com>
 * 
 * Data driven measuring examples
 */

#include "THOR.hpp"

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

// ======================================================
// Parameters:
//      measTime    - Measure Time in seconds
//      FilePath    - File path to store the data
// ======================================================
int ScientificData(double measTime, const char *FilePath) { // ###################################################

    // Performs a measurement in Data driven mode
    int rc; // return codes
    int deviceIndex = 0; // transmitted over pointer for use in the callback function 

    // working with TOA, TOATOT, TOT_NOTOA, not working with EVENT_ITOT
    // with TOT_NOTOA be carefully for threshold value
    rc = pxcSetTimepix3Mode(deviceIndex, PXC_TPX3_OPM_TOATOT);
    if(rc!=0) {printErrors("pxcSetTimepix3Mode", rc); return 1;}

    rc = pxcSetDeviceParameter(deviceIndex, PAR_DD_BLOCK_SIZE, 6000);
    printf("pxcSetDeviceParameter %d\n", rc);
    rc = pxcSetDeviceParameter(deviceIndex, PAR_DD_BUFF_SIZE, 100);
    //printf(", %d", rc);
    //rc = pxcSetDeviceParameter(deviceIndex, PAR_DCC_LEVEL, 80); 
    if(rc!=0) {printErrors(",", rc); return 1;}

    // First do the sensor refresh: Clean the chip for free charges.
    // In data-driven/callbacks mode, some chips can sometimes stop producing data
    //    in first measurement, if not refreshed before.
    // Alternatively can be used dummy measurement.
    printf("Refreshing sensor...\n");
    rc = pxcDoSensorRefresh(deviceIndex);
    if(rc!=0) {printErrors("pxcDoSensorRefresh", rc); return 1;}

    printf("Capturing...\n");
    //rc = pxcMeasureTpx3DataDrivenMode(deviceIndex, measTime, FilePath, PXC_TRG_NO, onTpx3Data, (intptr_t)&devIdx);
    rc = pxcMeasureTpx3DataDrivenMode(deviceIndex, measTime, FilePath, PXC_TRG_NO, 0, (intptr_t)&deviceIndex);
    if(rc!=0) {printErrors("pxcMeasureTpx3DataDrivenMode", rc); return 1;}

    pxcExit(); // Exit Pixet
    return 0;
}