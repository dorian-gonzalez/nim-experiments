
import winim

proc toString(bytes: openarray[char]): string =
  result = newString(bytes.len)
  copyMem(result[0].addr, bytes[0].unsafeAddr, bytes.len)

var client_socket: SOCKET
var wsastructure: WSADATA
var result: int
var client_addr: sockaddr_in

var recvData: array[500, char]
var clientMessage = "Hello from the client!";


result = WSAStartup(MAKEWORD(2, 2), &wsastructure);

if(result != 0):
    echo "[!] WinSock initialization failed \n"

client_socket = socket(AF_INET, SOCK_STREAM, 0);
client_addr.sin_family = AF_INET;
client_addr.sin_port = htons(9001);
client_addr.sin_addr.S_addr = inet_addr("192.168.122.128");
connect(client_socket, cast[ptr SockAddr](addr client_addr), int32(sizeof(client_addr)));
recv(client_socket, addr recvData[0], int32(sizeof(recvData)), 0);
echo "Data from the server:" & toString(recvData)
send(client_socket, addr clientMessage[0], int32(len(clientMessage)), 0);
closesocket(client_socket);
WSACleanup();