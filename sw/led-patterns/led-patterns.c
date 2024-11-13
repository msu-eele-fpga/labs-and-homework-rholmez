#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <stdbool.h>
#include <sys/mman.h> // for mmap
#include <fcntl.h>    // for file open flags
#include <unistd.h>   // for getting the page size

const uint32_t HPS_CONTROL_ADDRESS = 0xFF200000;
const uint32_t LED_CONTROL_ADDRESS = 0xFF200004;
const uint32_t BASE_PERIOD_ADDRESS = 0xFF200008;

Boolean verbose_flag = false;
volatile uint32_t *HPS_target_virtual_addr;
volatile uint32_t *BASE_target_virtual_addr;
volatile uint32_t *LED_target_virtual_addr;

void intHandler(int signal){
    printf("\nPutting FPGA back to hardware control mode \n");
    *HPS_target_virtual_addr = 0x0;
    exit(0); 
}

void print_usage() {
    printf("Usage: led-patterns [-h] [-v] [-p pattern1 time1 ...] [-f filename]\n");
    printf("Options:\n");
    printf("  -h        Show this help message and exit\n");
    printf("  -v        Enable verbose output\n");
    printf("            Output Example: LED pattern = 10011001 Display time = 1000 msec\n");
    printf("  -p        Specify LED patterns and display times\n");
    printf("            Input Example: pattern1 time1 pattern2 time2 pattern3 time3\n");
    printf("  -f FILE   Read patterns and times from a file\n");
}

void new_pattern(volatile uint32_t *led_target_virtual_addr, uint32_t pattern, uint32_t display_time){
    *led_target_virtual_addr = pattern;
    if(verbose_flag == true){
        printf("LED pattern: 0x%x, Display time: %u ms\n", pattern, display_time);
    }
    usleep(display_time*1000);
}

int main(int argc, char **argv) {
    signal(SIGINT, intHandler); //to customize what happens with CTL+C

    const size_t PAGE_SIZE = sysconf(_SC_PAGE_SIZE); 

    // Open the /dev/mem file, which is an image of the main system memory.
    int fd = open("/dev/mem", O_RDWR | O_SYNC);
    if (fd == -1) {
        fprintf(stderr, "failed to open /dev/mem.\n");
        return 1;
    }

    uint32_t page_aligned_addr = ADDRESS & ~(PAGE_SIZE - 1);
    printf("Memory addresses:\n");
    printf("  page aligned address = 0x%x\n", page_aligned_addr);

    // Map a page of physical memory into virtual memory.
    uint32_t *page_virtual_addr = (uint32_t *) mmap(NULL, PAGE_SIZE, PROT_READ | PROT_WRITE, MAP_SHARED, fd, page_aligned_addr);
    if (page_virtual_addr == MAP_FAILED) {
        fprintf(stderr, "failed to map memory.\n");
        return 1;
    }

    //printf("  page_virtual_addr = %p\n", page_virtual_addr);

    uint32_t HPS_offset_in_page = HPS_LED_CONTROL_ADDR & (PAGE_SIZE - 1);
    uint32_t BASE_offset_in_page = BASE_PERIOD_ADDR & (PAGE_SIZE - 1);
    uint32_t LED_offset_in_page = LED_REG_ADDR  & (PAGE_SIZE - 1);

    // Compute the virtual address corresponding to ADDRESS.
    *HPS_target_virtual_addr = page_virtual_addr + (HPS_offset_in_page / sizeof(uint32_t));
    *BASE_target_virtual_addr = page_virtual_addr + (BASE_offset_in_page / sizeof(uint32_t));
    *LED_target_virtual_addr = page_virtual_addr + (LED_offset_in_page / sizeof(uint32_t));

    int opt;
    while ((opt = getopt(argc,argv, "Hvp:f:")) != -1){
        switch (opt) {
            case 'h':
                print_usage();
                break;
            case 'v':
                verbose_flag = true;
                printf("in verbose mode\n")
                break;
            case 'p':
                *HPS_target_virtual_addr = 0x01;

                while(true){
                    //patterns stuff
                    for(int i = optind; i <argc-1; i += 2){
                        if(i+1<argc){
                            uint32_t pattern = strtoul(argv[i], NULL, 0);
                            uint32_t display_time = strtoul(argv[i + 1], NULL, 0);
                            new_pattern(led_target_virtual_addr, pattern, display_time);
                        }
                        else{
                            printf("incorrect input, try again.\n");
                            return 1;
                            break;
                        }
                    }
                }
                break;
            case 'f':
                *HPS_target_virtual_addr = 0x01;

                FILE *file_ptr = fopen(optarg,"r");
                if(file_ptr == NULL){
                    printf(optarg, "\n");
                    printf("FILE NOT FOUND\n");
                    return 1;
                }
                else
                {
                    printf("File opened successfully : ");
                    printf(optarg, "\n");
                    printf("\n");
                }

                uint32_t pattern;
                uint32_t time;
                char ch[11];
                while(fgets(ch,sizeof(ch), file_ptr) != NULL){
                    char *pattern_string = strtok(ch, " ");
                    char *time_string = strtok(NULL, " \n");

                    if(pattern_string != NULL ** delay_string != NULL){
                        pattern = strtoul(pattern_string, NULL, 16);
                        time = strtoul(time_string, NULL, 10);
                        new_pattern(led_target_virtual_addr, pattern, time);
                    }
                    else{
                        printf("Error. Make sure each line has a pattern and display time")
                    }
                }
                *HPS_target_virtual_addr = 0x00;
                break;
            
            case '?':
                printf("unknown command: %c\n", optopt);
                break;
        }
    }

    for(; optind < argc; optind++){
        printf("Something went wrong... \n");
    }

    return 0;
}