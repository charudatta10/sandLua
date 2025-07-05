# debug Command

The `debug` command allows you to launch an executable in a sandboxed environment for dynamic analysis.

## Usage

```
debug <path_to_executable>
```

- `<path_to_executable>`: The absolute or relative path to the executable you want to debug.

## Example

```
debug C:\Windows\System32\notepad.exe
```

This will launch `notepad.exe` in a sandboxed process. Currently, it only launches the process and does not provide interactive debugging capabilities. Future updates will include features like setting breakpoints, inspecting memory, and stepping through code.
