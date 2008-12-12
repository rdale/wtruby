#ifndef WTEXT_SMOKE_H
#define WTEXT_SMOKE_H

#include <smoke.h>

// Defined in smokedata.cpp, initialized by init_wtext_Smoke(), used by all .cpp files
extern SMOKE_EXPORT Smoke* wtext_Smoke;
extern SMOKE_EXPORT void init_wtext_Smoke();

#ifndef QGLOBALSPACE_CLASS
#define QGLOBALSPACE_CLASS
class QGlobalSpace { };
#endif

#endif
