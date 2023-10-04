#include "Menu_Funcs.h"

int main (int argc, char const* argv[]) {
    
    int rc;
    int connectedDevicesCount = SetupDetector();

    printf("Load default config of device 0\n");
    rc = pxcLoadDeviceConfiguration(0, "/home/ppovoa/Work/Space_Rider/Programs/MenuTesting/configs/MiniPIX-G05-W0085.xml");
    if (rc) printErrors("pxcLoadDeviceConfiguration", rc);

    Menu_Main(connectedDevicesCount);

    return 0;
}