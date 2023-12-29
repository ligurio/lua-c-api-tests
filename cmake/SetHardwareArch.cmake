# Copyright 2020 The SwiftShader Authors. All Rights Reserved.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
#            x32       x86_64
# ----------------------------
# ARM        arm       aarch64
# MIPS       mipsel    mips64el
# PPC        ppcle     ppc64le
# Intel-x86  x86       x86_64

if(CMAKE_SYSTEM_PROCESSOR MATCHES "arm" OR
   CMAKE_SYSTEM_PROCESSOR MATCHES "aarch")
  if(CMAKE_SIZEOF_VOID_P EQUAL 8)
    set(HW_ARCH "aarch64")
  else()
    set(HW_ARCH "arm")
  endif()
elseif(CMAKE_SYSTEM_PROCESSOR MATCHES "^mips.*")
  if(CMAKE_SIZEOF_VOID_P EQUAL 8)
    set(HW_ARCH "mips64el")
  else()
    set(HW_ARCH "mipsel")
  endif()
elseif(CMAKE_SYSTEM_PROCESSOR MATCHES "^ppc.*")
  if(CMAKE_SIZEOF_VOID_P EQUAL 8)
    set(HW_ARCH "ppc64le")
  else()
    set(HW_ARCH "ppcle")
  endif()
else()
  if(CMAKE_SIZEOF_VOID_P EQUAL 8)
    set(HW_ARCH "x86_64")
  else()
    set(HW_ARCH "x86")
  endif()
endif()

if(CMAKE_OSX_ARCHITECTURES)
  if(CMAKE_OSX_ARCHITECTURES MATCHES "arm64")
    set(HW_ARCH "aarch64")
  elseif(CMAKE_OSX_ARCHITECTURES MATCHES "x86_64")
    set(HW_ARCH "x86_64")
  elseif(CMAKE_OSX_ARCHITECTURES MATCHES "i386")
    set(HW_ARCH "x86")
  else()
    message(FATAL_ERROR "Unsupported hardware architecture")
  endif()
endif()
