#include "Core/globalc.h"
#include "thread.h"

void ThreadEntryExample()
{
}

int StaticExampleThreadCreate(const int a) {
	CreateThread(0, 0, ThreadEntryExample, 0, 0, 0);
	return a + 1;
}
