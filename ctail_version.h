/* Copyright 2007 Paul Querna
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

/**
 * @file pwt_version.h
 * @brief Defines the Cluster Tail's version information.
 */

#ifndef CTAIL_VERSION_H
#define CTAIL_VERSION_H

#include "apr_general.h"

#define CTAIL_MAJOR_VERSION 0
#define CTAIL_MINOR_VERSION 1
#define CTAIL_PATCH_VERSION 0

//#define CTAIL_DEVBUILD_BOOLEAN 1

#if CTAIL_DEVBUILD_BOOLEAN
#define CTAIL_VER_ADD_STRING "-dev"
#else
#define CTAIL_VER_ADD_STRING "-release"
#endif

#define CTAIL_VERSION_STRING    APR_STRINGIFY(CTAIL_MAJOR_VERSION) "." \
                                APR_STRINGIFY(CTAIL_MINOR_VERSION) "." \
                                APR_STRINGIFY(CTAIL_PATCH_VERSION) \
                                CTAIL_VER_ADD_STRING

#endif /* CTAIL_VERSION_H */
