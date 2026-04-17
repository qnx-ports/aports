toolchain(
    name = "qnx_cc_toolchain",
    toolchain = "@local_config_cc//:cc-compiler-qnx_%CPU%",
    toolchain_type = "@bazel_tools//tools/cpp:toolchain_type",
)
