#ifndef FUNCS_H
#define FUNCS_H

#include "pxcapi.h"

#include <iostream>     // std::cout, std::cin
#include <limits>
#include <stdio.h>
#include <atomic>       // std::atomic
#include <signal.h>     // struct sigaction
#include <pthread.h>    // pthread_t, pthread_create()
#include <ctime>        // std::time(), std::localtime()
#include <sys/stat.h>   // mkdir()
#include <chrono>       // std::chrono
#include <dirent.h>     // struct dirent
#include <vector>       // std::vector()
#include <chrono>       // std::chrono::high_resolution_clock::now(), std::chrono::duration<>

#define DIR_OUTPUTFILES         "./output-files/"

// Identify Noisy Pixels Function
#define NOISE_THRESHOLD         10
#define MAX_TOA_DIFF            80


#define PAR_DD_BUFF_SIZE        "DDBuffSize"    // Data Driven Buffer Size [MB], default 100
#define PAR_DD_BLOCK_SIZE       "DDBlockSize"   // Data Driven Block Size [B], default 66000
#define PAR_TRG_STG             "TrgStg"        // 0=logical 0, 1 = logical 1, 2 = rising edge, 3 = falling edge
#define PAR_DCC_LEVEL           "DataConsystencyCheckLevel"
// sensitivity on data timestamp discontinuity in % (temporary experimental function, not on all devices)

#define PAR_TEMP                "Temperature"
#define PAR_TEMP_CHIP           "TemperatureChip" 
#define PAR_TEMP_CPU            "TemperatureCpu"
#define PAR_TEMP_CHECK_IN_SW    "CheckMaxTempInSW"
#define PAR_TEMP_CHECK_IN_CPU   "CheckMaxChipTempInCPU"
#define PAR_DAC_TEMP            "DacTemp"

#define PAR_BIAS_SENSE_VOLT     "BiasSenseVoltage"
#define PAR_BIAS_SENSE_CURR     "BiasSenseCurrent"

#define RESET_CYCLE             -10


void handle_signal(int signal);
int SetupDetector();
void Show_allParameters(unsigned deviceIndex);
void Start_Measurement(unsigned deviceIndex);

void WaitforUser();
unsigned ChooseDevice(int connectedDevicesCount);

// Show_allParameters functions ====================
void Show_Temp(unsigned deviceIndex);
void Show_Bias(unsigned deviceIndex);
void Show_Threshold(unsigned deviceIndex);
void Show_DACs(unsigned deviceIndex);
void Change_Bias(unsigned deviceIndex, double *biasVoltage_Set);
void checkNoisyPixelsInFile(unsigned deviceIndex);

// Start_Measurement functions ====================
void timepix3DataDriven(unsigned deviceIndex, int totalTime, int intervalTime, std::string folderName);
void Housekeeping_HeaderFile(FILE* file, char date[], std::string fileName, double biasVoltage_Set, int totalTime, int intervalTime);
void Housekeeping2File(unsigned deviceIndex, FILE* Housekeeping_file, std::chrono::steady_clock::time_point clock_begin, int sequence_num, int max_sequences,  double biasVoltage_Set);
void Get_HousekeepingParams(unsigned deviceIndex, double *bias_volt, double *bias_curr, double *temp_cpu, double *temp_chip);
void Store_HousekeepingLog(FILE* file, double seconds, double bias_volt, double bias_curr, double temp_cpu, double temp_chip);
void Store_DACLog(unsigned deviceIndex, FILE* file);

void checkNoisyPixels(unsigned deviceIndex, std::string fileName);
__global__ void identifyNoisyPixels(uint32_t *matrixIndices, uint64_t *toaValues, int numEvents, int *NoisyPixels);
long Read_NumLinesFile(std::string fileName);
int Read_TxtRawFile(std::string fileName, uint32_t *index, uint16_t *tot, uint64_t *toa, uint8_t *ftoa, uint8_t *overflow);
void MallocCUDA(uint32_t **index, uint16_t **tot, uint64_t **toa, uint8_t **ftoa, uint8_t **overflow, uint32_t **d_index, uint64_t **d_toa, long numElements);





void onTpx3Data(intptr_t eventData, intptr_t userData);
void printErrors(const char* fName, int rc);

#endif