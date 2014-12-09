# aclocal.m4 generated automatically by aclocal 1.6.3 -*- Autoconf -*-

# Copyright 1996, 1997, 1998, 1999, 2000, 2001, 2002
# Free Software Foundation, Inc.
# This file is free software; the Free Software Foundation
# gives unlimited permission to copy and/or distribute it,
# with or without modifications, as long as this notice is preserved.

# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY, to the extent permitted by law; without
# even the implied warranty of MERCHANTABILITY or FITNESS FOR A
# PARTICULAR PURPOSE.

dnl -------------------------------------------------------- -*- autoconf -*-
dnl Licensed to the Apache Software Foundation (ASF) under one or more
dnl contributor license agreements.  See the NOTICE file distributed with
dnl this work for additional information regarding copyright ownership.
dnl The ASF licenses this file to You under the Apache License, Version 2.0
dnl (the "License"); you may not use this file except in compliance with
dnl the License.  You may obtain a copy of the License at
dnl
dnl     http://www.apache.org/licenses/LICENSE-2.0
dnl
dnl Unless required by applicable law or agreed to in writing, software
dnl distributed under the License is distributed on an "AS IS" BASIS,
dnl WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
dnl See the License for the specific language governing permissions and
dnl limitations under the License.

dnl
dnl apr_common.m4: APR's general-purpose autoconf macros
dnl

dnl
dnl APR_CONFIG_NICE(filename)
dnl
dnl Saves a snapshot of the configure command-line for later reuse
dnl
AC_DEFUN([APR_CONFIG_NICE], [
  rm -f $1
  cat >$1<<EOF
#! /bin/sh
#
# Created by configure

EOF
  if test -n "$CC"; then
    echo "CC=\"$CC\"; export CC" >> $1
  fi
  if test -n "$CFLAGS"; then
    echo "CFLAGS=\"$CFLAGS\"; export CFLAGS" >> $1
  fi
  if test -n "$CPPFLAGS"; then
    echo "CPPFLAGS=\"$CPPFLAGS\"; export CPPFLAGS" >> $1
  fi
  if test -n "$LDFLAGS"; then
    echo "LDFLAGS=\"$LDFLAGS\"; export LDFLAGS" >> $1
  fi
  if test -n "$LTFLAGS"; then
    echo "LTFLAGS=\"$LTFLAGS\"; export LTFLAGS" >> $1
  fi
  if test -n "$LIBS"; then
    echo "LIBS=\"$LIBS\"; export LIBS" >> $1
  fi
  if test -n "$INCLUDES"; then
    echo "INCLUDES=\"$INCLUDES\"; export INCLUDES" >> $1
  fi
  if test -n "$NOTEST_CFLAGS"; then
    echo "NOTEST_CFLAGS=\"$NOTEST_CFLAGS\"; export NOTEST_CFLAGS" >> $1
  fi
  if test -n "$NOTEST_CPPFLAGS"; then
    echo "NOTEST_CPPFLAGS=\"$NOTEST_CPPFLAGS\"; export NOTEST_CPPFLAGS" >> $1
  fi
  if test -n "$NOTEST_LDFLAGS"; then
    echo "NOTEST_LDFLAGS=\"$NOTEST_LDFLAGS\"; export NOTEST_LDFLAGS" >> $1
  fi
  if test -n "$NOTEST_LIBS"; then
    echo "NOTEST_LIBS=\"$NOTEST_LIBS\"; export NOTEST_LIBS" >> $1
  fi

  # Retrieve command-line arguments.
  eval "set x $[0] $ac_configure_args"
  shift

  for arg
  do
    APR_EXPAND_VAR(arg, $arg)
    echo "\"[$]arg\" \\" >> $1
  done
  echo '"[$]@"' >> $1
  chmod +x $1
])dnl

dnl APR_MKDIR_P_CHECK(fallback-mkdir-p)
dnl checks whether mkdir -p works
AC_DEFUN([APR_MKDIR_P_CHECK], [
  AC_CACHE_CHECK(for working mkdir -p, ac_cv_mkdir_p,[
    test -d conftestdir && rm -rf conftestdir
    mkdir -p conftestdir/somedir >/dev/null 2>&1
    if test -d conftestdir/somedir; then
      ac_cv_mkdir_p=yes
    else
      ac_cv_mkdir_p=no
    fi
    rm -rf conftestdir
  ])
  if test "$ac_cv_mkdir_p" = "yes"; then
      mkdir_p="mkdir -p"
  else
      mkdir_p="$1"
  fi
])

dnl
dnl APR_SUBDIR_CONFIG(dir [, sub-package-cmdline-args, args-to-drop])
dnl
dnl dir: directory to find configure in
dnl sub-package-cmdline-args: arguments to add to the invocation (optional)
dnl args-to-drop: arguments to drop from the invocation (optional)
dnl
dnl Note: This macro relies on ac_configure_args being set properly.
dnl
dnl The args-to-drop argument is shoved into a case statement, so
dnl multiple arguments can be separated with a |.
dnl
dnl Note: Older versions of autoconf do not single-quote args, while 2.54+
dnl places quotes around every argument.  So, if you want to drop the
dnl argument called --enable-layout, you must pass the third argument as:
dnl [--enable-layout=*|\'--enable-layout=*]
dnl
dnl Trying to optimize this is left as an exercise to the reader who wants
dnl to put up with more autoconf craziness.  I give up.
dnl
AC_DEFUN([APR_SUBDIR_CONFIG], [
  # save our work to this point; this allows the sub-package to use it
  AC_CACHE_SAVE

  echo "configuring package in $1 now"
  ac_popdir=`pwd`
  apr_config_subdirs="$1"
  test -d $1 || $mkdir_p $1
  ac_abs_srcdir=`(cd $srcdir/$1 && pwd)`
  cd $1

changequote(, )dnl
      # A "../" for each directory in /$config_subdirs.
      ac_dots=`echo $apr_config_subdirs|sed -e 's%^\./%%' -e 's%[^/]$%&/%' -e 's%[^/]*/%../%g'`
changequote([, ])dnl

  # Make the cache file pathname absolute for the subdirs
  # required to correctly handle subdirs that might actually
  # be symlinks
  case "$cache_file" in
  /*) # already absolute
    ac_sub_cache_file=$cache_file ;;
  *)  # Was relative path.
    ac_sub_cache_file="$ac_popdir/$cache_file" ;;
  esac

  ifelse($3, [], [apr_configure_args=$ac_configure_args],[
  apr_configure_args=
  apr_sep=
  for apr_configure_arg in $ac_configure_args
  do
    case "$apr_configure_arg" in
      $3)
        continue ;;
    esac
    apr_configure_args="$apr_configure_args$apr_sep'$apr_configure_arg'"
    apr_sep=" "
  done
  ])

  # autoconf doesn't add --silent to ac_configure_args; explicitly pass it
  test "x$silent" = "xyes" && apr_configure_args="$apr_configure_args --silent"

  dnl The eval makes quoting arguments work - specifically $2 where the
  dnl quoting mechanisms used is "" rather than [].
  dnl
  dnl We need to execute another shell because some autoconf/shell combinations
  dnl will choke after doing repeated APR_SUBDIR_CONFIG()s.  (Namely Solaris
  dnl and autoconf-2.54+)
  if eval $SHELL $ac_abs_srcdir/configure $apr_configure_args --cache-file=$ac_sub_cache_file --srcdir=$ac_abs_srcdir $2
  then :
    echo "$1 configured properly"
  else
    echo "configure failed for $1"
    exit 1
  fi

  cd $ac_popdir

  # grab any updates from the sub-package
  AC_CACHE_LOAD
])dnl

dnl
dnl APR_SAVE_THE_ENVIRONMENT(variable_name)
dnl
dnl Stores the variable (usually a Makefile macro) for later restoration
dnl
AC_DEFUN([APR_SAVE_THE_ENVIRONMENT], [
  apr_ste_save_$1="$$1"
])dnl

dnl
dnl APR_RESTORE_THE_ENVIRONMENT(variable_name, prefix_)
dnl
dnl Uses the previously saved variable content to figure out what configure
dnl has added to the variable, moving the new bits to prefix_variable_name
dnl and restoring the original variable contents.  This makes it possible
dnl for a user to override configure when it does something stupid.
dnl
AC_DEFUN([APR_RESTORE_THE_ENVIRONMENT], [
if test "x$apr_ste_save_$1" = "x"; then
  $2$1="$$1"
  $1=
else
  if test "x$apr_ste_save_$1" = "x$$1"; then
    $2$1=
  else
    $2$1=`echo $$1 | sed -e "s%${apr_ste_save_$1}%%"`
    $1="$apr_ste_save_$1"
  fi
fi
if test "x$silent" != "xyes"; then
  echo "  restoring $1 to \"$$1\""
  echo "  setting $2$1 to \"$$2$1\""
fi
AC_SUBST($2$1)
])dnl

dnl
dnl APR_SETIFNULL(variable, value)
dnl
dnl  Set variable iff it's currently null
dnl
AC_DEFUN([APR_SETIFNULL], [
  if test -z "$$1"; then
    test "x$silent" != "xyes" && echo "  setting $1 to \"$2\""
    $1="$2"
  fi
])dnl

dnl
dnl APR_SETVAR(variable, value)
dnl
dnl  Set variable no matter what
dnl
AC_DEFUN([APR_SETVAR], [
  test "x$silent" != "xyes" && echo "  forcing $1 to \"$2\""
  $1="$2"
])dnl

dnl
dnl APR_ADDTO(variable, value)
dnl
dnl  Add value to variable
dnl
AC_DEFUN([APR_ADDTO], [
  if test "x$$1" = "x"; then
    test "x$silent" != "xyes" && echo "  setting $1 to \"$2\""
    $1="$2"
  else
    apr_addto_bugger="$2"
    for i in $apr_addto_bugger; do
      apr_addto_duplicate="0"
      for j in $$1; do
        if test "x$i" = "x$j"; then
          apr_addto_duplicate="1"
          break
        fi
      done
      if test $apr_addto_duplicate = "0"; then
        test "x$silent" != "xyes" && echo "  adding \"$i\" to $1"
        $1="$$1 $i"
      fi
    done
  fi
])dnl

dnl
dnl APR_REMOVEFROM(variable, value)
dnl
dnl Remove a value from a variable
dnl
AC_DEFUN([APR_REMOVEFROM], [
  if test "x$$1" = "x$2"; then
    test "x$silent" != "xyes" && echo "  nulling $1"
    $1=""
  else
    apr_new_bugger=""
    apr_removed=0
    for i in $$1; do
      if test "x$i" != "x$2"; then
        apr_new_bugger="$apr_new_bugger $i"
      else
        apr_removed=1
      fi
    done
    if test $apr_removed = "1"; then
      test "x$silent" != "xyes" && echo "  removed \"$2\" from $1"
      $1=$apr_new_bugger
    fi
  fi
]) dnl

dnl
dnl APR_CHECK_DEFINE_FILES( symbol, header_file [header_file ...] )
dnl
AC_DEFUN([APR_CHECK_DEFINE_FILES], [
  AC_CACHE_CHECK([for $1 in $2],ac_cv_define_$1,[
    ac_cv_define_$1=no
    for curhdr in $2
    do
      AC_EGREP_CPP(YES_IS_DEFINED, [
#include <$curhdr>
#ifdef $1
YES_IS_DEFINED
#endif
      ], ac_cv_define_$1=yes)
    done
  ])
  if test "$ac_cv_define_$1" = "yes"; then
    AC_DEFINE(HAVE_$1, 1, [Define if $1 is defined])
  fi
])


dnl
dnl APR_CHECK_DEFINE(symbol, header_file)
dnl
AC_DEFUN([APR_CHECK_DEFINE], [
  AC_CACHE_CHECK([for $1 in $2],ac_cv_define_$1,[
    AC_EGREP_CPP(YES_IS_DEFINED, [
#include <$2>
#ifdef $1
YES_IS_DEFINED
#endif
    ], ac_cv_define_$1=yes, ac_cv_define_$1=no)
  ])
  if test "$ac_cv_define_$1" = "yes"; then
    AC_DEFINE(HAVE_$1, 1, [Define if $1 is defined in $2])
  fi
])

dnl
dnl APR_CHECK_APR_DEFINE( symbol )
dnl
AC_DEFUN([APR_CHECK_APR_DEFINE], [
apr_old_cppflags=$CPPFLAGS
CPPFLAGS="$CPPFLAGS $INCLUDES"
AC_EGREP_CPP(YES_IS_DEFINED, [
#include <apr.h>
#if $1
YES_IS_DEFINED
#endif
], ac_cv_define_$1=yes, ac_cv_define_$1=no)
CPPFLAGS=$apr_old_cppflags
])

dnl APR_CHECK_FILE(filename); set ac_cv_file_filename to
dnl "yes" if 'filename' is readable, else "no".
dnl @deprecated! - use AC_CHECK_FILE instead
AC_DEFUN([APR_CHECK_FILE], [
dnl Pick a safe variable name
define([apr_cvname], ac_cv_file_[]translit([$1], [./+-], [__p_]))
AC_CACHE_CHECK([for $1], [apr_cvname],
[if test -r $1; then
   apr_cvname=yes
 else
   apr_cvname=no
 fi])
])

define(APR_IFALLYES,[dnl
ac_rc=yes
for ac_spec in $1; do
    ac_type=`echo "$ac_spec" | sed -e 's/:.*$//'`
    ac_item=`echo "$ac_spec" | sed -e 's/^.*://'`
    case $ac_type in
        header )
            ac_item=`echo "$ac_item" | sed 'y%./+-%__p_%'`
            ac_var="ac_cv_header_$ac_item"
            ;;
        file )
            ac_item=`echo "$ac_item" | sed 'y%./+-%__p_%'`
            ac_var="ac_cv_file_$ac_item"
            ;;
        func )   ac_var="ac_cv_func_$ac_item"   ;;
        struct ) ac_var="ac_cv_struct_$ac_item" ;;
        define ) ac_var="ac_cv_define_$ac_item" ;;
        custom ) ac_var="$ac_item" ;;
    esac
    eval "ac_val=\$$ac_var"
    if test ".$ac_val" != .yes; then
        ac_rc=no
        break
    fi
done
if test ".$ac_rc" = .yes; then
    :
    $2
else
    :
    $3
fi
])


define(APR_BEGIN_DECISION,[dnl
ac_decision_item='$1'
ac_decision_msg='FAILED'
ac_decision=''
])


AC_DEFUN([APR_DECIDE],[dnl
dnl Define the flag (or not) in apr_private.h via autoheader
AH_TEMPLATE($1, [Define if $2 will be used])
ac_decision='$1'
ac_decision_msg='$2'
ac_decision_$1=yes
ac_decision_$1_msg='$2'
])


define(APR_DECISION_OVERRIDE,[dnl
    ac_decision=''
    for ac_item in $1; do
         eval "ac_decision_this=\$ac_decision_${ac_item}"
         if test ".$ac_decision_this" = .yes; then
             ac_decision=$ac_item
             eval "ac_decision_msg=\$ac_decision_${ac_item}_msg"
         fi
    done
])


define(APR_DECISION_FORCE,[dnl
ac_decision="$1"
eval "ac_decision_msg=\"\$ac_decision_${ac_decision}_msg\""
])


define(APR_END_DECISION,[dnl
if test ".$ac_decision" = .; then
    echo "[$]0:Error: decision on $ac_decision_item failed" 1>&2
    exit 1
else
    if test ".$ac_decision_msg" = .; then
        ac_decision_msg="$ac_decision"
    fi
    AC_DEFINE_UNQUOTED(${ac_decision_item})
    AC_MSG_RESULT([decision on $ac_decision_item... $ac_decision_msg])
fi
])


dnl
dnl APR_CHECK_SIZEOF_EXTENDED(INCLUDES, TYPE [, CROSS_SIZE])
dnl
dnl A variant of AC_CHECK_SIZEOF which allows the checking of
dnl sizes of non-builtin types
dnl
AC_DEFUN([APR_CHECK_SIZEOF_EXTENDED],
[changequote(<<, >>)dnl
dnl The name to #define.
define(<<AC_TYPE_NAME>>, translit(sizeof_$2, [a-z *], [A-Z_P]))dnl
dnl The cache variable name.
define(<<AC_CV_NAME>>, translit(ac_cv_sizeof_$2, [ *], [_p]))dnl
changequote([, ])dnl
AC_MSG_CHECKING(size of $2)
AC_CACHE_VAL(AC_CV_NAME,
[AC_TRY_RUN([#include <stdio.h>
$1
main()
{
  FILE *f=fopen("conftestval", "w");
  if (!f) exit(1);
  fprintf(f, "%d\n", sizeof($2));
  exit(0);
}], AC_CV_NAME=`cat conftestval`, AC_CV_NAME=0, ifelse([$3],,,
AC_CV_NAME=$3))])dnl
AC_MSG_RESULT($AC_CV_NAME)
AC_DEFINE_UNQUOTED(AC_TYPE_NAME, $AC_CV_NAME, [The size of ]$2)
undefine([AC_TYPE_NAME])dnl
undefine([AC_CV_NAME])dnl
])


dnl
dnl APR_TRY_COMPILE_NO_WARNING(INCLUDES, FUNCTION-BODY,
dnl             [ACTIONS-IF-NO-WARNINGS], [ACTIONS-IF-WARNINGS])
dnl
dnl Tries a compile test with warnings activated so that the result
dnl is false if the code doesn't compile cleanly.  For compilers
dnl where it is not known how to activate a "fail-on-error" mode,
dnl it is undefined which of the sets of actions will be run.
dnl
AC_DEFUN([APR_TRY_COMPILE_NO_WARNING],
[apr_save_CFLAGS=$CFLAGS
 CFLAGS="$CFLAGS $CFLAGS_WARN"
 if test "$ac_cv_prog_gcc" = "yes"; then 
   CFLAGS="$CFLAGS -Werror"
 fi
 AC_COMPILE_IFELSE(
  [#include "confdefs.h"
  ]
  [[$1]]
  [int main(int argc, const char *const *argv) {]
  [[$2]]
  [   return 0; }],
  [$3], [$4])
 CFLAGS=$apr_save_CFLAGS
])

dnl
dnl APR_CHECK_STRERROR_R_RC
dnl
dnl  Decide which style of retcode is used by this system's 
dnl  strerror_r().  It either returns int (0 for success, -1
dnl  for failure), or it returns a pointer to the error 
dnl  string.
dnl
dnl
AC_DEFUN([APR_CHECK_STRERROR_R_RC], [
AC_MSG_CHECKING(for type of return code from strerror_r)
AC_TRY_RUN([
#include <errno.h>
#include <string.h>
#include <stdio.h>
main()
{
  char buf[1024];
  if (strerror_r(ERANGE, buf, sizeof buf) < 1) {
    exit(0);
  }
  else {
    exit(1);
  }
}], [
    ac_cv_strerror_r_rc_int=yes ], [
    ac_cv_strerror_r_rc_int=no ], [
    ac_cv_strerror_r_rc_int=no ] )
if test "x$ac_cv_strerror_r_rc_int" = xyes; then
  AC_DEFINE(STRERROR_R_RC_INT, 1, [Define if strerror returns int])
  msg="int"
else
  msg="pointer"
fi
AC_MSG_RESULT([$msg])
] )

dnl
dnl APR_CHECK_DIRENT_INODE
dnl
dnl  Decide if d_fileno or d_ino are available in the dirent
dnl  structure on this platform.  Single UNIX Spec says d_ino,
dnl  BSD uses d_fileno.  Undef to find the real beast.
dnl
AC_DEFUN([APR_CHECK_DIRENT_INODE], [
AC_CACHE_CHECK([for inode member of struct dirent], apr_cv_dirent_inode, [
apr_cv_dirent_inode=no
AC_TRY_COMPILE([
#include <sys/types.h>
#include <dirent.h>
],[
#ifdef d_ino
#undef d_ino
#endif
struct dirent de; de.d_fileno;
], apr_cv_dirent_inode=d_fileno)
if test "$apr_cv_dirent_inode" = "no"; then
AC_TRY_COMPILE([
#include <sys/types.h>
#include <dirent.h>
],[
#ifdef d_fileno
#undef d_fileno
#endif
struct dirent de; de.d_ino;
], apr_cv_dirent_inode=d_ino)
fi
])
if test "$apr_cv_dirent_inode" != "no"; then
  AC_DEFINE_UNQUOTED(DIRENT_INODE, $apr_cv_dirent_inode, 
    [Define if struct dirent has an inode member])
fi
])

dnl
dnl APR_CHECK_DIRENT_TYPE
dnl
dnl  Decide if d_type is available in the dirent structure 
dnl  on this platform.  Not part of the Single UNIX Spec.
dnl  Note that this is worthless without DT_xxx macros, so
dnl  look for one while we are at it.
dnl
AC_DEFUN([APR_CHECK_DIRENT_TYPE], [
AC_CACHE_CHECK([for file type member of struct dirent], apr_cv_dirent_type,[
apr_cv_dirent_type=no
AC_TRY_COMPILE([
#include <sys/types.h>
#include <dirent.h>
],[
struct dirent de; de.d_type = DT_REG;
], apr_cv_dirent_type=d_type)
])
if test "$apr_cv_dirent_type" != "no"; then
  AC_DEFINE_UNQUOTED(DIRENT_TYPE, $apr_cv_dirent_type, 
    [Define if struct dirent has a d_type member]) 
fi
])

dnl the following is a newline, a space, a tab, and a backslash (the
dnl backslash is used by the shell to skip newlines, but m4 sees it;
dnl treat it like whitespace).
dnl WARNING: don't reindent these lines, or the space/tab will be lost!
define([apr_whitespace],[
 	\])

dnl
dnl APR_COMMA_ARGS(ARG1 ...)
dnl  convert the whitespace-separated arguments into comman-separated
dnl  arguments.
dnl
dnl APR_FOREACH(CODE-BLOCK, ARG1, ARG2, ...)
dnl  subsitute CODE-BLOCK for each ARG[i]. "eachval" will be set to ARG[i]
dnl  within each iteration.
dnl
changequote({,})
define({APR_COMMA_ARGS},{patsubst([$}{1],[[}apr_whitespace{]+],[,])})
define({APR_FOREACH},
  {ifelse($}{2,,,
          [define([eachval],
                  $}{2)$}{1[]APR_FOREACH([$}{1],
                                         builtin([shift],
                                                 builtin([shift], $}{@)))])})
changequote([,])

dnl APR_FLAG_HEADERS(HEADER-FILE ... [, FLAG-TO-SET ] [, "yes" ])
dnl  we set FLAG-TO-SET to 1 if we find HEADER-FILE, otherwise we set to 0
dnl  if FLAG-TO-SET is null, we automagically determine it's name
dnl  by changing all "/" to "_" in the HEADER-FILE and dropping
dnl  all "." and "-" chars. If the 3rd parameter is "yes" then instead of
dnl  setting to 1 or 0, we set FLAG-TO-SET to yes or no.
dnl  
AC_DEFUN([APR_FLAG_HEADERS], [
AC_CHECK_HEADERS($1)
for aprt_i in $1
do
    ac_safe=`echo "$aprt_i" | sed 'y%./+-%__p_%'`
    aprt_2=`echo "$aprt_i" | sed -e 's%/%_%g' -e 's/\.//g' -e 's/-//g'`
    if eval "test \"`echo '$ac_cv_header_'$ac_safe`\" = yes"; then
       eval "ifelse($2,,$aprt_2,$2)=ifelse($3,yes,yes,1)"
    else
       eval "ifelse($2,,$aprt_2,$2)=ifelse($3,yes,no,0)"
    fi
done
])

dnl APR_FLAG_FUNCS(FUNC ... [, FLAG-TO-SET] [, "yes" ])
dnl  if FLAG-TO-SET is null, we automagically determine it's name
dnl  prepending "have_" to the function name in FUNC, otherwise
dnl  we use what's provided as FLAG-TO-SET. If the 3rd parameter
dnl  is "yes" then instead of setting to 1 or 0, we set FLAG-TO-SET
dnl  to yes or no.
dnl
AC_DEFUN([APR_FLAG_FUNCS], [
AC_CHECK_FUNCS($1)
for aprt_j in $1
do
    aprt_3="have_$aprt_j"
    if eval "test \"`echo '$ac_cv_func_'$aprt_j`\" = yes"; then
       eval "ifelse($2,,$aprt_3,$2)=ifelse($3,yes,yes,1)"
    else
       eval "ifelse($2,,$aprt_3,$2)=ifelse($3,yes,no,0)"
    fi
done
])

dnl Iteratively interpolate the contents of the second argument
dnl until interpolation offers no new result. Then assign the
dnl final result to $1.
dnl
dnl Example:
dnl
dnl foo=1
dnl bar='${foo}/2'
dnl baz='${bar}/3'
dnl APR_EXPAND_VAR(fraz, $baz)
dnl   $fraz is now "1/2/3"
dnl 
AC_DEFUN([APR_EXPAND_VAR], [
ap_last=
ap_cur="$2"
while test "x${ap_cur}" != "x${ap_last}";
do
  ap_last="${ap_cur}"
  ap_cur=`eval "echo ${ap_cur}"`
done
$1="${ap_cur}"
])

dnl
dnl Removes the value of $3 from the string in $2, strips of any leading
dnl slashes, and returns the value in $1.
dnl
dnl Example:
dnl orig_path="${prefix}/bar"
dnl APR_PATH_RELATIVE(final_path, $orig_path, $prefix)
dnl    $final_path now contains "bar"
AC_DEFUN([APR_PATH_RELATIVE], [
ap_stripped=`echo $2 | sed -e "s#^$3##"`
# check if the stripping was successful
if test "x$2" != "x${ap_stripped}"; then
    # it was, so strip of any leading slashes
    $1="`echo ${ap_stripped} | sed -e 's#^/*##'`"
else
    # it wasn't so return the original
    $1="$2"
fi
])

dnl APR_HELP_STRING(LHS, RHS)
dnl Autoconf 2.50 can not handle substr correctly.  It does have 
dnl AC_HELP_STRING, so let's try to call it if we can.
dnl Note: this define must be on one line so that it can be properly returned
dnl as the help string.  When using this macro with a multi-line RHS, ensure
dnl that you surround the macro invocation with []s
AC_DEFUN([APR_HELP_STRING], [ifelse(regexp(AC_ACVERSION, 2\.1), -1, AC_HELP_STRING([$1],[$2]),[  ][$1] substr([                       ],len($1))[$2])])

dnl
dnl APR_LAYOUT(configlayout, layoutname [, extravars])
dnl
AC_DEFUN([APR_LAYOUT], [
  if test ! -f $srcdir/config.layout; then
    echo "** Error: Layout file $srcdir/config.layout not found"
    echo "** Error: Cannot use undefined layout '$LAYOUT'"
    exit 1
  fi
  # Catch layout names including a slash which will otherwise
  # confuse the heck out of the sed script.
  case $2 in
  */*) 
    echo "** Error: $2 is not a valid layout name"
    exit 1 ;;
  esac
  pldconf=./config.pld
  changequote({,})
  sed -e "1s/[ 	]*<[lL]ayout[ 	]*$2[ 	]*>[ 	]*//;1t" \
      -e "1,/[ 	]*<[lL]ayout[ 	]*$2[ 	]*>[ 	]*/d" \
      -e '/[ 	]*<\/Layout>[ 	]*/,$d' \
      -e "s/^[ 	]*//g" \
      -e "s/:[ 	]*/=\'/g" \
      -e "s/[ 	]*$/'/g" \
      $1 > $pldconf
  layout_name=$2
  if test ! -s $pldconf; then
    echo "** Error: unable to find layout $layout_name"
    exit 1
  fi
  . $pldconf
  rm $pldconf
  for var in prefix exec_prefix bindir sbindir libexecdir mandir \
             sysconfdir datadir includedir localstatedir runtimedir \
             logfiledir libdir installbuilddir libsuffix $3; do
    eval "val=\"\$$var\""
    case $val in
      *+)
        val=`echo $val | sed -e 's;\+$;;'`
        eval "$var=\"\$val\""
        autosuffix=yes
        ;;
      *)
        autosuffix=no
        ;;
    esac
    val=`echo $val | sed -e 's:\(.\)/*$:\1:'`
    val=`echo $val | sed -e 's:[\$]\([a-z_]*\):${\1}:g'`
    if test "$autosuffix" = "yes"; then
      if echo $val | grep apache >/dev/null; then
        addtarget=no
      else
        addtarget=yes
      fi
      if test "$addtarget" = "yes"; then
        val="$val/apache2"
      fi
    fi
    eval "$var='$val'"
  done
  changequote([,])
])dnl

dnl
dnl APR_ENABLE_LAYOUT(default layout name [, extra vars])
dnl
AC_DEFUN([APR_ENABLE_LAYOUT], [
AC_ARG_ENABLE(layout,
[  --enable-layout=LAYOUT],[
  LAYOUT=$enableval
])

if test -z "$LAYOUT"; then
  LAYOUT="$1"
fi
APR_LAYOUT($srcdir/config.layout, $LAYOUT, $2)

AC_MSG_CHECKING(for chosen layout)
AC_MSG_RESULT($layout_name)
])


dnl
dnl APR_PARSE_ARGUMENTS
dnl a reimplementation of autoconf's argument parser,
dnl used here to allow us to co-exist layouts and argument based
dnl set ups.
AC_DEFUN([APR_PARSE_ARGUMENTS], [
ac_prev=
# Retrieve the command-line arguments.  The eval is needed because
# the arguments are quoted to preserve accuracy.
eval "set x $ac_configure_args"
shift
for ac_option
do
  # If the previous option needs an argument, assign it.
  if test -n "$ac_prev"; then
    eval "$ac_prev=\$ac_option"
    ac_prev=
    continue
  fi

  ac_optarg=`expr "x$ac_option" : 'x[[^=]]*=\(.*\)'`

  case $ac_option in

  -bindir | --bindir | --bindi | --bind | --bin | --bi)
    ac_prev=bindir ;;
  -bindir=* | --bindir=* | --bindi=* | --bind=* | --bin=* | --bi=*)
    bindir="$ac_optarg" ;;

  -datadir | --datadir | --datadi | --datad | --data | --dat | --da)
    ac_prev=datadir ;;
  -datadir=* | --datadir=* | --datadi=* | --datad=* | --data=* | --dat=* \
  | --da=*)
    datadir="$ac_optarg" ;;

  -exec-prefix | --exec_prefix | --exec-prefix | --exec-prefi \
  | --exec-pref | --exec-pre | --exec-pr | --exec-p | --exec- \
  | --exec | --exe | --ex)
    ac_prev=exec_prefix ;;
  -exec-prefix=* | --exec_prefix=* | --exec-prefix=* | --exec-prefi=* \
  | --exec-pref=* | --exec-pre=* | --exec-pr=* | --exec-p=* | --exec-=* \
  | --exec=* | --exe=* | --ex=*)
    exec_prefix="$ac_optarg" ;;

  -includedir | --includedir | --includedi | --included | --include \
  | --includ | --inclu | --incl | --inc)
    ac_prev=includedir ;;
  -includedir=* | --includedir=* | --includedi=* | --included=* | --include=* \
  | --includ=* | --inclu=* | --incl=* | --inc=*)
    includedir="$ac_optarg" ;;

  -infodir | --infodir | --infodi | --infod | --info | --inf)
    ac_prev=infodir ;;
  -infodir=* | --infodir=* | --infodi=* | --infod=* | --info=* | --inf=*)
    infodir="$ac_optarg" ;;

  -libdir | --libdir | --libdi | --libd)
    ac_prev=libdir ;;
  -libdir=* | --libdir=* | --libdi=* | --libd=*)
    libdir="$ac_optarg" ;;

  -libexecdir | --libexecdir | --libexecdi | --libexecd | --libexec \
  | --libexe | --libex | --libe)
    ac_prev=libexecdir ;;
  -libexecdir=* | --libexecdir=* | --libexecdi=* | --libexecd=* | --libexec=* \
  | --libexe=* | --libex=* | --libe=*)
    libexecdir="$ac_optarg" ;;

  -localstatedir | --localstatedir | --localstatedi | --localstated \
  | --localstate | --localstat | --localsta | --localst \
  | --locals | --local | --loca | --loc | --lo)
    ac_prev=localstatedir ;;
  -localstatedir=* | --localstatedir=* | --localstatedi=* | --localstated=* \
  | --localstate=* | --localstat=* | --localsta=* | --localst=* \
  | --locals=* | --local=* | --loca=* | --loc=* | --lo=*)
    localstatedir="$ac_optarg" ;;

  -mandir | --mandir | --mandi | --mand | --man | --ma | --m)
    ac_prev=mandir ;;
  -mandir=* | --mandir=* | --mandi=* | --mand=* | --man=* | --ma=* | --m=*)
    mandir="$ac_optarg" ;;

  -prefix | --prefix | --prefi | --pref | --pre | --pr | --p)
    ac_prev=prefix ;;
  -prefix=* | --prefix=* | --prefi=* | --pref=* | --pre=* | --pr=* | --p=*)
    prefix="$ac_optarg" ;;

  -sbindir | --sbindir | --sbindi | --sbind | --sbin | --sbi | --sb)
    ac_prev=sbindir ;;
  -sbindir=* | --sbindir=* | --sbindi=* | --sbind=* | --sbin=* \
  | --sbi=* | --sb=*)
    sbindir="$ac_optarg" ;;

  -sharedstatedir | --sharedstatedir | --sharedstatedi \
  | --sharedstated | --sharedstate | --sharedstat | --sharedsta \
  | --sharedst | --shareds | --shared | --share | --shar \
  | --sha | --sh)
    ac_prev=sharedstatedir ;;
  -sharedstatedir=* | --sharedstatedir=* | --sharedstatedi=* \
  | --sharedstated=* | --sharedstate=* | --sharedstat=* | --sharedsta=* \
  | --sharedst=* | --shareds=* | --shared=* | --share=* | --shar=* \
  | --sha=* | --sh=*)
    sharedstatedir="$ac_optarg" ;;

  -sysconfdir | --sysconfdir | --sysconfdi | --sysconfd | --sysconf \
  | --syscon | --sysco | --sysc | --sys | --sy)
    ac_prev=sysconfdir ;;
  -sysconfdir=* | --sysconfdir=* | --sysconfdi=* | --sysconfd=* | --sysconf=* \
  | --syscon=* | --sysco=* | --sysc=* | --sys=* | --sy=*)
    sysconfdir="$ac_optarg" ;;

  esac
done

# Be sure to have absolute paths.
for ac_var in exec_prefix prefix
do
  eval ac_val=$`echo $ac_var`
  case $ac_val in
    [[\\/$]]* | ?:[[\\/]]* | NONE | '' ) ;;
    *)  AC_MSG_ERROR([expected an absolute path for --$ac_var: $ac_val]);;
  esac
done

])dnl

dnl
dnl APR_CHECK_DEPEND
dnl
dnl Determine what program we can use to generate .deps-style dependencies
dnl
AC_DEFUN([APR_CHECK_DEPEND], [
dnl Try to determine what depend program we can use
dnl All GCC-variants should have -MM.
dnl If not, then we can check on those, too.
if test "$GCC" = "yes"; then
  MKDEP='$(CC) -MM'
else
  rm -f conftest.c
dnl <sys/types.h> should be available everywhere!
  cat > conftest.c <<EOF
#include <sys/types.h>
  int main() { return 0; }
EOF
  MKDEP="true"
  for i in "$CC -MM" "$CC -M" "$CPP -MM" "$CPP -M" "cpp -M"; do
    AC_MSG_CHECKING([if $i can create proper make dependencies])
    if $i conftest.c 2>/dev/null | grep 'conftest.o: conftest.c' >/dev/null; then
      MKDEP=$i
      AC_MSG_RESULT(yes)
      break;
    fi
    AC_MSG_RESULT(no)
  done
  rm -f conftest.c
fi

AC_SUBST(MKDEP)
])

dnl -------------------------------------------------------- -*- autoconf -*-
dnl Licensed to the Apache Software Foundation (ASF) under one or more
dnl contributor license agreements.  See the NOTICE file distributed with
dnl this work for additional information regarding copyright ownership.
dnl The ASF licenses this file to You under the Apache License, Version 2.0
dnl (the "License"); you may not use this file except in compliance with
dnl the License.  You may obtain a copy of the License at
dnl
dnl     http://www.apache.org/licenses/LICENSE-2.0
dnl
dnl Unless required by applicable law or agreed to in writing, software
dnl distributed under the License is distributed on an "AS IS" BASIS,
dnl WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
dnl See the License for the specific language governing permissions and
dnl limitations under the License.

dnl
dnl find_apr.m4 : locate the APR include files and libraries
dnl
dnl This macro file can be used by applications to find and use the APR
dnl library. It provides a standardized mechanism for using APR. It supports
dnl embedding APR into the application source, or locating an installed
dnl copy of APR.
dnl
dnl APR_FIND_APR(srcdir, builddir, implicit-install-check, acceptable-majors,
dnl              detailed-check)
dnl
dnl   where srcdir is the location of the bundled APR source directory, or
dnl   empty if source is not bundled.
dnl
dnl   where builddir is the location where the bundled APR will will be built,
dnl   or empty if the build will occur in the srcdir.
dnl
dnl   where implicit-install-check set to 1 indicates if there is no
dnl   --with-apr option specified, we will look for installed copies.
dnl
dnl   where acceptable-majors is a space separated list of acceptable major
dnl   version numbers. Often only a single major version will be acceptable.
dnl   If multiple versions are specified, and --with-apr=PREFIX or the
dnl   implicit installed search are used, then the first (leftmost) version
dnl   in the list that is found will be used.  Currently defaults to [0 1].
dnl
dnl   where detailed-check is an M4 macro which sets the apr_acceptable to
dnl   either "yes" or "no". The macro will be invoked for each installed
dnl   copy of APR found, with the apr_config variable set appropriately.
dnl   Only installed copies of APR which are considered acceptable by
dnl   this macro will be considered found. If no installed copies are
dnl   considered acceptable by this macro, apr_found will be set to either
dnl   either "no" or "reconfig".
dnl
dnl Sets the following variables on exit:
dnl
dnl   apr_found : "yes", "no", "reconfig"
dnl
dnl   apr_config : If the apr-config tool exists, this refers to it. If
dnl                apr_found is "reconfig", then the bundled directory
dnl                should be reconfigured *before* using apr_config.
dnl
dnl Note: this macro file assumes that apr-config has been installed; it
dnl       is normally considered a required part of an APR installation.
dnl
dnl If a bundled source directory is available and needs to be (re)configured,
dnl then apr_found is set to "reconfig". The caller should reconfigure the
dnl (passed-in) source directory, placing the result in the build directory,
dnl as appropriate.
dnl
dnl If apr_found is "yes" or "reconfig", then the caller should use the
dnl value of apr_config to fetch any necessary build/link information.
dnl

AC_DEFUN([APR_FIND_APR], [
  apr_found="no"

  if test "$target_os" = "os2-emx"; then
    # Scripts don't pass test -x on OS/2
    TEST_X="test -f"
  else
    TEST_X="test -x"
  fi

  ifelse([$4], [], [
         ifdef(AC_WARNING,AC_WARNING([$0: missing argument 4 (acceptable-majors): Defaulting to APR 0.x then APR 1.x]))
         acceptable_majors="0 1"],
         [acceptable_majors="$4"])

  apr_temp_acceptable_apr_config=""
  for apr_temp_major in $acceptable_majors
  do
    case $apr_temp_major in
      0)
      apr_temp_acceptable_apr_config="$apr_temp_acceptable_apr_config apr-config"
      ;;
      *)
      apr_temp_acceptable_apr_config="$apr_temp_acceptable_apr_config apr-$apr_temp_major-config"
      ;;
    esac
  done

  AC_MSG_CHECKING(for APR)
  AC_ARG_WITH(apr,
  [  --with-apr=PATH         prefix for installed APR or the full path to 
                             apr-config],
  [
    if test "$withval" = "no" || test "$withval" = "yes"; then
      AC_MSG_ERROR([--with-apr requires a directory or file to be provided])
    fi

    for apr_temp_apr_config_file in $apr_temp_acceptable_apr_config
    do
      for lookdir in "$withval/bin" "$withval"
      do
        if $TEST_X "$lookdir/$apr_temp_apr_config_file"; then
          apr_config="$lookdir/$apr_temp_apr_config_file"
          ifelse([$5], [], [], [
          apr_acceptable="yes"
          $5
          if test "$apr_acceptable" != "yes"; then
            AC_MSG_WARN([Found APR in $apr_config, but we think it is considered unacceptable])
            continue
          fi])
          apr_found="yes"
          break 2
        fi
      done
    done

    if test "$apr_found" != "yes" && $TEST_X "$withval" && $withval --help > /dev/null 2>&1 ; then
      apr_config="$withval"
      ifelse([$5], [], [apr_found="yes"], [
          apr_acceptable="yes"
          $5
          if test "$apr_acceptable" = "yes"; then
                apr_found="yes"
          fi])
    fi

    dnl if --with-apr is used, it is a fatal error for its argument
    dnl to be invalid
    if test "$apr_found" != "yes"; then
      AC_MSG_ERROR([the --with-apr parameter is incorrect. It must specify an install prefix, a build directory, or an apr-config file.])
    fi
  ],[
    dnl If we allow installed copies, check those before using bundled copy.
    if test -n "$3" && test "$3" = "1"; then
      for apr_temp_apr_config_file in $apr_temp_acceptable_apr_config
      do
        if $apr_temp_apr_config_file --help > /dev/null 2>&1 ; then
          apr_config="$apr_temp_apr_config_file"
          ifelse([$5], [], [], [
          apr_acceptable="yes"
          $5
          if test "$apr_acceptable" != "yes"; then
            AC_MSG_WARN([skipped APR at $apr_config, version not acceptable])
            continue
          fi])
          apr_found="yes"
          break
        else
          dnl look in some standard places
          for lookdir in /usr /usr/local /usr/local/apr /opt/apr; do
            if $TEST_X "$lookdir/bin/$apr_temp_apr_config_file"; then
              apr_config="$lookdir/bin/$apr_temp_apr_config_file"
              ifelse([$5], [], [], [
              apr_acceptable="yes"
              $5
              if test "$apr_acceptable" != "yes"; then
                AC_MSG_WARN([skipped APR at $apr_config, version not acceptable])
                continue
              fi])
              apr_found="yes"
              break 2
            fi
          done
        fi
      done
    fi
    dnl if we have not found anything yet and have bundled source, use that
    if test "$apr_found" = "no" && test -d "$1"; then
      apr_temp_abs_srcdir="`cd $1 && pwd`"
      apr_found="reconfig"
      apr_bundled_major="`sed -n '/#define.*APR_MAJOR_VERSION/s/^[^0-9]*\([0-9]*\).*$/\1/p' \"$1/include/apr_version.h\"`"
      case $apr_bundled_major in
        "")
          AC_MSG_ERROR([failed to find major version of bundled APR])
        ;;
        0)
          apr_temp_apr_config_file="apr-config"
        ;;
        *)
          apr_temp_apr_config_file="apr-$apr_bundled_major-config"
        ;;
      esac
      if test -n "$2"; then
        apr_config="$2/$apr_temp_apr_config_file"
      else
        apr_config="$1/$apr_temp_apr_config_file"
      fi
    fi
  ])

  AC_MSG_RESULT($apr_found)
])

dnl -------------------------------------------------------- -*- autoconf -*-
dnl Copyright 2002-2005 The Apache Software Foundation or its licensors, as
dnl applicable.
dnl
dnl Licensed under the Apache License, Version 2.0 (the "License");
dnl you may not use this file except in compliance with the License.
dnl You may obtain a copy of the License at
dnl
dnl     http://www.apache.org/licenses/LICENSE-2.0
dnl
dnl Unless required by applicable law or agreed to in writing, software
dnl distributed under the License is distributed on an "AS IS" BASIS,
dnl WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
dnl See the License for the specific language governing permissions and
dnl limitations under the License.

dnl
dnl find_apu.m4 : locate the APR-util (APU) include files and libraries
dnl
dnl This macro file can be used by applications to find and use the APU
dnl library. It provides a standardized mechanism for using APU. It supports
dnl embedding APU into the application source, or locating an installed
dnl copy of APU.
dnl
dnl APR_FIND_APU(srcdir, builddir, implicit-install-check, acceptable-majors,
dnl              detailed-check)
dnl
dnl   where srcdir is the location of the bundled APU source directory, or
dnl   empty if source is not bundled.
dnl
dnl   where builddir is the location where the bundled APU will be built,
dnl   or empty if the build will occur in the srcdir.
dnl
dnl   where implicit-install-check set to 1 indicates if there is no
dnl   --with-apr-util option specified, we will look for installed copies.
dnl
dnl   where acceptable-majors is a space separated list of acceptable major
dnl   version numbers. Often only a single major version will be acceptable.
dnl   If multiple versions are specified, and --with-apr-util=PREFIX or the
dnl   implicit installed search are used, then the first (leftmost) version
dnl   in the list that is found will be used.  Currently defaults to [0 1].
dnl
dnl   where detailed-check is an M4 macro which sets the apu_acceptable to
dnl   either "yes" or "no". The macro will be invoked for each installed
dnl   copy of APU found, with the apu_config variable set appropriately.
dnl   Only installed copies of APU which are considered acceptable by
dnl   this macro will be considered found. If no installed copies are
dnl   considered acceptable by this macro, apu_found will be set to either
dnl   either "no" or "reconfig".
dnl
dnl Sets the following variables on exit:
dnl
dnl   apu_found : "yes", "no", "reconfig"
dnl
dnl   apu_config : If the apu-config tool exists, this refers to it.  If
dnl                apu_found is "reconfig", then the bundled directory
dnl                should be reconfigured *before* using apu_config.
dnl
dnl Note: this macro file assumes that apr-config has been installed; it
dnl       is normally considered a required part of an APR installation.
dnl
dnl Note: At this time, we cannot find *both* a source dir and a build dir.
dnl       If both are available, the build directory should be passed to
dnl       the --with-apr-util switch.
dnl
dnl Note: the installation layout is presumed to follow the standard
dnl       PREFIX/lib and PREFIX/include pattern. If the APU config file
dnl       is available (and can be found), then non-standard layouts are
dnl       possible, since it will be described in the config file.
dnl
dnl If a bundled source directory is available and needs to be (re)configured,
dnl then apu_found is set to "reconfig". The caller should reconfigure the
dnl (passed-in) source directory, placing the result in the build directory,
dnl as appropriate.
dnl
dnl If apu_found is "yes" or "reconfig", then the caller should use the
dnl value of apu_config to fetch any necessary build/link information.
dnl

AC_DEFUN([APR_FIND_APU], [
  apu_found="no"

  if test "$target_os" = "os2-emx"; then
    # Scripts don't pass test -x on OS/2
    TEST_X="test -f"
  else
    TEST_X="test -x"
  fi

  ifelse([$4], [],
  [
    ifdef(AC_WARNING,([$0: missing argument 4 (acceptable-majors): Defaulting to APU 0.x then APU 1.x]))
    acceptable_majors="0 1"
  ], [acceptable_majors="$4"])

  apu_temp_acceptable_apu_config=""
  for apu_temp_major in $acceptable_majors
  do
    case $apu_temp_major in
      0)
      apu_temp_acceptable_apu_config="$apu_temp_acceptable_apu_config apu-config"
      ;;
      *)
      apu_temp_acceptable_apu_config="$apu_temp_acceptable_apu_config apu-$apu_temp_major-config"
      ;;
    esac
  done

  AC_MSG_CHECKING(for APR-util)
  AC_ARG_WITH(apr-util,
  [  --with-apr-util=PATH    prefix for installed APU or the full path to 
                             apu-config],
  [
    if test "$withval" = "no" || test "$withval" = "yes"; then
      AC_MSG_ERROR([--with-apr-util requires a directory or file to be provided])
    fi

    for apu_temp_apu_config_file in $apu_temp_acceptable_apu_config
    do
      for lookdir in "$withval/bin" "$withval"
      do
        if $TEST_X "$lookdir/$apu_temp_apu_config_file"; then
          apu_config="$lookdir/$apu_temp_apu_config_file"
          ifelse([$5], [], [], [
          apu_acceptable="yes"
          $5
          if test "$apu_acceptable" != "yes"; then
            AC_MSG_WARN([Found APU in $apu_config, but it is considered unacceptable])
            continue
          fi])
          apu_found="yes"
          break 2
        fi
      done
    done

    if test "$apu_found" != "yes" && $TEST_X "$withval" && $withval --help > /dev/null 2>&1 ; then
      apu_config="$withval"
      ifelse([$5], [], [apu_found="yes"], [
          apu_acceptable="yes"
          $5
          if test "$apu_acceptable" = "yes"; then
                apu_found="yes"
          fi])
    fi

    dnl if --with-apr-util is used, it is a fatal error for its argument
    dnl to be invalid
    if test "$apu_found" != "yes"; then
      AC_MSG_ERROR([the --with-apr-util parameter is incorrect. It must specify an install prefix, a build directory, or an apu-config file.])
    fi
  ],[
    if test -n "$3" && test "$3" = "1"; then
      for apu_temp_apu_config_file in $apu_temp_acceptable_apu_config
      do
        if $apu_temp_apu_config_file --help > /dev/null 2>&1 ; then
          apu_config="$apu_temp_apu_config_file" 
          ifelse([$5], [], [], [
          apu_acceptable="yes"
          $5
          if test "$apu_acceptable" != "yes"; then
            AC_MSG_WARN([skipped APR-util at $apu_config, version not acceptable])
            continue
          fi])
          apu_found="yes"
          break
        else
          dnl look in some standard places (apparently not in builtin/default)
          for lookdir in /usr /usr/local /usr/local/apr /opt/apr; do
            if $TEST_X "$lookdir/bin/$apu_temp_apu_config_file"; then
              apu_config="$lookdir/bin/$apu_temp_apu_config_file"
              ifelse([$5], [], [], [
              apu_acceptable="yes"
              $5
              if test "$apu_acceptable" != "yes"; then
                AC_MSG_WARN([skipped APR-util at $apu_config, version not acceptable])
                continue
              fi])
              apu_found="yes"
              break 2
            fi
          done
        fi
      done
    fi
    dnl if we have not found anything yet and have bundled source, use that
    if test "$apu_found" = "no" && test -d "$1"; then
      apu_temp_abs_srcdir="`cd $1 && pwd`"
      apu_found="reconfig"
      apu_bundled_major="`sed -n '/#define.*APU_MAJOR_VERSION/s/^[^0-9]*\([0-9]*\).*$/\1/p' \"$1/include/apu_version.h\"`"
      case $apu_bundled_major in
        "")
          AC_MSG_ERROR([failed to find major version of bundled APU])
        ;;
        0)
          apu_temp_apu_config_file="apu-config"
        ;;
        *)
          apu_temp_apu_config_file="apu-$apu_bundled_major-config"
        ;;
      esac
      if test -n "$2"; then
        apu_config="$2/$apu_temp_apu_config_file"
      else
        apu_config="$1/$apu_temp_apu_config_file"
      fi
    fi
  ])

  AC_MSG_RESULT($apu_found)
])

