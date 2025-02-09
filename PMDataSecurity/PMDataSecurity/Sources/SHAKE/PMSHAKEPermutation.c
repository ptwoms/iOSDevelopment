//
//  PMSHAKEPermutation.c
//  PMDataSecurity
//
//  Created by Pyae Phyo Myint Soe on 3/2/25.
//

#include "PMSHAKEPermutation.h"

#ifndef PMLeftRotate64
#define PMLeftRotate64(x, y) (((x) << (y)) | ((x) >> (64 - (y))))
#endif

int pm_update_data(const unsigned char *datePtr, int count, UInt64 state[25], int noOfRounds, int curRatePos, int rateSize) {
    if (datePtr == NULL || count <= 0) {
        return curRatePos;
    }
    int curPos = curRatePos;
    for (int i = 0; i < count; i++) {
        state[curPos >> 3] ^= ((UInt64)datePtr[i]) << ((curPos & 0b111) << 3);
        curPos += 1;
        if (curPos >= rateSize) {
            pm_keccakf(state, noOfRounds);
            curPos = 0;
        }
    }
    return curPos;
}

inline void pm_keccakf(UInt64 state[25], int noOfRounds)
{
    const UInt64 roundConstants[24] = {
        0x0000000000000001, 0x0000000000008082, 0x800000000000808a,
        0x8000000080008000, 0x000000000000808b, 0x0000000080000001,
        0x8000000080008081, 0x8000000000008009, 0x000000000000008a,
        0x0000000000000088, 0x0000000080008009, 0x000000008000000a,
        0x000000008000808b, 0x800000000000008b, 0x8000000000008089,
        0x8000000000008003, 0x8000000000008002, 0x8000000000000080,
        0x000000000000800a, 0x800000008000000a, 0x8000000080008081,
        0x8000000000008080, 0x0000000080000001, 0x8000000080008008
    };
    const int rotationConstants[24] = {
        1,   3,  6, 10, 15, 21, 28, 36, 45, 55,
        2,  14, 27, 41, 56,  8, 25, 43, 62, 18,
        39, 61, 20, 44
    };
    const int permutationIndex[24] = {
        10,  7, 11, 17, 18,
        3,   5, 16,  8, 21,
        24,  4, 15, 23, 19,
        13, 12,  2, 20, 14,
        22,  9,  6,  1
    };

    int x, index;
    UInt64 D, C[5];

    // x mod 5 lookup tables
    int xPl1ModLookup[5] = { 1, 2, 3, 4, 0 };
    int xP2ModLookup[5]  = { 2, 3, 4, 0, 1 };
    int xM1ModLookup[5]  = { 4, 0, 1, 2, 3 };

    // permutation rounds
    for (int curRound = 0; curRound < noOfRounds; curRound++) {

        // θ step
        //   C[x] = A[x,0] xor A[x,1] xor A[x,2] xor A[x,3] xor A[x,4],   for x in 0…4
        for (x = 0; x < 5; x++)
            C[x] = state[x] ^ state[x + 5] ^ state[x + 10] ^ state[x + 15] ^ state[x + 20];

        //  D[x] = C[x-1] xor rot(C[x+1],1),                             for x in 0…4
        //  A[x,y] = A[x,y] xor D[x],                           for (x,y) in (0…4,0…4)
        for (x = 0; x < 5; x++) {
            D = C[xM1ModLookup[x]] ^ PMLeftRotate64(C[xPl1ModLookup[x]], 1);
            for (index = 0; index < 25; index += 5)
                state[index + x] ^= D;
        }

        // ρ and π steps
        // B[y,2*x+3*y] = rot(A[x,y], r[x,y]),                 for (x,y) in (0…4,0…4)
        D = state[1];
        for (x = 0; x < 24; x++) {
            index = permutationIndex[x];
            C[0] = state[index];
            state[index] = PMLeftRotate64(D, rotationConstants[x]);
            D = C[0];
        }

        // χ step
        // A[x,y] = B[x,y] xor ((not B[x+1,y]) and B[x+2,y]),  for (x,y) in (0…4,0…4)
        for (index = 0; index < 25; index += 5) {
            for (x = 0; x < 5; x++) {
                C[x] = state[index + x];
            }
            for (x = 0; x < 5; x++) {
                state[index + x] ^= (~C[xPl1ModLookup[x]]) & C[xP2ModLookup[x]];
            }
        }

        // ι step
        state[0] ^= roundConstants[curRound];
    }
}

