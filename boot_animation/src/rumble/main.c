#include <getopt.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>

void set_rumble_level(int level) {
    if (level < 0 || level > 100)
    {
        printf("Error: Level must be between 0 and 100\n");
        return;
    }

    char* filename = "/sys/class/power_supply/battery/moto";
    char data[4];

    snprintf(data, sizeof(data), "%d", level);
    FILE* file = fopen(filename, "w");

    if (file)
    {
        fwrite(data, sizeof(char), strlen(data), file);
        fclose(file);
    }
    else
    {
        printf("Error: Could not open %s\n", filename);
    }
}

int main(int argc, char *argv[]) {
    int s_value = 0, t_value = 0;
    int c;

    while ((c = getopt(argc, argv, "s:t:")) != -1)
    {
        switch (c)
        {
            case 's':
                s_value = atoi(optarg);
                break;
            case 't':
                t_value = atoi(optarg);
                break;
            default:
                printf("Usage: %s -s [integer] -t [integer]\n", argv[0]);
                exit(0);
        }
    }

    set_rumble_level(s_value);
    sleep(t_value);
    set_rumble_level(0);

    return 0;
}
