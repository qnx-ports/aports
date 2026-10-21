# Minimal Findriegeli.cmake for the QNX openpi/tensorstore port.
#
# No official riegeli CMake Find-module ships with tensorstore's
# tools/cmake/, and tensorstore's own third_party/com_google_riegeli/
# workspace.bzl declares no cmake_target_mapping either (unlike blake3's
# single BLAKE3::BLAKE3 target, riegeli is referenced via ~14 separate
# fine-grained bazel targets -- riegeli/bytes:reader, :writer, :cord_reader,
# etc.). Rather than hand-writing 14 individual CMake targets, the small
# workspace.bzl patch (see project_tensorstore_qnx.md) maps all of them to
# this single riegeli::riegeli target, backed by our scoped riegeli build
# (see project_riegeli_qnx.md -- bytes/digests/varint/zstd/base only, the
# subset tensorstore's OCDBT format actually needs).
#
# Result variables: RIEGELI_FOUND, RIEGELI_INCLUDE_DIR, RIEGELI_LIBRARY
# Imported target: riegeli::riegeli
#
# riegeli::riegeli is a STATIC IMPORTED target -- unlike a real CMake
# Config-exported target, an IMPORTED static library doesn't carry its own
# transitive link dependencies unless INTERFACE_LINK_LIBRARIES is set
# explicitly here (confirmed the hard way: omitting this produces real
# "undefined reference to ZSTD_*" linker errors from riegeli's own
# zstd_reader.cc/zstd_writer.cc/zstd_dictionary.cc object code, since
# riegeli's own extra/riegeli/CMakeLists.txt links zstd into its build but
# that fact isn't discoverable from the installed .a file alone). zlib is
# included too, for the same reason (riegeli/zlib/zlib_{reader,writer}.cc).

find_path(RIEGELI_INCLUDE_DIR NAMES riegeli/bytes/reader.h)
find_library(RIEGELI_LIBRARY NAMES riegeli)
find_library(RIEGELI_ZSTD_LIBRARY NAMES zstd)
find_library(RIEGELI_ZLIB_LIBRARY NAMES z)

include(FindPackageHandleStandardArgs)
find_package_handle_standard_args(riegeli DEFAULT_MSG RIEGELI_LIBRARY RIEGELI_INCLUDE_DIR)

mark_as_advanced(RIEGELI_INCLUDE_DIR RIEGELI_LIBRARY RIEGELI_ZSTD_LIBRARY RIEGELI_ZLIB_LIBRARY)

if(RIEGELI_FOUND AND NOT TARGET riegeli::riegeli)
  add_library(riegeli::riegeli STATIC IMPORTED)
  set_target_properties(riegeli::riegeli PROPERTIES
    IMPORTED_LOCATION "${RIEGELI_LIBRARY}"
    INTERFACE_INCLUDE_DIRECTORIES "${RIEGELI_INCLUDE_DIR}"
    INTERFACE_LINK_LIBRARIES "${RIEGELI_ZSTD_LIBRARY};${RIEGELI_ZLIB_LIBRARY}"
  )
endif()
