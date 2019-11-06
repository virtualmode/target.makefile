// Colors:
//#define BLACK				0x0
//#define BLUE				0x1
//#define GREEN				0x2
//#define CYAN				0x3
//#define RED				0x4
//#define MAGENTA			0x5
//#define BROWN				0x6
//#define GREY				0x7
//#define DARK_GREY			0x8
//#define LIGHT_BLUE		0x9
//#define LIGHT_GREEN		0xA
//#define LIGHT_CYAN		0xB
//#define LIGHT_RED			0xC
//#define LIGHT_MAGENTA		0xD
//#define LIGHT_BROWN		0xE
//#define WHITE				0xF

int main()
{
	const char *script = "Hello, World!";
	const char length = 14;

/*
	// Установка видеорежима:
	__asm
	{
		mov		al, 02h ;// Настройка графического режима 80x25 (текст).
		mov		ah, 00h ;// Код функции изменения видео режима.
		int		10h ;// Вызов прерывания.
	}

	// Настройка курсора:
	//unsigned char flag = inMode ? 0 : 0x32;
	__asm
	{
		mov		ch, 0x32
		mov		cl, 0Ah
		mov		ah, 01h
		int		10h
	}

	// Вывод строки:
	__asm
	{
		push	bp
		mov		al, 0x00 ;// inUpdateCursor = false.
		xor		bh, bh
		mov		bl, 0xFD ;// textAttribute = ((inTextColor) | (inBackgroundColor << 4));
		xor		cx, cx
		mov		cl, length ;// Длина строки с терминирующим символом.
		mov		dl, 0x20 ;// X-координата.
		mov		dh, 0x0C ;// Y-координата.
		mov		es, word ptr[script + 2]
		mov		bp, word ptr[script]
		mov		ah, 13h
		int		10h
		pop		bp
	}
*/

	return 24;
}
