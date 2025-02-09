//
//  PMSHAKEPermutation.h
//  PMDataSecurity
//
//  Created by Pyae Phyo Myint Soe on 3/2/25.
//

#ifndef PMSHAKEPermutation_h
#define PMSHAKEPermutation_h

#ifdef __cplusplus
extern "C" {
#endif

#include <MacTypes.h>

extern inline int pm_update_data(const unsigned char *datePtr, int count, UInt64 state[25], int noOfRounds, int curRatePos, int rateSize);
void pm_keccakf(UInt64 st[25], int noOfRounds);

#ifdef __cplusplus
}
#endif

#endif /* PMSHAKEPermutation_h */

