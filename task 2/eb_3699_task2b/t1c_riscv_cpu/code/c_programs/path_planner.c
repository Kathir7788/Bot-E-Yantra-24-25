/*
* EcoMender Bot (EB): Task 2B Path Planner
*
* This program computes the valid path from the start point to the end point.
* Make sure you don't change anything outside the "Add your code here" section.
*/

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
    int8_t cost_function[32][4] ;
    uint8_t distance[32];
    uint8_t previous_node[32];
#else
    #define START_POINT (*(volatile uint8_t *)0x02000000)
    #define END_POINT (*(volatile uint8_t *)0x02000004)
    #define NODE_POINT (*(volatile uint8_t *)0x02000008)
    #define CPU_DONE (*(volatile uint8_t *)0x0200000c)
    #define cost_function ((uint8_t (*)[4])0x02000010)
    #define distance ((uint8_t *)0x02000090)
    #define previous_node ((uint8_t *)0x020000b0)
#endif

    cost_function[0][0] = 1; cost_function[0][1] = 10; cost_function[0][2] = 6; cost_function[0][3] = -1;
    cost_function[1][0] = 2; cost_function[1][1] = 11; cost_function[1][2] = 0; cost_function[1][3] = -1;
    cost_function[2][0] = 1; cost_function[2][1] = 3; cost_function[2][2] = 4; cost_function[2][3] = 5;
    cost_function[3][0] = 2; cost_function[3][1] = -1; cost_function[3][2] = -1; cost_function[3][3] = -1;
    cost_function[4][0] = 2; cost_function[4][1] = -1; cost_function[4][2] = -1; cost_function[4][3] = -1;
    cost_function[5][0] = 2; cost_function[5][1] = -1; cost_function[5][2] = -1; cost_function[5][3] = -1;
    cost_function[6][0] = 0; cost_function[6][1] = 7; cost_function[6][2] = 8; cost_function[6][3] = 9;
    cost_function[7][0] = 6; cost_function[7][1] = -1; cost_function[7][2] = -1; cost_function[7][3] = -1;
    cost_function[8][0] = 6; cost_function[8][1] = -1; cost_function[8][2] = -1; cost_function[8][3] = -1;
    cost_function[9][0] = 6; cost_function[9][1] = -1; cost_function[9][2] = -1; cost_function[9][3] = -1;
    cost_function[10][0] = 0; cost_function[10][1] = 24; cost_function[10][2] = 26; cost_function[10][3] = 11;
    cost_function[11][0] = 1; cost_function[11][1] = 12; cost_function[11][2] = 19; cost_function[11][3] = 10;
    cost_function[12][0] = 11; cost_function[12][1] = 13; cost_function[12][2] = 14; cost_function[12][3] = -1;
    cost_function[13][0] = 12; cost_function[13][1] = -1; cost_function[13][2] = -1; cost_function[13][3] = -1;
    cost_function[14][0] = 12; cost_function[14][1] = 15; cost_function[14][2] = 16; cost_function[14][3] = -1;
    cost_function[15][0] = 14; cost_function[15][1] = -1; cost_function[15][2] = -1; cost_function[15][3] = -1;
    cost_function[16][0] = 14; cost_function[16][1] = 17; cost_function[16][2] = 18; cost_function[16][3] = -1;
    cost_function[17][0] = 16; cost_function[17][1] = -1; cost_function[17][2] = -1; cost_function[17][3] = -1;
    cost_function[18][0] = 16; cost_function[18][1] = 19; cost_function[18][2] = 21; cost_function[18][3] = -1;
    cost_function[19][0] = 20; cost_function[19][1] = 11; cost_function[19][2] = 18; cost_function[19][3] = -1;
    cost_function[20][0] = 19; cost_function[20][1] = -1; cost_function[20][2] = -1; cost_function[20][3] = -1;
    cost_function[21][0] = 18; cost_function[21][1] = 22; cost_function[21][2] = 23; cost_function[21][3] = -1;
    cost_function[22][0] = 21; cost_function[22][1] = -1; cost_function[22][2] = -1; cost_function[22][3] = -1;
    cost_function[23][0] = 21; cost_function[23][1] = 24; cost_function[23][2] = 30; cost_function[23][3] = -1;
    cost_function[24][0] = 23; cost_function[24][1] = 25; cost_function[24][2] = 10; cost_function[24][3] = -1;
    cost_function[25][0] = 24; cost_function[25][1] = -1; cost_function[25][2] = -1; cost_function[25][3] = -1;
    cost_function[26][0] = 10; cost_function[26][1] = 27; cost_function[26][2] = 28; cost_function[26][3] = -1;
    cost_function[27][0] = 26; cost_function[27][1] = -1; cost_function[27][2] = -1; cost_function[27][3] = -1;
    cost_function[28][0] = 26; cost_function[28][1] = 29; cost_function[28][2] = 30; cost_function[28][3] = -1;
    cost_function[29][0] = 28; cost_function[29][1] = -1; cost_function[29][2] = -1; cost_function[29][3] = -1;
    cost_function[30][0] = 23; cost_function[30][1] = 28; cost_function[30][2] = 31; cost_function[30][3] = -1;
    cost_function[31][0] = 30; cost_function[31][1] = -1; cost_function[31][2] = -1; cost_function[31][3] = -1;

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
            uint8_t neighbor = cost_function[idx][i];
            if (neighbor == -1) continue;
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
        // _put_value(temp);
        temp = previous_node[temp];
        
        if (temp == END_POINT)
        {
            NODE_POINT = temp;
            // _put_value(temp);
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
    // for(int i = 0;i<5;i++) _put_value(temp[i]);
    _put_str("################################\n");

#endif

    return 0;
}
