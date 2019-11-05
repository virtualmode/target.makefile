#include "Core/cglobalc.h"
#include "cthread.h"

//#include <winbase.h>

void test()
{
}

int ClThreadCreate(const int a) {
	CreateThread(0, 0, test, 0, 0, 0);
	return a + 1;
}
