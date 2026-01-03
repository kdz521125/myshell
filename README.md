# myshell
Archive Tool v1.0.0 - A powerful file archiving utility
Usage: archive <command> [options] [arguments]

Commands:
  create, c    Create a new archive
  extract, x   Extract files from an archive
  list, l      List contents of an archive
  add, a       Add files to an existing archive
  remove, r    Remove files from an archive
  verify, v    Verify integrity of an archive
  update, u    Update files in an archive
  test, t      Test archive file integrity
  help, h      Show this help message
  version, V   Show version information

Global options:
  -v, --verbose          Verbose output
  -q, --quiet            Quiet mode (no output)
  -c, --compression N    Compression level (0-9, default: 6)
  -p, --password PASS    Password for encryption
  -n, --no-progress      Disable progress display

Examples:
  archive create backup.arc file1.txt file2.txt
  archive extract backup.arc
  archive list backup.arc
  archive add backup.arc newfile.txt

Detailed command usage:
CREATE:
  archive create [options] <archive> <files...>
  Options:
    -r, --recursive      Add directories recursively
    -f, --file NAME      Specify archive filename

EXTRACT:
  archive extract [options] <archive> [dest]
  Options:
    -C, --directory DIR  Extract to specific directory
    -p, --password PASS  Password for encrypted archive

LIST:
  archive list [options] <archive>
  Options:
    -v, --verbose        Show detailed information

For more information, see the man page: man archive