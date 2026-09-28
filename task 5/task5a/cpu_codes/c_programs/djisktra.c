#include <stdint.h>
#include <stdbool.h>
#include <stdio.h>
#include <limits.h>

#define total_nodes 5

uint32_t graph[total_nodes] = {
    0b00000000000000000000000000000010,  // Node 0 is connected to Node 1
    0b00000000000000000000000000000101,  // Node 1 is connected to Node 0 and Node 2
    0b00000000000000000000000000001010,  // Node 2 is connected to Node 1 and Node 3
    0b00000000000000000000000000101000,  // Node 3 is connected to Node 2 and Node 4
    0b00000000000000000000000001000000   // Node 4 is connected to Node 3
};

bool is_neighbor(uint8_t u, uint8_t v) {
    return (graph[u] & (1 << v)) != 0;
}

void dijkstra(uint8_t start_node, uint8_t end_node){

    uint32_t visited=0;
    uint8_t dist[total_nodes];         
    uint8_t parent[total_nodes];

    for (int i = 0; i < total_nodes; i++) {
            dist[i] = UINT8_MAX;
            parent[i] = 31;
        }
    
    dist[start_node] = 0;

    for(int i=0; i<total_nodes; i++){
        int u = 31;
            for (int j = 0; j < total_nodes; j++) {
                if (!(visited & 1<<j) && (u == 31 || dist[j] < dist[u])) {
                    u = j;
                }
            }

        if (dist[u] == UINT8_MAX) break;

        visited |= (1<<u);

        for (int v = 0; v < total_nodes; v++) {
                if (is_neighbor(u, v) && !(visited & 1<<v) && dist[u] + 1 < dist[v]) {
                    dist[v] = dist[u] + 1;
                    parent[v] = u;
                    printf("dist=%d and parent of %d=%d\n",dist[v],v,parent[v]);
                }
            }
        }
        
        if (dist[end_node] == UINT8_MAX) {
            printf("Node %d is unreachable from Node %d\n", end_node, start_node);
        } else {
            printf("Shortest distance from Node %d to Node %d is %d\n", start_node, end_node, dist[end_node]);
            printf("Path: ");
            int p = end_node;
            while (p != 31) {
                printf("%d ", p);
                p = parent[p];
            }
            printf("\n");
        }
    }



int main() {
    uint8_t start = 1; // Starting node for Dijkstra's algorithm
    uint8_t end = 4;
    printf("Running Dijkstra's algorithm from Node %d , %d:\n", start, end);
    dijkstra(start, end);
    return 0;
}