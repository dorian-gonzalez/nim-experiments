import winim/lean
import minhook

proc NimMain() {.cdecl, importc.}

proc modifiedIsValidCode(_: int): bool = true


proc DllMain(hinstDLL: HINSTANCE, fdwReason: DWORD,
    lpvReserved: LPVOID): BOOL {.stdcall, exportc, dynlib.} =
  NimMain()
  if fdwReason == DLL_PROCESS_ATTACH:
    var baseAddress = cast[int](GetModuleHandleA("library-loader.exe"));
    var isValidCode = cast[pointer](baseAddress + 0x10E0);
    assert createHook(isValidCode, modifiedIsValidCode, nil) == mhOk
    assert enableHook(isValidCode) == mhOk
  return true
