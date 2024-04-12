# nim-experiments

Debug

	nim c --verbosity:2 -r main.nim


Release

	nimble build -d:release -d:strip --passC:-flto --passL:-flto --passL:-s

	nim c -d:release -d:strip --passC:-flto --passL:-flto --passL:-s main.nim

32bit
	nim c -d:release --cpu:i386 -d:strip --passC:-flto --passL:-flto --passL:-s main.nim


ARC
	nim c -d:release -d:strip --gc:arc --passC:-flto --passL:-flto --passL:-s main.n