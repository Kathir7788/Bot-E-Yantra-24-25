#include <stdint.h>
#include <stdbool.h>
#include <limits.h>
#include <stdlib.h>
#define V 32
#define INF 255  // Use 255 as "infinity" since it's the max value for uint8_t

#ifdef __linux__ // for host pc

    #include <stdio.h>

    void _put_byte(char c) { putchar(c); }

    void _put_str(char *str) {
        while (*str) {
            _put_byte(*str++);
        }
    }

    void print_output(uint8_t num) {
        if (num == 0) {
            putchar('0'); // if the number is 0, directly print '0'
            _put_byte('\n');
            return;
        }

        // convert the integer to a string
        char buffer[20];
        uint8_t index = 0;

        while (num > 0) {
            buffer[index++] = '0' + num % 10;
            num /= 10;
        }
        while (index > 0) { putchar(buffer[--index]); }
        _put_byte('\n');
    }

    void _put_value(uint8_t val) { print_output(val); }

#else  // for the test device

    void _put_value(uint8_t val) { }
    void _put_str(char *str) { }

#endif

void decode_edges(uint32_t encoded_edges, uint8_t neighbors[], uint8_t weights[], uint8_t* count) {
    *count = 0;
    for (uint8_t i = 0; i < 4; i++) {
        uint8_t neighbor = (encoded_edges >> (8 * i)) & 0x1F; // Corrected to 5 bits for neighbor
        uint8_t weight = (encoded_edges >> (5 + 8 * i)) & 0x07; // Corrected to 3 bits for weight
        if (neighbor != 0 || weight != 0) {  // Assuming 0 means no edge
            neighbors[*count] = neighbor;
            weights[*count] = weight;
            (*count)++;
        }
    }
}

int main(int argc, char const *argv[]) {
    #ifdef __linux__
        const uint8_t START_POINT   = atoi(argv[1]);
        const uint8_t END_POINT     = atoi(argv[2]);
        uint8_t NODE_POINT          = 0;
        uint8_t CPU_DONE            = 0;
        uint32_t graph[32] ;
        uint8_t dist[V];
        bool visited[V];
        uint8_t predecessors[V]; 
    #else
        #define START_POINT         (* (volatile uint8_t * ) 0x02000000)
        #define END_POINT           (* (volatile uint8_t * ) 0x02000004)
        #define NODE_POINT          (* (volatile uint8_t * ) 0x02000008)
        #define CPU_DONE            (* (volatile uint8_t * ) 0x0200000c)
        #define graph ((uint32_t *) 0x02000010)
        #define dist ((uint8_t *)0x02000090)
        #define predecessors ((uint8_t *)0x020000b0)
        #define visited ((uint8_t *)0x020000c0)
        
    #endif

    graph[0] = 0x0026212a;    //0
    graph[1] = 0x00202227;   //1
    graph[2] = 0x24252321;     //e(1,1,3,1,5,1,4,1); 2
    graph[3] = 0x00000022;     //e(2,1,0,0,0,0,0,0); 3
    graph[4] = 0x00000022;     //e(2,1,0,0,0,0,0,0); 4
    graph[5] = 0x00000022;     //e(2,1,0,0,0,0,0,0); 5
    graph[6] = 0x20272829;     //e(9,1,8,1,7,1,0,1); 6
    graph[7] = 0x00000026;     //e(6,1,0,0,0,0,0,0); 7
    graph[8] = 0x00000026;    //e(6,1,0,0,0,0,0,0); 8
    graph[9] = 0x00000026;    //e(6,1,0,0,0,0,0,0); 9
    graph[10] = 0x4b383a20; //e(0,1,26,1,24,1,11,2); 10 
    graph[11] = 0x212c334a;//e(10,2,19,1,12,1,1,1); 11
    graph[12] = 0x2e2b2d;//e(13,1,11,1,14,1,0,0); 12
    graph[13] = 0x2c;  //e(12,1,0,0,0,0,0,0); 13
    graph[14] = 0x302c2f;//e(15,1,12,1,16,1,0,0); 14
    graph[15] = 0x2e;  //e(14,1,0,0,0,0,0,0); 15
    graph[16] = 0x2e3231;//e(17,1,18,1,14,1,0,0); 16 
    graph[17] = 0x30;  //e(16,1,0,0,0,0,0,0); 17
    graph[18] = 0x303335;//e(21,1,19,1,16,1,0,0); 18
    graph[19] = 0x2b3234;//e(20,1,18,1,11,1,0,0); 19
    graph[20] = 0x33;  //e(19,1,0,0,0,0,0,0); 20
    graph[21] = 0x323736; //e(22,1,23,1,18,1,0,0); 21
    graph[22] = 0x35;  //e(21,1,0,0,0,0,0,0); 22
    graph[23] = 0x35383e;//e(30,1,24,1,21,1,0,0); 23
    graph[24] = 0x2a3937;//e(23,1,25,1,10,1,0,0); 24
    graph[25] = 0x38;  //e(24,1,0,0,0,0,0,0); 25
    graph[26] = 0x2a3c3b;//e(27,1,28,1,10,1,0,0); 26
    graph[27] = 0x3a;  //e(26,1,0,0,0,0,0,0); 27
    graph[28] = 0x3e3d3a;//e(26,1,29,1,30,1,0,0); 28
    graph[29] = 0x3c;  //e(28,1,0,0,0,0,0,0); 29
    graph[30] = 0x373c3f;//e(31,1,28,1,23,1,0,0); 30
    graph[31] = 0x3e;  //e(30,1,0,0,0,0,0,0); 31

    
    
    // Initialize distances and visited status
    for (uint8_t i = 0; i < V; i++) {
        dist[i] = INF;
        visited[i] = false;
        predecessors[i] = INF;
    }
    dist[END_POINT] = 0;

    for (uint8_t i = 0; i < V - 1; i++) {
        uint8_t u = INF, min_dist = INF;

        // Find the unvisited node with the minimum distance
        for (uint8_t v = 0; v < V; v++) {
            if (!visited[v] && dist[v] < min_dist) {
                min_dist = dist[v];
                u = v;
            }
        }
        if (u == INF) break;
        visited[u] = true;

        // Decode neighbors of node u
        uint8_t neighbors[4], weights[4], num_neighbors;
        decode_edges(*(graph+u), neighbors, weights, &num_neighbors);

        // Update distances for each neighbor
        for (uint8_t j = 0; j < num_neighbors; j++) {
            uint8_t v = neighbors[j];
            if (!visited[v] && dist[u] + weights[j] < dist[v]) {
                dist[v] = dist[u] + weights[j];
                predecessors[v] = u;
            }
        }
    }

    for (uint8_t v = START_POINT; v != INF; v = predecessors[v]) {
        NODE_POINT = v;
        if (v == END_POINT) break;
    }
    CPU_DONE = 1;

    #ifdef __linux__
        _put_str("######### Planned Path #########\n");
        for (uint8_t v = START_POINT; v != INF; v = predecessors[v]) {
            _put_value(v);
            if (v == END_POINT) break;
        }
        _put_str("################################\n");
    #endif

    return 0;
}
