#include <stdint.h>
#include <stdbool.h>
#include <limits.h>
#include <stdlib.h>
#include <stdio.h>

uint32_t e(uint8_t neighbor1, uint8_t weight1, 
           uint8_t neighbor2, uint8_t weight2,
           uint8_t neighbor3, uint8_t weight3,
           uint8_t neighbor4, uint8_t weight4) {
    return (neighbor1 & 0x1F) |  // 5 bits for neighbor1
           ((weight1 & 0x07) << 5) | // 3 bits for weight1, shifted 5 bits
           ((neighbor2 & 0x1F) << 8) | // 5 bits for neighbor2
           ((weight2 & 0x07) << 13) | // 3 bits for weight2, shifted 13 bits
           ((neighbor3 & 0x1F) << 16) | // 5 bits for neighbor3
           ((weight3 & 0x07) << 21) | // 3 bits for weight3, shifted 21 bits
           ((neighbor4 & 0x1F) << 24) | // 5 bits for neighbor4
           ((weight4 & 0x07) << 29);  // 3 bits for weight4, shifted 29 bits
}
int main(){
uint32_t graph[32]={0};
graph[7] = e(6,1,0,0,0,0,0,0);     //7
graph[8] = e(6,1,0,0,0,0,0,0);     //8
graph[9] = e(6,1,0,0,0,0,0,0);     //9
graph[10] = e(0,1,26,1,24,1,11,2); //10 
graph[11] = e(10,2,19,1,12,1,1,1); //11
graph[12] = e(13,1,11,1,14,1,0,0); //12
graph[13] = e(12,1,0,0,0,0,0,0);   //13
graph[14] = e(15,1,12,1,16,1,0,0); //14
graph[15] = e(14,1,0,0,0,0,0,0);   //15
graph[16] = e(17,1,18,1,14,1,0,0); //16 
graph[17] = e(16,1,0,0,0,0,0,0);   //17
graph[18] = e(21,1,19,1,16,1,0,0); //18
graph[19] = e(20,1,18,1,11,1,0,0); //19
graph[20] = e(19,1,0,0,0,0,0,0);   //20
graph[21] = e(22,1,23,1,18,1,0,0); //21
graph[22] = e(21,1,0,0,0,0,0,0);   //22
graph[23] = e(30,1,24,1,21,1,0,0); //23
graph[24] = e(23,1,25,1,10,1,0,0); //24
graph[25] = e(24,1,0,0,0,0,0,0);   //25
graph[26] = e(27,1,28,1,10,1,0,0); //26
graph[27] = e(26,1,0,0,0,0,0,0);   //27
graph[28] = e(26,1,29,1,30,1,0,0); //28
graph[29] = e(28,1,0,0,0,0,0,0);   //29
graph[30] = e(31,1,28,1,23,1,0,0); //30
graph[31] = e(30,1,0,0,0,0,0,0);   //31

for(int i=7; i<32; i++){
    printf("%x - %d\n",graph[i],i);
}

}