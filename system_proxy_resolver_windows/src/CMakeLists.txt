# The Flutter tooling requires that developers have CMake 3.10 or later
# installed. You should not increase this version, as doing so will cause
# the plugin to fail to compile for some customers of the plugin.
cmake_minimum_required(VERSION 3.10)

project(system_proxy_resolver_windows_library VERSION 0.0.1 LANGUAGES C)

add_library(system_proxy_resolver_windows SHARED
  "system_proxy_resolver_windows.c"
)

set_target_properties(system_proxy_resolver_windows PROPERTIES
  PUBLIC_HEADER system_proxy_resolver_windows.h
  OUTPUT_NAME "system_proxy_resolver_windows"
)

target_compile_definitions(system_proxy_resolver_windows PUBLIC DART_SHARED_LIB)
