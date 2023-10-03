#ifndef THOR_H
#define THOR_H 

#include <stdio.h>

#define NO_error            0
#define SR_MMU_error        1
#define OBC_MMU_error       2
#define PDU_error           3
#define DET_error           4
#define DET_Subsys_error    5

#define MODE_COMMI  11
#define MODE_HK     12
#define MODE_OBS    13
#define MODE_DEBUG  14
#define MODE_TEST   15
#define MODE_REBOOT 16
#define EXIT_PROG   99

#define DET_MAX_TEMP_THRESH 50 // Max temperature before considering overheating
#define DET_MIN_TEMP_THRESH 40 // Temp to turn on the components in case of overheat
#define DET_MAX_VOLT_THRESH 1  // Max voltage before considering arc discarging


// Commissioning.c
int Commissioning_Start(int* previousMode, int error_fromMode, int* nextMode);
int Connections_checkup(void);

// Housekeeping.c
int Housekeeping_Start(int* previousMode, int error_fromMode, int* nextMode);
int IsErrorManageable(int error);
int IsAnError(int error);

// Observational.c
int Observational_Start(int* previousMode, int error_fromMode, int* nextMode);

// Debug.c
int Debug_Start(int* previousMode, int error_fromMode, int* nextMode);
int isAffecting_SCI_operations(int error);// to finish
int isAffecting_PL_operations(int error);// to finish
int isErrorBearable(int error); // to finish

#endif