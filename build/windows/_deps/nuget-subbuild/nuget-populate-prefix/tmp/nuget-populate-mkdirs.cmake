# Distributed under the OSI-approved BSD 3-Clause License.  See accompanying
# file Copyright.txt or https://cmake.org/licensing for details.

cmake_minimum_required(VERSION 3.5)

file(MAKE_DIRECTORY
  "C:/git_subir/armazensr/paip_gestor_webview/build/windows/_deps/nuget-src"
  "C:/git_subir/armazensr/paip_gestor_webview/build/windows/_deps/nuget-build"
  "C:/git_subir/armazensr/paip_gestor_webview/build/windows/_deps/nuget-subbuild/nuget-populate-prefix"
  "C:/git_subir/armazensr/paip_gestor_webview/build/windows/_deps/nuget-subbuild/nuget-populate-prefix/tmp"
  "C:/git_subir/armazensr/paip_gestor_webview/build/windows/_deps/nuget-subbuild/nuget-populate-prefix/src/nuget-populate-stamp"
  "C:/git_subir/armazensr/paip_gestor_webview/build/windows/_deps/nuget-subbuild/nuget-populate-prefix/src"
  "C:/git_subir/armazensr/paip_gestor_webview/build/windows/_deps/nuget-subbuild/nuget-populate-prefix/src/nuget-populate-stamp"
)

set(configSubDirs Debug)
foreach(subDir IN LISTS configSubDirs)
    file(MAKE_DIRECTORY "C:/git_subir/armazensr/paip_gestor_webview/build/windows/_deps/nuget-subbuild/nuget-populate-prefix/src/nuget-populate-stamp/${subDir}")
endforeach()
if(cfgdir)
  file(MAKE_DIRECTORY "C:/git_subir/armazensr/paip_gestor_webview/build/windows/_deps/nuget-subbuild/nuget-populate-prefix/src/nuget-populate-stamp${cfgdir}") # cfgdir has leading slash
endif()
