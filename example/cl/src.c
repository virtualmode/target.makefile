
#include "sglobalc.h"

#include "src.h"

//#include <conio.h>

//#include <fcntl.h>
//#include <io.h>
//#include <iostream>
//#include <fstream>

/*void InitializeDebugConsole()
{
	//Create a console for this application
	AllocConsole();
	//Redirect unbuffered STDOUT to the console
	HANDLE ConsoleOutput = GetStdHandle(STD_OUTPUT_HANDLE);
	int SystemOutput = _open_osfhandle(intptr_t(ConsoleOutput), _O_TEXT);
	FILE *COutputHandle = _fdopen(SystemOutput, "w");
	*stdout = *COutputHandle;
	setvbuf(stdout, NULL, _IONBF, 0);

	//Redirect unbuffered STDERR to the console
	HANDLE ConsoleError = GetStdHandle(STD_ERROR_HANDLE);
	int SystemError = _open_osfhandle(intptr_t(ConsoleError), _O_TEXT);
	FILE *CErrorHandle = _fdopen(SystemError, "w");
	*stderr = *CErrorHandle;
	setvbuf(stderr, NULL, _IONBF, 0);

	//Redirect unbuffered STDIN to the console
	HANDLE ConsoleInput = GetStdHandle(STD_INPUT_HANDLE);
	int SystemInput = _open_osfhandle(intptr_t(ConsoleInput), _O_TEXT);
	FILE *CInputHandle = _fdopen(SystemInput, "r");
	*stdin = *CInputHandle;
	setvbuf(stdin, NULL, _IONBF, 0);

	//make cout, wcout, cin, wcin, wcerr, cerr, wclog and clog point to console as well
	//ios::sync_with_stdio(true);
}

void ShutdownDebugConsole(void)
{
	//Write "Press any key to exit"
	HANDLE ConsoleOutput = GetStdHandle(STD_OUTPUT_HANDLE);
	DWORD CharsWritten;
	WriteConsole(ConsoleOutput, "\nPress any key to exit", 22, &CharsWritten, 0);
	//Disable line-based input mode so we can get a single character
	HANDLE ConsoleInput = GetStdHandle(STD_INPUT_HANDLE);
	SetConsoleMode(ConsoleInput, 0);
	//Read a single character
	TCHAR InputBuffer;
	DWORD CharsRead;
	ReadConsole(ConsoleInput, &InputBuffer, 1, &CharsRead, 0);
}*/

int main(int argc, char **argv) {
	//BOOL result = AllocConsole();

	//int t = srclibfunc(7);

	printf("Hello, world!\n");

	/*BOOL res = AttachConsole(0x0ffffffff), res2 = 0;
	if (res == 0) {
		res2 = AllocConsole();
	}

	if (res2 != 0) {
		FILE* temp = stdout;
		freopen("CON", "w", stdout);
		printf("test2: %p", temp);
	}

	FreeConsole();
	ExitProcess(0);*/

	// TODO: ExitProcess is used when default CRT isn't loaded.

	return 0;
	// 1) New empty win32 app.
	// 2) Linker->Advanced->Entry Point = main
	// 3) Linker->Input->Ignore All Default Libraries = Yes (/NODEFAULTLIB)
	// 4) Compiler->Code Generation->Security Check = Disable Security Check (/GS-)
	// 5) ??? Compiler->Optimization->Enable Intristic Functions = No (/Oi-) (if you want to replace strlen(), etc.)
	// 6) /NOASSEMBLY
	// 7) Linker->Advanced->Image Has Safe Exception Handlers = No (/SAFESEH:NO) (no extra space allocated for list of SEH handlers)
}
