require 'mkmf'

# :stopdoc:

dir_config 'libffi'

def have_ffi_headers
  return true if have_header('ffi.h')
  if have_header('ffi/ffi.h')
    $defs.push(format('-DUSE_HEADER_HACKS'))
  end
end

unless have_ffi_headers
  pkgconfig('libffi')
  unless have_ffi_headers
    raise "ffi.h is missing. Please install libffi."
  end
end

unless have_library('ffi') || have_library('libffi')
  raise "libffi is missing. Please install libffi."
end

have_header 'sys/mman.h'

create_makefile 'fiddle'

# :startdoc:
