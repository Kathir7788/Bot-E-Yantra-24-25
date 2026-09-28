#include <stdlib.h>
#include <stdbool.h>
#include <stdint.h>

#ifdef linux // for host pc

#include <stdio.h>

void _put_byte(char c) { putchar(c); }

void _put_str(char *str)
{
    while (*str)
    {
        _put_byte(*str++);
    }
}

void print_output(uint8_t num)
{
    if (num == 0)
    {
        putchar('0');
        _put_byte('\n');
        return;
    }

    char buffer[20];
    uint8_t index = 0;

    while (num > 0)
    {
        buffer[index++] = '0' + num % 10;
        num /= 10;
    }

    while (index > 0)
    {
        putchar(buffer[--index]);
    }
    _put_byte('\n');
}

void _put_value(uint8_t val) { print_output(val); }

#else // for the test device

void _put_value(uint8_t val) {}
void _put_str(char *str) {}

#endif

int main(int argc, char const *argv[])
{
#ifdef linux
    const uint8_t START_POINT = atoi(argv[1]);
    const uint8_t END_POINT = atoi(argv[2]);
    uint8_t NODE_POINT = 0;
    uint8_t CPU_DONE = 0;
    uint32_t cost_function[32];
    uint8_t distance[32];
    uint8_t previous_node[32];
#else
    #define START_POINT (*(volatile uint8_t *)0x02000000)
    #define END_POINT (*(volatile uint8_t *)0x02000004)
    #define NODE_POINT (*(volatile uint8_t *)0x02000008)
    #define CPU_DONE (*(volatile uint8_t *)0x0200000c)
    #define cost_function ((uint32_t *)0x02000010)
    #define distance ((uint8_t *)0x02000090)
    #define previous_node ((uint8_t *)0x020000b0)
#endif

    // Neighbor representation for each node: 0xXXYYZZWW, where
    // XX, YY, ZZ, and WW represent each neighbor or 0xFF if no neighbor
    cost_function[0]  = 0x010A06FF;
    cost_function[1]  = 0x020B00FF;
    cost_function[2]  = 0x01030405;
    cost_function[3]  = 0x02FFFFFF;

    cost_function[4]  = 0x02FFFFFF;
    cost_function[5]  = 0x02FFFFFF;
    cost_function[6]  = 0x00070809;
    cost_function[7]  = 0x06FFFFFF;

    cost_function[8]  = 0x06FFFFFF;
    cost_function[9]  = 0x06FFFFFF;
    cost_function[10] = 0x181A0B00;
    cost_function[11] = 0x0A0C1301;

    cost_function[12] = 0x0B0D0EFF;
    cost_function[13] = 0x0CFFFFFF;
    cost_function[14] = 0x0C0F10FF;
    cost_function[15] = 0x0EFFFFFF;

    cost_function[16] = 0x0E1112FF;
    cost_function[17] = 0x10FFFFFF;
    cost_function[18] = 0x101315FF;
    cost_function[19] = 0x12140BFF;

    cost_function[20] = 0x13FFFFFF;
    cost_function[21] = 0x121617FF;
    cost_function[22] = 0x15FFFFFF;
    cost_function[23] = 0x15181EFF;

    cost_function[24] = 0x17190AFF;
    cost_function[25] = 0x18FFFFFF;
    cost_function[26] = 0x0A1B1CFF;
    cost_function[27] = 0x1AFFFFFF;

    cost_function[28] = 0x1A1D1EFF;
    cost_function[29] = 0x1CFFFFFF;
    cost_function[30] = 0x171F1CFF;
    cost_function[31] = 0x1EFFFFFF;

    // Initialize distances to "infinity" (99) and set the end point distance to 0
    for (uint8_t i = 0; i < 32; i++) distance[i] = 99;
    distance[END_POINT] = 0;

    for (uint8_t j = 0; j < 32; j++){
        uint8_t idx = 0;
        for (uint8_t i = 1; i < 32; i++){
            if (distance[i] < distance[idx]){
                idx = i;
            }
        }

        for (uint8_t i = 0; i < 4; i++){
            uint8_t neighbor = (cost_function[idx] >> (8 * (3 - i))) & 0xFF;
            // if (neighbor == 0xFF) continue;
            if (distance[idx] + 1 < distance[neighbor] && distance[neighbor] != 98) {
                distance[neighbor] = distance[idx] + 1;
                previous_node[neighbor] = idx;
            }
        }
        distance[idx] = 98;
    }

    uint8_t temp = START_POINT; 
    while (true){
        NODE_POINT = temp;
        temp = previous_node[temp];
        
        if (temp == END_POINT)
        {
            NODE_POINT = temp;
            break;
        }
    }
    CPU_DONE = 1;

#ifdef linux // for host pc

    _put_str("######### Planned Path #########\n");
    temp = START_POINT;
    while(true){
        _put_value(temp);
        temp = previous_node[temp];
        
        if (temp == END_POINT)
        {
            _put_value(temp);
            break;
        }
    }
    _put_str("################################\n");

#endif

    return 0;
}