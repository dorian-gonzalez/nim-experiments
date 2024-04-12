import os
import streams
import strutils

proc binnim(filenames: seq[string], width: int = 20, quotes: bool = true, format: string = "c") =
    try:
        if filenames.len == 0:
            raise new_exception(Exception, "You must supply a filename.")

        for filename in filenames:
            if not os.file_exists(filename):
                stderr.write_line(filename & " is not found." & "\n")
                continue

            var file_stream = streams.new_file_stream(filename, fmRead)
            var file_size = cast[int](os.get_file_size(filename))
            var counter = 0

            case format:
            of "c":
                while not file_stream.at_end():
                    if counter == 0:
                        if quotes:
                            stdout.write "\""

                    var character = file_stream.read_str(1)
                    stdout.write "\\x" & strutils.to_lower(strutils.to_hex(character))
                    counter += 1

                    if width != 0:
                        if counter >= width:
                            if quotes:
                                stdout.write "\""
                            stdout.write "\n"
                            counter = 0
            of "nim":
                stdout.write("var shellcode: array[" & strutils.int_to_str(file_size) & ", byte] = [\nbyte ")
                
                while not file_stream.at_end():
                    var character = file_stream.read_str(1)
                    stdout.write "0x" & strutils.to_lower(strutils.to_hex(character)) & ", "
                    counter += 1

                    if width != 0:
                        if counter >= width:
                            stdout.write "\n"
                            counter = 0

            file_stream.close()

            case format:
                of "c":
                    if quotes:
                        stdout.write "\""
                of "nim":
                    stdout.write " ]"

    except:
        stderr.write_line("[ERROR] " & get_current_exception_msg() & "\n")

when is_main_module:
    import cligen; dispatch(binnim)

