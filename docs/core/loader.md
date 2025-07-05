# Loader

The loader is responsible for identifying and parsing different binary file formats. It currently supports ELF files and has placeholder support for PE and Mach-O formats.

The `loader.load` function takes a file path as input and returns a `binary_info` table containing the parsed information.