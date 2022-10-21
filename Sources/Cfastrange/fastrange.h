#include <stdint.h>

static inline uint64_t fastrange64(uint64_t factor1, uint64_t factor2) {
    return (uint64_t)(((__uint128_t)factor1 * (__uint128_t)factor2) >> 64);
}
