#include "Menu_Funcs.h"

void Menu_Main(int connectedDevicesCount){
    int opcao = RESET_CYCLE;

    while(opcao != 0){
        do{
            printf("\nDevices connected: %d\n", connectedDevicesCount);
            printf("=====================\n");
            printf("        Menu Main\n");
            printf("=====================\n");
            printf("1 - Show all parameters\n");
            printf("2 - Menu Bias\n");
            printf("3 - Menu Threshold\n");
            printf("4 - Measurement\n");
            printf("5 - Check noisy pixels in a file\n");
            printf("0 - Exit\n");

            printf("\nOption: ");
            std::cin >> opcao;

            if(opcao<0 || opcao>4 || std::cin.fail()){
                std::cin.clear(); //clear bad input flag
                std::cin.ignore(std::numeric_limits<std::streamsize>::max(), '\n'); //discard input
                std::cout << "Invalid input; Please try again.\n";
                opcao = RESET_CYCLE;
            }
        }while(opcao == RESET_CYCLE);

        switch(opcao){
            case 1:
                (void)Show_allParameters(ChooseDevice(connectedDevicesCount));
                WaitforUser();
                break;
            case 2:
                (void)Menu_Bias(connectedDevicesCount);
                break;
            case 3:
                (void)Menu_Threshold(connectedDevicesCount);
                break;
            case 4:
                (void)Start_Measurement(ChooseDevice(connectedDevicesCount));
                break;
            case 5:
                (void)checkNoisyPixelsInFile(ChooseDevice(connectedDevicesCount));
                break;
            case 0:
                pxcExit();
                return;
        }
    }
}

void Menu_Bias(int connectedDevicesCount){
    int opcao = RESET_CYCLE;

    while(opcao != 0){
        do{
            printf("\nDevices connected: %d\n", connectedDevicesCount);
            printf("=================\n");
            printf("    Menu Bias\n");
            printf("=================\n");
            printf("1 - Check Bias\n");
            printf("2 - Change Bias (in progress...)\n");
            printf("0 - Exit\n");

            printf("\nOption: ");
            std::cin >> opcao;

            if(opcao<0 || opcao>2 || std::cin.fail()){
                std::cin.clear(); //clear bad input flag
                std::cin.ignore(std::numeric_limits<std::streamsize>::max(), '\n'); //discard input
                std::cout << "Invalid input; Please try again.\n";
                opcao = RESET_CYCLE;
            }

        }while(opcao == RESET_CYCLE);

        switch(opcao){
            case 1:
                (void)Show_Bias(ChooseDevice(connectedDevicesCount));
                break;
            case 2:
                break;
            case 0:
                return;
        }
        WaitforUser();
    }
}

void Menu_Threshold(int connectedDevicesCount){
    int opcao = RESET_CYCLE;

    while(opcao != 0){
        do{
            printf("\nDevices connected: %d\n", connectedDevicesCount);
            printf("=================\n");
            printf(" Menu Threshold\n");
            printf("=================\n");
            printf("1 - Check Threshold\n");
            printf("2 - Change Threshold (in progress...)\n");
            printf("0 - Exit\n");

            printf("\nOption: ");
            std::cin >> opcao;

            if(opcao<0 || opcao>2 || std::cin.fail()){
                std::cin.clear(); //clear bad input flag
                std::cin.ignore(std::numeric_limits<std::streamsize>::max(), '\n'); //discard input
                std::cout << "Invalid input; Please try again.\n";
                opcao = RESET_CYCLE;
            }

        }while(opcao == RESET_CYCLE);

        switch(opcao){
            case 1:
                (void)Show_Threshold(ChooseDevice(connectedDevicesCount));
                break;
            case 2:
                break;
            case 0:
                return;
        }
        WaitforUser();
    }
}

