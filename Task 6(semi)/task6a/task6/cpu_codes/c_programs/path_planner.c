/*
* EcoMender Bot (EB): Task 2B Path Planner
*
* This program computes the valid path from the start point to the end point.
* Make sure you don't change anything outside the "Add your code here" section.
*/

#include <stdlib.h>
#include <stdbool.h>
#include <stdint.h>
#include <limits.h>
#define V 32

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

        if (num < 0) {
            putchar('-'); // print the negative sign for negative numbers
            num = -num;   // make the number positive for easier processing
        }

        // convert the integer to a string
        char buffer[20]; // assuming a 32-bit integer, the maximum number of digits is 10 (plus sign and null terminator)
        uint8_t index = 0;

        while (num > 0) {
            buffer[index++] = '0' + num % 10; // convert the last digit to its character representation
            num /= 10;                        // move to the next digit
        }
        // print the characters in reverse order (from right to left)
        while (index > 0) { putchar(buffer[--index]); }
        _put_byte('\n');
    }

    void _put_value(uint8_t val) { print_output(val); }

#else  // for the test device

    void _put_value(uint8_t val) { }
    void _put_str(char *str) { }

#endif

// main function
int main(int argc, char const *argv[]) {

    #ifdef __linux__

        const uint8_t START_POINT   = atoi(argv[1]);
        const uint8_t END_POINT     = atoi(argv[2]);
        uint8_t NODE_POINT          = 0;
        uint8_t CPU_DONE            = 0;

    #else
        // Address value of variables for RISC-V Implementation
        #define START_POINT         (* (volatile uint8_t * ) 0x02000000)
        #define END_POINT           (* (volatile uint8_t * ) 0x02000004)
        #define NODE_POINT          (* (volatile uint8_t * ) 0x02000008)
        #define CPU_DONE            (* (volatile uint8_t * ) 0x0200000c)

    #endif

    // array to store the planned path
    uint8_t path_planned[32];
    // index to keep track of the path_planned array
    uint8_t idx = 0;

    /* Functions Usage

    instead of using printf() function for debugging,
    use the below function calls to print a number, string or a newline

    for newline: _put_byte('\n');
    for string:  _put_str("your string here");
    for number:  _put_value(your_number_here);

    Examples:
            _put_value(START_POINT);
            _put_value(END_POINT);
            _put_str("Hello World!");
            _put_byte('\n');
    */

    // ############# Add your code here #############
    // prefer declaring variable like this
    #ifdef __linux__
        uint32_t graph[32];
    #else
        uint32_t *graph = (uint32_t *) 0x02000010;
    #endif
	
    // Encoding the graph with neighbors for each node
	graph[0] = (10 << 12) | (6 << 6) | 1;    // Node 0 connects to 10, 6, 1
	graph[1] = (11 << 12) | (2 << 6) | 32;     // Node 1 connects to 2, 5, 7
	graph[2] = (5 << 18) | (4 << 12) | (3 << 6) | 1;  // Node 2 connects to 3, 4, 5
	graph[3] = (2 << 6);                    // Node 3 connects to 2
	graph[4] = (2 << 6);                    // Node 4 connects to 2
	graph[5] = (2 << 6);                    // Node 5 connects to 2
	graph[6] = (9 << 18) | (8 << 12) | (7 << 6) | 32;  // Node 6 connects to 7, 8, 9
	graph[7] = (6 << 6);                    // Node 7 connects to 6
	graph[8] = (6 << 6);                    // Node 8 connects to 6
	graph[9] = (6 << 6);                    // Node 9 connects to 6
	graph[10] = (26 << 18) | (24 << 12) | (11 << 6) | 32;  // Node 10 connects to 26, 24, 11
	graph[11] = (19 << 18) | (12 << 12) | (10 << 6) | 1;   // Node 11 connects to 19, 12, 10
	graph[12] = (14 << 12) | (13 << 6) | 11;  // Node 12 connects to 14, 13, 11
	graph[13] = (12 << 6);                  // Node 13 connects to 12
	graph[14] = (16 << 12) | (15 << 6) | 12; // Node 14 connects to 16, 15, 12
	graph[15] = (14 << 6);                  // Node 15 connects to 14
	graph[16] = (18 << 12) | (17 << 6) | 14; // Node 16 connects to 18, 17, 14
	graph[17] = (16 << 6);                  // Node 17 connects to 16
	graph[18] = (21 << 12) | (19 << 6) | 16; // Node 18 connects to 21, 19, 16
	graph[19] = (20 << 12) | (18 << 6) | 11; // Node 19 connects to 20, 18, 11
	graph[20] = (19 << 6);                  // Node 20 connects to 19
	graph[21] = (23 << 12) | (22 << 6) | 18; // Node 21 connects to 23, 22, 18
	graph[22] = (21 << 6);                  // Node 22 connects to 21
	graph[23] = (30 << 12) | (24 << 6) | 21; // Node 23 connects to 30, 24, 21
	graph[24] = (25 << 12) | (23 << 6) | 10; // Node 24 connects to 25, 23, 10
	graph[25] = (24 << 6);                  // Node 25 connects to 24
	graph[26] = (28 << 12) | (27 << 6) | 10; // Node 26 connects to 28, 27, 10
	graph[27] = (26 << 6);                  // Node 27 connects to 26
	graph[28] = (30 << 12) | (29 << 6) | 26; // Node 28 connects to 30, 29, 26
	graph[29] = (28 << 6);                  // Node 29 connects to 28
	graph[30] = (31 << 12) | (28 << 6) | 23; // Node 30 connects to 31, 28, 23
	graph[31] = (30 << 6);                          // Node 31 has no neighbors
	
	#ifdef __linux__
        uint8_t dist[V];
    #else
        uint8_t *dist = (uint8_t *) 0x02000090;
    #endif
    
    #ifdef __linux__
        uint8_t parent[V];
    #else
        uint8_t *parent = (uint8_t *) 0x020000b0;
    #endif
    
    #ifdef __linux__
        bool sptSet[V];
    #else
        bool *sptSet = (bool *) 0x020000d0;
    #endif
	
	for (uint8_t i = 0; i < V; i++) dist[i] = 255, parent[i] = 32, sptSet[i] = false;
	dist[START_POINT] = 0;
	
	for (int count = 0; count < V - 1; count++) {
	    int u , min = 255;
	
	    // Find the vertex with the minimum distance value
	    for (int v = 0; v < V; v++) 
	        if (!sptSet[v] && dist[v] <= min) min = dist[u=v];
	
	    sptSet[u] = true;
	
	    // Iterate through the neighbors encoded in the adjacency list
	    for (uint8_t i = 0; i < 4; i++, graph[u] >>= 6) {
	        uint8_t v = graph[u] & 0x3F;       // Get the least significant byte (neighbor)	        
	        if(v!=0){
		        if (v == 32) v = 0;                 // If the neighbor is 32, it indicates no connection
		        if (!sptSet[v] && dist[u] + 1 < dist[v]) dist[v] = dist[u] + 1, parent[v] = u;
	        }
	    }
	}
	
	for (int crawl = END_POINT; crawl != 32; crawl = parent[crawl])
	    path_planned[idx++] = crawl;
	
	for (uint8_t i = 0; i < idx / 2; i++) {
	    uint8_t temp = path_planned[i];
	    path_planned[i] = path_planned[idx - 1 - i];
	    path_planned[idx - 1 - i] = temp;
	}

    // ##############################################

    // the node values are written into data memory sequentially.
    for (int i = 0; i < idx; ++i) {
        NODE_POINT = path_planned[i];
    }
    // Path Planning Computation Done Flag
    CPU_DONE = 1;
    #ifdef __linux__    // for host pc

        _put_str("######### Planned Path #########\n");
        for (int i = 0; i < idx; ++i) {
            _put_value(path_planned[i]);
        }
        _put_str("################################\n");

    #endif

    return 0;
}
