#ifndef THOR_H
#define THOR_H 

#include <iostream>
#include <stdio.h>
#include <stdint.h>
#include <type_traits> // is_same<>
#include <vector>
#include <map>

#include "pxcapi.h"

#define NO_error            99
/*#define SR_MMU_error        1
#define OBC_MMU_error       2
#define PDU_error           3
#define DET_error           4
#define DET_Subsys_error    5*/

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

#define PAR_DD_BUFF_SIZE    "DDBuffSize"    // Data Driven Buffer Size [MB], default 100
#define PAR_DD_BLOCK_SIZE   "DDBlockSize"   // Data Driven Block Size [B], default 66000
#define PAR_TRG_STG         "TrgStg"        // 0=logical 0, 1 = logical 1, 2 = rising edge, 3 = falling edge
#define PAR_DCC_LEVEL       "DataConsystencyCheckLevel"
// sensitivity on data timestamp discontinuity in % (temporary experimental function, not on all devices)
#define PAR_TEMP_CHIP       "TemperatureChip" 
#define PAR_TEMP_CPU        "TemperatureCpu"

class ErrorHandler {
public:
    enum MainErrorType{
        Unknown_MainError = 0,
       
        SR_MMU_CantConnect = 1,

        OBC_MMU_CantConnect = 2,

        DET_CantConnect = 3,

        PDU_CantConnect = 4,

        DET_Subsytem_Cantconnect = 5,

        PDU_ErrorGetOuputState = 6,

        PDU_ErrorGetTemperature = 7,

        PDU_ErrorGetCurrent = 8,

        PDU_ErrorGetVoltage = 9,

        DET_ErrorGetDeadPixels = 10,

        DET_ErrorGetTemperature = 11,

        DET_ErrorGetCurrent = 12,

        DET_ErrorGetVoltage = 13,

        DET_ConfigMode = 14,
    };

    enum CommissioningErrorType{
        Unknown_CommissioningError = 0,
    };

    enum HousekeepingErrorType{
        Unknown_HousekeepingError = 0,
    };

    enum ObservationalErrorType{
        Unknown_ObservationalError = 0,
    };

    enum DebugErrorType{
        Unknown_DebugError = 0,
    };

    enum ErrorSource{
        Main,
        Commisioning,
        Housekeeping,
        Observational,
        Debug,
    };

    template <typename ErrorType>
    inline static ErrorSource findErrorSource(ErrorType errorType){
        // Static type checking
        ErrorSource source = Main; // default Main

        if(std::is_same<ErrorType, CommissioningErrorType>()) {
            source = Commisioning;
        }
        else if(std::is_same<ErrorType, HousekeepingErrorType>()) {
            source = Housekeeping;
        }
        else if(std::is_same<ErrorType, ObservationalErrorType>()) {
            source = Observational;
        }
        else if(std::is_same<ErrorType, DebugErrorType>()) {
            source = Debug;
        }

        return source;
    }

};

class StoredErrors{
protected:
    static std::multimap<std::pair<ErrorHandler::ErrorSource, uint16_t>, bool> thrownErrors;

public:
    static void addError(ErrorHandler::ErrorSource errorSource, uint16_t errorCode) {
        thrownErrors.emplace(std::make_pair(errorSource, errorCode), 1);
    }
    
    template <typename ErrorType>
    static void addError(ErrorType errorToReport) {
        ErrorHandler::ErrorSource errorSource = ErrorHandler::findErrorSource(errorToReport);
        uint16_t errorCode = errorToReport;
        thrownErrors.emplace(std::make_pair(errorSource, errorCode), 1);
    }


    static void resetErrors() {
		thrownErrors.clear();
	}

    static bool hasNoErrors() {
		return thrownErrors.empty();
	}

    static uint64_t countErrors() {
		return thrownErrors.size();
	}

    static std::vector<std::pair<ErrorHandler::ErrorSource, uint16_t>> getThrownErrors() {
		std::vector<std::pair<ErrorHandler::ErrorSource, uint16_t>> errors;

		for (auto error : thrownErrors) {
			errors.push_back(error.first);
		}

		return errors;
	}

    // for testing!!!!!!!!!!!
    static void showErrors(){
        if(StoredErrors::hasNoErrors()) printf("No errors\n");
        
        for (const auto& pair : thrownErrors) {
            const auto& errorPair = pair.first;
            //bool errorValue = pair.second;

            std::cout << "Error Source: " << errorPair.first << ", "
                    << "Error Code: " << errorPair.second << std::endl;
        }
    }
};

// Commissioning.cu
void Commissioning_Start(StoredErrors storedErrors, int* previousMode, int* nextMode);
int Detector_setup(void);

// Housekeeping.cu
void Housekeeping_Start(StoredErrors storedErrors, int* previousMode, int error_fromMode, int* nextMode);
int IsErrorManageable(std::vector<std::pair<ErrorHandler::ErrorSource, uint16_t>> error);
int IsAnError(int error);

// Observational.cu
void Observational_Start(StoredErrors storedErrors, int* previousMode, int* nextMode);

// Debug.cu
void Debug_Start(StoredErrors storedErrors, int* previousMode, int* nextMode);
void ManageErrors(StoredErrors storedErrors, int* previousMode, int* nextMode);
int isErrorKnown(StoredErrors storedErrors);
int isAffecting_SCI_operations(StoredErrors storedErrors);// to finish
int isAffecting_PL_operations(StoredErrors storedErrors);// to finish
int isErrorBearable(StoredErrors storedErrors); // to finish

// SCI_data.cu
void printErrors(const char* fName, int rc); // to delete
int ScientificData (double measTime, const char *FilePath);

#endif