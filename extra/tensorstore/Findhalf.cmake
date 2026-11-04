# Minimal FindHalf.cmake for the QNX openpi/tensorstore port.
#
# "half" (sourceforge.net/projects/half, Christian Rau) is a tiny
# single-header half-precision float library. No official CMake Find-module
# ships with tensorstore's tools/cmake/. tensorstore's own
# third_party/net_sourceforge_half/workspace.bzl declares:
#   cmake_target_mapping = {"@net_sourceforge_half//:half": "half::half"}
# so this module exists purely to define that one header-only target,
# pointed at a local copy of half.hpp with tensorstore's own
# detail_raise.patch applied (fixes an ambiguous unqualified raise() call
# that collides with libc's global raise() from <csignal> -- a real
# portability fix, not QNX-specific).
#
# Result variables: HALF_FOUND, HALF_INCLUDE_DIR
# Imported target: half::half

find_path(HALF_INCLUDE_DIR NAMES half.hpp)

include(FindPackageHandleStandardArgs)
find_package_handle_standard_args(Half DEFAULT_MSG HALF_INCLUDE_DIR)

mark_as_advanced(HALF_INCLUDE_DIR)

if(HALF_FOUND AND NOT TARGET half::half)
  add_library(half::half INTERFACE IMPORTED)
  set_target_properties(half::half PROPERTIES
    INTERFACE_INCLUDE_DIRECTORIES "${HALF_INCLUDE_DIR}"
  )
endif()
