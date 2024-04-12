# include <iostream>
# include <array>
# include <sstream>

# include "windows.h"

# const char* InjectionDll = "hook.dll";

# __declspec(noinline) bool is_valid_code(int code)
# {
#     std::array<int, 3> valid_codes = { 1234, 4321, 8888 };
#     for (const auto& c : valid_codes)
#         if (c == code)
#             return true;

#     return false;
# }

# int main()
# {
#     auto dll = LoadLibraryA(InjectionDll);
#     if (!dll)
#         std::cout << "failed to load " << InjectionDll << std::endl;

#     std::string buffer;
#     int code;
#     while (true)
#     {
#         std::cout << "enter code to continue: ";

#         std::getline(std::cin, buffer);
#         auto ss = std::istringstream(buffer);

#         ss >> code;
#         if (is_valid_code(code))
#             break;

#         std::cout << "Wrong code :(" << std::endl;
#     }

#     std::cout << "Correct code!" << '\n'
#         << "Press return to exit... ";
#     std::getline(std::cin, buffer);
# }

import winim
import std/rdstdin
import strutils

const InjectionDll: string = "hook.dll"

proc is_valid_code(code: int): bool {.noinline.} =
        let valid_codes: array[3, int] = [1234, 4321, 8888]

        for c in valid_codes:
                if c == code:
                        return true

        return false


var dll = LoadLibraryA(InjectionDll)

if bool(dll) == FALSE:
        echo "failed to load"

var buffer: string
while true:
        let ok = readLineFromStdin("enter code to continue: ", buffer)
        if ok and buffer.len > 0:
                let code = parseInt(buffer)
                if is_valid_code(code):
                        break

        echo "Wrong code :("

echo "Correct code!"

echo "Press return to exit... "
