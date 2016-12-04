#!/bin/bash

#
# Load configuration
#
CONF=${CONF:-/etc/sboui/sboui.conf}
#CONF=${CONF:-/data/dprosser/software/sboui_files/sboui/sboui.conf}
. $CONF

################################################################################
# Removes quotes around string
function remove_quotes ()
{
  local STRING=$1
  STRING=${STRING#\"}
  STRING=${STRING%\"}
  echo $STRING
}

################################################################################
# Gets SlackBuild name from installed package name in /var/log/packages
function get_pkg_name ()
{
  local PKG=$1

  # Get rid of trailing stuff
  local BUILD=${PKG%*_$TAG}
  BUILD=${BUILD%*-*}  # Architecture-number
  BUILD=${BUILD%*-*}  # Architecture
  BUILD=${BUILD%*-*}  # Version
  echo $BUILD
}

################################################################################
# Gets SlackBuild version from installed package name in /var/log/packages
function get_pkg_version ()
{
  local PKG=$1

  # Get rid of trailing stuff
  local VERSION=${PKG%*_$TAG}
  VERSION=${VERSION%*-*}  # Architecture-number
  VERSION=${VERSION%*-*}  # Architecture

  # Get rid of leading package name
  local TEMP=${VERSION%*-*}
  VERSION=${VERSION#$TEMP-*}
  echo $VERSION
}

################################################################################
# Checks if a SlackBuild is actually installed. Returns installed version if so;
# returns "not_installed" otherwise.
function check_installed ()
{
  local BUILD=$1
  local PKGLIST=$(find /var/log/packages -maxdepth 1 -name "$BUILD*_$TAG")
  #local PKGLIST=$(find /data/dprosser/software/sboui_files/packages -maxdepth 1 -name "$BUILD*_$TAG")
  local INSTALLED="not_installed"
  local PKG BUILDNAME

  # There can be multiple packages fitting the pattern, so loop through them
  # and check against requested
  if [ -n "$PKGLIST" ]; then
    for PKG in $PKGLIST
    do
      PKG=$(basename "$PKG")
      BUILDNAME=$(get_pkg_name "$PKG")
      if [ "$BUILDNAME" == "$BUILD" ]; then
        INSTALLED=$(get_pkg_version "$PKG")
        break
      fi
    done
  fi

  echo $INSTALLED
}

################################################################################
# Gets SlackBuild version from string in .info file
function get_available_version ()
{
  local BUILD=$1
  local CATEGORY=$2

  # Get path of SlackBuild.info
  local INFILE=$REPO_DIR/$CATEGORY/$BUILD/$BUILD.info

  # Get version number
  local VERSION=$(grep VERSION "$INFILE" | sed 's/VERSION=//')
  VERSION=$(remove_quotes "$VERSION")

  echo $VERSION
}

################################################################################
# Lists installed SlackBuilds
function list_installed ()
{
  local PKGLIST=$(find /var/log/packages -maxdepth 1 -name "$BUILD*_$TAG")
  #local PKGLIST=$(find /data/dprosser/software/sboui_files/packages -maxdepth 1 -name "$BUILD*_$TAG")
  local PKG

  for PKG in $PKGLIST
  do
    PKG=$(basename "$PKG")
    echo $(get_pkg_name "$PKG")
  done
}

################################################################################
# Checks whether SlackBuild 1 is required by SlackBuild 2
function is_dep()
{
  local BUILD1=$1
  local BUILD2=$2
  local CATEGORY2=$3

  local REQ ISREQ

  # Read requirements from .info file
  . "$REPO_DIR/$CATEGORY2/$BUILD2/$BUILD2.info"

  # Loop through and see if specified SlackBuild is mentioned
  ISREQ=0
  if [ -n "$REQUIRES" ]; then
    for REQ in $REQUIRES
    do
      if [ "$REQ" == "$BUILD1" ]; then
        ISREQ=1
        break
      fi
    done
  fi

  echo $ISREQ
}

case $1 in
    "check_installed")
        check_installed $2
        ;;
    "get_available_version")
        get_available_version $2 $3
        ;;
    "list_installed")
        list_installed
        ;;
    "is_dep")
        is_dep $2 $3 $4
        ;;
    *)
        ;;
esac
