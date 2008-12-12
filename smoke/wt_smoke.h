#ifndef WT_SMOKE_H
#define WT_SMOKE_H

#include <smoke.h>

// Defined in smokedata.cpp, initialized by init_wt_Smoke(), used by all .cpp files
extern SMOKE_EXPORT Smoke* wt_Smoke;
extern SMOKE_EXPORT void init_wt_Smoke();

#ifndef QGLOBALSPACE_CLASS
#define QGLOBALSPACE_CLASS
class QGlobalSpace { };
#endif

#endif
