# Redirect for the QNX openpi/tensorstore port.
#
# tensorstore's third_party/com_google_re2/workspace.bzl declares
# cmake_name = "Re2", so find_package(Re2 CONFIG) looks for
# Re2Config.cmake / re2-config.cmake. The real re2-dev apk package ships
# usr/lib/cmake/re2/re2Config.cmake (lowercase "re2", no hyphen before
# "Config") which matches neither expected filename -- a plain case-
# sensitivity naming mismatch between tensorstore's declared cmake_name and
# upstream re2's own CMake install convention, not a QNX portability issue.
# This just forwards to the real file.
include(/usr/lib/cmake/re2/re2Config.cmake)
