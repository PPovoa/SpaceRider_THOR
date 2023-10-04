#include "Funcs.h"

int SetupDetector(){
    int rc = pxcInitialize();
    if (rc) {
        printf("Could not initialize Pixet:\n");
        printErrors("pxcInitialize", rc);
        exit(0);
    }

    int connectedDevicesCount = pxcGetDevicesCount();
    printf("Connected devices: %d\n", connectedDevicesCount);

    if (connectedDevicesCount == 0){pxcExit(); exit(0);}

    for (unsigned devIdx = 0; (signed)devIdx < connectedDevicesCount; devIdx++){
        char deviceName[256];
        for (int n=0; n<256; n++) deviceName[n]=0;
        pxcGetDeviceName(devIdx, deviceName, 256);

        char chipID[256];
        for (int n=0; n<256; n++) chipID[n]=0;
        pxcGetDeviceChipID(devIdx, 0, chipID, 256);
        printf("Device %d: Name %s, (first ChipID: %s)\n", devIdx, deviceName, chipID);
    }
    
    return connectedDevicesCount;
}

void Show_allParameters(unsigned deviceIndex){
    Show_Temp(deviceIndex);
    Show_Bias(deviceIndex);
    Show_Threshold(deviceIndex);
    //Show_DACs(deviceIndex);
}

void Start_Measurement(unsigned deviceIndex){
    int totalTime, intervalTime; //Measure time in seconds
    std::string folderName;

    do{
        printf("Enter total measure time in secs: ");
        std::cin >> totalTime;

        if(totalTime<=0 || std::cin.fail()){
            std::cin.clear(); //clear bad input flag
            std::cin.ignore(std::numeric_limits<std::streamsize>::max(), '\n'); //discard input
            std::cout << "Invalid input; Please try again.\n";
            totalTime = 0;
        }
    }while(totalTime == 0);


    do{
        printf("Enter duration of each interval in secs: ");
        std::cin >> intervalTime;

        if(intervalTime<=0 || std::cin.fail()){
            std::cin.clear(); //clear bad input flag
            std::cin.ignore(std::numeric_limits<std::streamsize>::max(), '\n'); //discard input
            std::cout << "Invalid input; Please try again.\n";
            intervalTime = 0;
        }
    }while(intervalTime == 0);


    printf("Enter name of folder: ");
    std::cin >> folderName;

    timepix3DataDriven(deviceIndex, totalTime, intervalTime, folderName);
}


void WaitforUser(){
    std::cin.clear(); //clear bad input flag
    std::cin.ignore(std::numeric_limits<std::streamsize>::max(), '\n'); //discard input
    std::cout << "Press any key to continue...";
    std::cin.get();
}

unsigned ChooseDevice(int connectedDevicesCount){
    unsigned deviceIdx;
    if (connectedDevicesCount==1){
        return 0;
    }
    else{
        do{
            printf("Choose the device index (from 0 to %d): ", connectedDevicesCount);
            std::cin >> deviceIdx;
        
            if(deviceIdx>=connectedDevicesCount || std::cin.fail()){
                std::cin.clear(); //clear bad input flag
                std::cin.ignore(std::numeric_limits<std::streamsize>::max(), '\n'); //discard input
                std::cout << "Invalid input; Please try again.\n";
                deviceIdx = 99;// reset cycle
            }
        }while(deviceIdx == 99);
        return deviceIdx;
    }
}

// Show_allParameters functions ====================
void Show_Temp(unsigned deviceIndex){
    double val;
    int rc;

    rc = pxcGetDeviceParameterDouble(deviceIndex, PAR_TEMP_CHIP, &val);
    if(rc)printErrors("pxcGetDeviceParameterDouble - PAR_TEMP_CHIP", rc);
    else printf("CHIP temperature: %f\n", val);

    rc = pxcGetDeviceParameterDouble(deviceIndex, PAR_TEMP_CPU, &val);
    if(rc)printErrors("pxcGetDeviceParameterDouble - PAR_TEMP_CPU", rc);
    else printf("CPU temperature: %f\n", val);

    /*rc = pxcGetDeviceParameterDouble(deviceIndex, PAR_TEMP_CHECK_IN_SW, &val);
    if(rc)printErrors("pxcGetDeviceParameterDouble - PAR_TEMP_CHECK_IN_SW", rc);
    else printf("Max temperature SW: %f\n", val);

    rc = pxcGetDeviceParameterDouble(deviceIndex, PAR_TEMP_CHECK_IN_CPU, &val);
    if(rc)printErrors("pxcGetDeviceParameterDouble - PAR_TEMP_CHECK_IN_CPU", rc);
    else printf("Max temperature CPU: %f\n", val);*/
}

void Show_Bias(unsigned deviceIndex){
    double val;
    int rc;

    rc = pxcGetDeviceParameterDouble(deviceIndex, PAR_BIAS_SENSE_VOLT, &val);
    if(rc) printErrors("pxcGetDeviceParameterDouble", rc);
    else printf("Bias Voltage (V): %f\n", val);

    rc = pxcGetDeviceParameterDouble(deviceIndex, PAR_BIAS_SENSE_CURR, &val);
    if(rc) printErrors("pxcGetDeviceParameterDouble", rc);
    else printf("Bias Current (uA): %f\n", val);
}

void Show_Threshold(unsigned deviceIndex){
    double val;
    int rc;

    rc = pxcGetThreshold(deviceIndex, 0, &val);
    if(rc) printErrors("pxcGetDeviceParameterDouble", rc);
    else printf("Threshold: %f\n", val);
}

// not in use
void Show_DACs(unsigned deviceIndex){
    unsigned short val;
    int rc;
    unsigned idxChip = 0;
    unsigned width, height;

    int opcao;
    if(pxcGetDeviceChipCount(deviceIndex)>1){
        do{
            rc = pxcGetDeviceDimensions(deviceIndex, &width, &height);
            if(rc) printErrors("pxcGetDeviceDimensions", rc);

            
            printf("Select chip index: ");
            std::cin >> idxChip;

            if(idxChip>=width*height || std::cin.fail()){
                std::cin.clear(); //clear bad input flag
                std::cin.ignore(std::numeric_limits<std::streamsize>::max(), '\n'); //discard input
                std::cout << "Invalid input; Choose between 0 - " << width*height << ". Please try again.\n";
                opcao = RESET_CYCLE;
            }
            
        }while(opcao == RESET_CYCLE);
    }

    rc = pxcGetDAC(deviceIndex, idxChip, PXC_TPX3_IBIAS_PREAMP_ON, &val);
    if(rc) printErrors("pxcGetDAC - PXC_TPX3_IBIAS_PREAMP_ON", rc);
    else printf("DAC of chip %d - PXC_TPX3_IBIAS_PREAMP_ON: %hu\n", idxChip, val);
}

void Change_Bias(unsigned deviceIndex, double *biasVoltage_Set){
    int rc;
    double maxBiasVoltage, minBiasVoltage;

    rc = pxcGetBiasRange(deviceIndex, &minBiasVoltage, &maxBiasVoltage);
    if(rc!=0) printErrors("pxcGetBiasRange", rc);

    do{
        printf("Enter bias voltage in volts: ");
        std::cin >> *biasVoltage_Set;

        if(*biasVoltage_Set < minBiasVoltage || *biasVoltage_Set > maxBiasVoltage || std::cin.fail()){
            std::cin.clear(); //clear bad input flag
            std::cin.ignore(std::numeric_limits<std::streamsize>::max(), '\n'); //discard input
            std::cout << "Invalid input; Please try again.\n";
        }
    }while(*biasVoltage_Set < minBiasVoltage || *biasVoltage_Set > maxBiasVoltage);

    rc = pxcSetBias(deviceIndex, *biasVoltage_Set);
    if(rc!=0) printErrors("pxcSetBias", rc);

}

void checkNoisyPixelsInFile(unsigned deviceIndex){

    int opcao = RESET_CYCLE;
    DIR *dir = opendir(DIR_OUTPUTFILES);
    struct dirent *entry;
    std::vector<std::string> fileNames;
    std::string extension = ".t3pa";
    int i=0;

    printf("All files in the output directory\n");
    
    if (dir == nullptr ) {
        printf("Error opening output directory\n");
        return;
    }
    
    while ((entry = readdir(dir))) {
        std::string fileName = entry->d_name;
        if(fileName.size() >= extension.size() && fileName.substr(fileName.size() - extension.size()) == extension){
            std::cout << i + 1 << ". " << entry->d_name << "\n";
            fileNames.push_back(fileName);
            i++;
        }
    }

    closedir(dir);

    do{
        printf("\nSelect one file from 1 to %d (-1 to exit): ", i);
        std::cin >> opcao;

        if(opcao == -1) return;

        if(opcao<1 || opcao>i || std::cin.fail()){
            std::cin.clear(); //clear bad input flag
            std::cin.ignore(std::numeric_limits<std::streamsize>::max(), '\n'); //discard input
            std::cout << "Invalid input; Please try again.\n";
            opcao = RESET_CYCLE;
        }
        
    }while(opcao == RESET_CYCLE);

    auto start = std::chrono::high_resolution_clock::now();
    checkNoisyPixels(deviceIndex, std::string(DIR_OUTPUTFILES) + fileNames[opcao-1]);
    auto end = std::chrono::high_resolution_clock::now();

    // Calculate the duration and output it
    std::chrono::duration<double> duration = end - start;
    std::cout << "Execution time: " << duration.count() << " seconds" << std::endl;

    return;
}

// ====================


// Start_Measurement functions ====================
void timepix3DataDriven(unsigned deviceIndex, int totalTime, int intervalTime, std::string folderName){
    int rc; // return codes
    int devIdx = deviceIndex; // transmitted over pointer for use in the callback function 
    
    double biasVoltage_Set;
    Change_Bias(deviceIndex, &biasVoltage_Set);

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



    // get todays date (YYYY-mm-DD_HH-MM) and insert into files name and measured time
    std::time_t t = std::time(nullptr);
    char date[30];
    std::strftime(date, sizeof(date), "%Y-%m-%d", std::localtime(&t));

    std::string folderDir = std::string(DIR_OUTPUTFILES) + folderName;
    if(mkdir(folderDir.c_str(), 0777) != 0){
        printf("Directory %s failed to create\n", folderDir.c_str());
        return;
    }

    std::string Path_CreateFolder = folderDir + "/RawData";
    if(mkdir(Path_CreateFolder.c_str(), 0777) != 0){
        printf("Directory %s failed to create\n", Path_CreateFolder.c_str());
        return;
    }



    std::string rawFilePath = folderDir + "/RawData/" + folderName;
    std::string HousekeepingFilePath = folderDir + "/Housekeeping_log_" + folderName + "_" + std::string(date) + ".txt";
    //std::string DACFilePath = folderDir + "/DAC_log_" + folderName + "_"  + std::string(date) + ".txt";
    printf("\nFile saved in: %s\n", rawFilePath.c_str());

    printf("Total Time: %d seconds\n", totalTime);
    printf("Time interval: %d seconds\n", intervalTime);

    FILE* HousekeepingFile = std::fopen(HousekeepingFilePath.c_str(), "w");
    if (!HousekeepingFile){
        printf("Error opening the file %s\n", HousekeepingFilePath.c_str());
    }
    Housekeeping_HeaderFile(HousekeepingFile, date, folderName, biasVoltage_Set, totalTime, intervalTime);


    /*FILE* DACFile = std::fopen(DACFilePath.c_str(), "w");
    if (!DACFile){
        printf("Error opening the file %s\n", DACFilePath.c_str());
    }*/


    std::string interationFile;
    std::chrono::steady_clock::time_point clock_begin = std::chrono::steady_clock::now();

    int max_sequences = totalTime/intervalTime;
    for(int i=0; i<max_sequences; i++){
        interationFile = rawFilePath + "_" + std::to_string(i) + ".t3pa";
        //rc = pxcMeasureTpx3DataDrivenMode(deviceIndex, intervalTime, interationFile.c_str(), PXC_TRG_NO, onTpx3Data, (intptr_t)&devIdx);
        rc = pxcMeasureTpx3DataDrivenMode(deviceIndex, intervalTime, interationFile.c_str(), PXC_TRG_NO, 0, (intptr_t)&devIdx);
        if(rc!=0) printErrors("pxcMeasureTpx3DataDrivenMode", rc);

        Housekeeping2File(deviceIndex, HousekeepingFile, clock_begin, i+1, max_sequences, biasVoltage_Set);
        //printf("Sequence %i of %d done.\n", i+1, max_sequences);

        checkNoisyPixels(deviceIndex, interationFile);
    }

    std::fclose(HousekeepingFile);
    //std::fclose(DACFile);  
}

void Housekeeping_HeaderFile(FILE* file, char date[], std::string fileName, double biasVoltage_Set, int totalTime, int intervalTime){

    fprintf(file, "logfile created at %s\n", date);
    fprintf(file, "\nfilename: %s\n", fileName.c_str());
    fprintf(file, "total acquisition time: %d seconds\n", totalTime);
    fprintf(file, "duration of each interval: %d seconds\n", intervalTime);
    fprintf(file, "bias input voltage: %.2f V\n", biasVoltage_Set);

    fprintf(file, "\ntimestamp | chip (ºC) | cpu (ºC) | bias sense voltage (V) | bias sense current (µA)\n");
    printf("\nSequence | timestamp | chip (ºC) | cpu (ºC) | bias sense voltage (V) | bias sense current (µA)\n");
}

void Housekeeping2File(unsigned deviceIndex, FILE* Housekeeping_file, std::chrono::steady_clock::time_point clock_begin, int sequence_num, int max_sequences, double biasVoltage_Set){
    
    auto clock_now = std::chrono::steady_clock::now();
    std::chrono::duration<double> elapsedSeconds = clock_now - clock_begin;
    double seconds = elapsedSeconds.count();

    double bias_volt, bias_curr;
    double temp_cpu, temp_chip;
    Get_HousekeepingParams(deviceIndex, &bias_volt, &bias_curr, &temp_cpu, &temp_chip);
    Store_HousekeepingLog(Housekeeping_file, seconds, bias_volt, bias_curr, temp_cpu, temp_chip);
    //Store_DACLog(deviceIndex, DAC_file);

    printf("%3d/%-3d    %-9.3f   %-10.2f  %-8.2f   %-22.2f   %-23.2f\n", sequence_num, max_sequences, seconds, temp_chip, temp_cpu, bias_volt, bias_curr);

    /*printf("Temperature chip: %.2f ºC\n", temp_chip);
    printf("Temperature cpu: %.2f ºC\n", temp_cpu);
    printf("Bias set voltage: %.2f V\n", biasVoltage_Set);
    printf("Bias sense voltage: %.2f V\n", bias_volt);
    printf("Bias sense current: %.2f µA\n", bias_curr);*/
}

void Get_HousekeepingParams(unsigned deviceIndex, double *bias_volt, double *bias_curr, double *temp_cpu, double *temp_chip){
    int rc;

    rc = pxcGetDeviceParameterDouble(deviceIndex, PAR_BIAS_SENSE_VOLT, bias_volt);
    if(rc) printErrors("Get_HousekeepingParams - PAR_BIAS_SENSE_VOLT", rc);

    rc = pxcGetDeviceParameterDouble(deviceIndex, PAR_BIAS_SENSE_CURR, bias_curr);
    if(rc) printErrors("Get_HousekeepingParams - PAR_BIAS_SENSE_CURR", rc);

    rc = pxcGetDeviceParameterDouble(deviceIndex, PAR_TEMP_CHIP, temp_chip);
    if(rc)printErrors("Get_HousekeepingParams - PAR_TEMP_CHIP", rc);

    rc = pxcGetDeviceParameterDouble(deviceIndex, PAR_TEMP_CPU, temp_cpu);
    if(rc) printErrors("Get_HousekeepingParams - PAR_TEMP_CPU", rc);
}

void Store_HousekeepingLog(FILE* file, double seconds, double bias_volt, double bias_curr, double temp_cpu, double temp_chip){
    std::fprintf(file, "%-9.3f   %-10.2f  %-8.2f   %-22.2f   %-23.2f\n", seconds, temp_chip, temp_cpu, bias_volt, bias_curr);
}

// not in use
void Store_DACLog(unsigned deviceIndex, FILE* file){
    unsigned short value; // u16

    pxcGetDAC(deviceIndex, 0, PXC_TPX3_IBIAS_PREAMP_ON, &value);
    if(fprintf(file, "%hu ", value)==0){
        printf("Error saving DAC parameter -> PXC_TPX3_IBIAS_PREAMP_ON\n");
    }

    pxcGetDAC(deviceIndex, 0, PXC_TPX3_IBIAS_PREAMP_OFF, &value);
    if(fprintf(file, "%hu ", value)==0){
        printf("Error saving DAC parameter -> PXC_TPX3_IBIAS_PREAMP_OFF\n");
    }

    pxcGetDAC(deviceIndex, 0, PXC_TPX3_VPREAMP_NCAS, &value);
    if(fprintf(file, "%hu ", value)==0){
        printf("Error saving DAC parameter -> PXC_TPX3_VPREAMP_NCAS\n");
    }

    pxcGetDAC(deviceIndex, 0, PXC_TPX3_IBIAS_IKRUM, &value);
    if(fprintf(file, "%hu ", value)==0){
        printf("Error saving DAC parameter -> PXC_TPX3_IBIAS_IKRUM\n");
    }

    pxcGetDAC(deviceIndex, 0, PXC_TPX3_VFBK, &value);
    if(fprintf(file, "%hu ", value)==0){
        printf("Error saving DAC parameter -> PXC_TPX3_VFBK\n");
    }

    pxcGetDAC(deviceIndex, 0, PXC_TPX3_VTHRESHOLD, &value);
    if(fprintf(file, "%hu ", value)==0){
        printf("Error saving DAC parameter -> PXC_TPX3_VTHRESHOLD\n");
    }

    pxcGetDAC(deviceIndex, 0, PXC_TPX3_IBIAS_DISCS1_ON, &value);
    if(fprintf(file, "%hu ", value)==0){
        printf("Error saving DAC parameter -> PXC_TPX3_IBIAS_DISCS1_ON\n");
    }

    pxcGetDAC(deviceIndex, 0, PXC_TPX3_IBIAS_DISC1_OFF, &value);
    if(fprintf(file, "%hu ", value)==0){
        printf("Error saving DAC parameter -> PXC_TPX3_IBIAS_DISC1_OFF\n");
    }

    pxcGetDAC(deviceIndex, 0, PXC_TPX3_IBIAS_DISCS2_ON, &value);
    if(fprintf(file, "%hu ", value)==0){
        printf("Error saving DAC parameter -> PXC_TPX3_IBIAS_DISCS2_ON\n");
    }

    pxcGetDAC(deviceIndex, 0, PXC_TPX3_IBIAS_DISCS2_OFF, &value);
    if(fprintf(file, "%hu ", value)==0){
        printf("Error saving DAC parameter -> PXC_TPX3_IBIAS_DISCS2_OFF\n");
    }

    pxcGetDAC(deviceIndex, 0, PXC_TPX3_IBIAS_PIXELDAC, &value);
    if(fprintf(file, "%hu ", value)==0){
        printf("Error saving DAC parameter -> PXC_TPX3_IBIAS_PIXELDAC\n");
    }

    pxcGetDAC(deviceIndex, 0, PXC_TPX3_IBIAS_TPBUFF_IN, &value);
    if(fprintf(file, "%hu ", value)==0){
        printf("Error saving DAC parameter -> PXC_TPX3_IBIAS_TPBUFF_IN\n");
    }

    pxcGetDAC(deviceIndex, 0, PXC_TPX3_IBIAS_TPBUFF_OUT, &value);
    if(fprintf(file, "%hu ", value)==0){
        printf("Error saving DAC parameter -> PXC_TPX3_IBIAS_TPBUFF_OUT\n");
    }

    pxcGetDAC(deviceIndex, 0, PXC_TPX3_VTP_COARSE, &value);
    if(fprintf(file, "%hu ", value)==0){
        printf("Error saving DAC parameter -> PXC_TPX3_VTP_COARSE\n");
    }

    pxcGetDAC(deviceIndex, 0, PXC_TPX3_VTP_FINE, &value);
    if(fprintf(file, "%hu ", value)==0){
        printf("Error saving DAC parameter -> PXC_TPX3_VTP_FINE\n");
    }

    pxcGetDAC(deviceIndex, 0, PXC_TPX3_IBIAS_CP_PLL, &value);
    if(fprintf(file, "%hu ", value)==0){
        printf("Error saving DAC parameter -> PXC_TPX3_IBIAS_CP_PLL\n");
    }

    pxcGetDAC(deviceIndex, 0, PXC_TPX3_PLL_VCNTRL, &value);
    if(fprintf(file, "%hu\n", value)==0){
        printf("Error saving DAC parameter -> PXC_TPX3_PLL_VCNTRL\n");
    }

}


void checkNoisyPixels(unsigned deviceIndex, std::string fileName){

    int getError, rc;

    uint32_t *index, *d_index;
    uint16_t *tot;
    uint64_t *toa, *d_toa;
    uint8_t *ftoa, *overflow;
    int* d_noisyPixels;

    unsigned width, height;
    rc = pxcGetDeviceDimensions(deviceIndex, &width, &height);
    if(rc){
        printErrors("pxcGetDeviceDimensions", rc);
        return;
    }
    else printf("Width: %d\nHeigth: %d\n", width, height);

    int numPixels = width*height;//256*256;     // Number of distinct index values (number of pixels in detetor)
    
    long numElements = Read_NumLinesFile(fileName);
    int blockSize = 512;
    int gridSize = ceil((double)(numElements + blockSize - 1) / (double)blockSize);

    //printf("\nBlock size: %d\nGrid size: %d\n", blockSize, gridSize);

    MallocCUDA(&index, &tot, &toa, &ftoa, &overflow, &d_index, &d_toa, numElements);

    cudaMalloc(&d_noisyPixels, numPixels * sizeof(int));
    cudaMemset(d_noisyPixels, 0, numPixels * sizeof(int));

    //printf("Reading %s\n", fileName.c_str());

    getError = Read_TxtRawFile(fileName, index, tot, toa, ftoa, overflow);
    if(getError){
        printf("Error! Read_RawFile()\n");
        return;
    }

    cudaMemcpy(d_index, index, numElements * sizeof(uint32_t), cudaMemcpyHostToDevice);
    // Launch the kernel to identify noisy pixels
    identifyNoisyPixels<<<gridSize, blockSize>>>(d_index, d_toa, numPixels, d_noisyPixels);

    // Copy noisy pixel counters back to the host
    int* h_NoisyPixels = new int[numPixels];
    cudaMemcpy(h_NoisyPixels, d_noisyPixels, numPixels * sizeof(int), cudaMemcpyDeviceToHost);

    unsigned char maskMatrix[numPixels];
    rc = pxcGetPixelMaskMatrix(deviceIndex, maskMatrix, sizeof(maskMatrix));
    if(rc!=0) printErrors("pxcGetPixelMaskMatrix", rc);

    // noisy pixel information
    for (int i = 0; i < numPixels; ++i){
        if (h_NoisyPixels[i] >= NOISE_THRESHOLD) {
            printf("Pixel %d is masked with count %d\n" , i, h_NoisyPixels[i]);
            maskMatrix[i]=PXC_PIXEL_MASKED;
            rc = pxcSetPixelMaskMatrix(deviceIndex, maskMatrix, sizeof(maskMatrix));
            if(rc!=0) printErrors("pxcSetPixelMaskMatrix", rc);
        }
    }
   
    // Cleanup: Free memory and release resources
    cudaFreeHost(index);
    cudaFreeHost(tot);
    cudaFreeHost(toa);
    cudaFreeHost(ftoa);
    cudaFreeHost(overflow);
    cudaFreeHost(h_NoisyPixels);
    cudaFree(d_index);
    cudaFree(d_toa);
    cudaFree(d_noisyPixels);
}

__global__
void identifyNoisyPixels(uint32_t *matrixIndices, uint64_t *toaValues, int numEvents, int *NoisyPixels) {
    int tid = threadIdx.x + blockIdx.x * blockDim.x;

    while (tid < numEvents) {
        int matrixIndex = matrixIndices[tid];
        int toa = toaValues[tid];

        // Iterate over previous events and check if the same index pixel was active within MAX_TOA_DIFF
        for (int i = tid - 1; i >= 0; --i){
            if (matrixIndices[i] == matrixIndex && (toa - toaValues[i]) <= MAX_TOA_DIFF) {
                atomicAdd(&NoisyPixels[matrixIndex], 1); // Increment the noisy pixel counter
                break; // No need to check further, as the condition is satisfied
            }
        }

        tid += blockDim.x * gridDim.x;
    }
}

long Read_NumLinesFile(std::string fileName){
    long number_of_lines = 0;
    FILE *infile = fopen(fileName.c_str(), "r");
    int ch;

    if (infile == nullptr)
        printf("Read_NumLinesFile - Error in opening file\n");

    while (EOF != (ch=getc(infile)))
        if ('\n' == ch)
            ++number_of_lines;
    //printf("%u\n", number_of_lines-1);

    return number_of_lines-1;
}

int Read_TxtRawFile(std::string fileName, uint32_t *index, uint16_t *tot, uint64_t *toa, uint8_t *ftoa, uint8_t *overflow){
    FILE *fp;

    fp = fopen(fileName.c_str(), "r");

    if (fp == NULL) {
        printf("Error opening file\n");
        return 1;
    }

    // Ignore first line - header
    char line[100];
    fgets(line, 100, fp);

    // Read remaining lines and convert values to numbers
    int i=0, value;
    while (fscanf(fp, "%d %u %lu %hu %hhu %hhu", &value, &index[i], &toa[i], &tot[i], &ftoa[i], &overflow[i]) == 6){
        i++;
        if (i%10000000==0){
            printf(".");
            fflush(stdout); // colocar se não usar \n
        }
    }
    printf("\n");
    
    fclose(fp);

    return 0;
}

void MallocCUDA(uint32_t **index, uint16_t **tot, uint64_t **toa, uint8_t **ftoa, uint8_t **overflow, uint32_t **d_index, uint64_t **d_toa, long numElements){
    // HOST PINNED
    cudaMallocHost((void**)index, numElements*sizeof(uint32_t));
    cudaMallocHost((void**)tot, numElements*sizeof(uint16_t));
    cudaMallocHost((void**)toa, numElements*sizeof(uint64_t));
    cudaMallocHost((void**)ftoa, numElements*sizeof(uint8_t));
    cudaMallocHost((void**)overflow, numElements*sizeof(uint8_t));

    cudaMalloc((void**)d_index, numElements*sizeof(uint32_t));
    cudaMalloc((void**)d_toa, numElements*sizeof(uint64_t));
}

// ====================================







// ================================

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

    /*if(!running.load(std::memory_order_relaxed)){
        printf("Aborting Measurement...\n");
        pxcAbortMeasurement(deviceIndex);
    }*/
    /*
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
            //maskMatrix[*it]=PXC_PIXEL_MASKED; // does not work in the middle of the measurement!
            //rc = pxcSetPixelMaskMatrix(deviceIndex, maskMatrix, sizeof(maskMatrix));
            //if(rc!=0) printErrors("pxcSetPixelMatrix", rc);
            printf("%d ", *it);
        }
        printf("\n");
    }
    */
}

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