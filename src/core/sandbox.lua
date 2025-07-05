local ffi = require("ffi")

ffi.cdef[[
    typedef void* HANDLE;
    typedef void* LPVOID;
    typedef unsigned long DWORD;
    typedef const char* LPCSTR;
    typedef int BOOL;
    typedef unsigned short WORD;
    typedef unsigned char BYTE;

    typedef struct _SECURITY_ATTRIBUTES {
        DWORD nLength;
        LPVOID lpSecurityDescriptor;
        BOOL bInheritHandle;
    } SECURITY_ATTRIBUTES, *LPSECURITY_ATTRIBUTES;

    typedef struct _STARTUPINFOA {
        DWORD cb;
        LPCSTR lpReserved;
        LPCSTR lpDesktop;
        LPCSTR lpTitle;
        DWORD dwX;
        DWORD dwY;
        DWORD dwXSize;
        DWORD dwYSize;
        DWORD dwXCountChars;
        DWORD dwYCountChars;
        DWORD dwFillAttribute;
        DWORD dwFlags;
        WORD wShowWindow;
        WORD cbReserved2;
        LPBYTE lpReserved2;
        HANDLE hStdInput;
        HANDLE hStdOutput;
        HANDLE hStdError;
    } STARTUPINFOA, *LPSTARTUPINFOA;

    typedef struct _PROCESS_INFORMATION {
        HANDLE hProcess;
        HANDLE hThread;
        DWORD dwProcessId;
        DWORD dwThreadId;
    } PROCESS_INFORMATION, *LPPROCESS_INFORMATION;

    BOOL CreateProcessA(
        LPCSTR lpApplicationName,
        LPSTR lpCommandLine,
        LPSECURITY_ATTRIBUTES lpProcessAttributes,
        LPSECURITY_ATTRIBUTES lpThreadAttributes,
        BOOL bInheritHandles,
        DWORD dwCreationFlags,
        LPVOID lpEnvironment,
        LPCSTR lpCurrentDirectory,
        LPSTARTUPINFOA lpStartupInfo,
        LPPROCESS_INFORMATION lpProcessInformation
    );

    BOOL CloseHandle(HANDLE hObject);

    // Debugging API structures and functions
    typedef struct _EXCEPTION_DEBUG_INFO {
        DWORD dwFirstChance;
    } EXCEPTION_DEBUG_INFO, *LPEXCEPTION_DEBUG_INFO;

    typedef struct _DEBUG_EVENT {
        DWORD dwDebugEventCode;
        DWORD dwProcessId;
        DWORD dwThreadId;
        union {
            EXCEPTION_DEBUG_INFO Exception;
            // Add other event types as needed
        } u;
    } DEBUG_EVENT, *LPDEBUG_EVENT;

    BOOL WaitForDebugEvent(
        LPDEBUG_EVENT lpDebugEvent,
        DWORD dwMilliseconds
    );

    BOOL ContinueDebugEvent(
        DWORD dwProcessId,
        DWORD dwThreadId,
        DWORD dwContinueStatus
    );
]]

local kernel32 = ffi.load("kernel32.dll")

local M = {}

function M.create_sandboxed_process(command_line)
    local si = ffi.new("STARTUPINFOA")
    si.cb = ffi.sizeof(si)
    local pi = ffi.new("PROCESS_INFORMATION")

    local success = kernel32.CreateProcessA(
        nil, -- lpApplicationName
        command_line, -- lpCommandLine
        nil, -- lpProcessAttributes
        nil, -- lpThreadAttributes
        false, -- bInheritHandles
        0x00000001, -- DEBUG_PROCESS
        nil, -- lpEnvironment
        nil, -- lpCurrentDirectory
        si,
        pi
    )

    if success then
        print("Process created with PID: " .. pi.dwProcessId)
        return pi
    else
        print("Failed to create process. Error: " .. ffi.errno())
        return nil
    end
end

function M.debug_loop(pi)
    local debug_event = ffi.new("DEBUG_EVENT")
    local continue_status = 0x00010002 -- DBG_CONTINUE

    while true do
        if not kernel32.WaitForDebugEvent(debug_event, 100) then -- 100ms timeout
            if ffi.errno() == 0 then -- Timeout
                -- No debug event, continue loop
            else
                print("WaitForDebugEvent failed. Error: " .. ffi.errno())
                break
            end
        else
            print(string.format("Debug Event: %x, PID: %d, TID: %d",
                                debug_event.dwDebugEventCode,
                                debug_event.dwProcessId,
                                debug_event.dwThreadId))

            if debug_event.dwDebugEventCode == 1 then -- EXCEPTION_DEBUG_EVENT
                print("Exception Debug Event")
                -- Handle exceptions here
            elseif debug_event.dwDebugEventCode == 2 then -- CREATE_THREAD_DEBUG_EVENT
                print("Create Thread Debug Event")
            elseif debug_event.dwDebugEventCode == 3 then -- CREATE_PROCESS_DEBUG_EVENT
                print("Create Process Debug Event")
                kernel32.CloseHandle(debug_event.u.CreateProcessInfo.hFile)
            elseif debug_event.dwDebugEventCode == 4 then -- EXIT_THREAD_DEBUG_EVENT
                print("Exit Thread Debug Event")
            elseif debug_event.dwDebugEventCode == 5 then -- EXIT_PROCESS_DEBUG_EVENT
                print("Exit Process Debug Event")
                break -- Exit loop when process exits
            elseif debug_event.dwDebugEventCode == 6 then -- LOAD_DLL_DEBUG_EVENT
                print("Load DLL Debug Event")
                kernel32.CloseHandle(debug_event.u.LoadDll.hFile)
            elseif debug_event.dwDebugEventCode == 7 then -- UNLOAD_DLL_DEBUG_EVENT
                print("Unload DLL Debug Event")
            elseif debug_event.dwDebugEventCode == 8 then -- OUTPUT_DEBUG_STRING_EVENT
                print("Output Debug String Event")
            elseif debug_event.dwDebugEventCode == 9 then -- RIP_EVENT
                print("RIP Event")
            end

            kernel32.ContinueDebugEvent(
                debug_event.dwProcessId,
                debug_event.dwThreadId,
                continue_status
            )
        end
    end
end

return M