#! /usr/bin/bash

# !!! FILE NEEDED FOR GITHUB VERSIONING !!!

VERSION_ONLY=false
USE_LATEST_TAG=true
HOTFIX=false
VERSION=""

while [[ $# -gt 0 ]]; do
  case $1 in
  "-v" | "--version")
    shift
    OLD_VERSION="$1"
    USE_LATEST_TAG=false
    ;;
  "-q")
    VERSION_ONLY=true
    ;;
  "-h")
    HOTFIX=true
    ;;
  esac
  shift
done

COMMIT=$(git show -s --format=%B)
COMMIT=$(echo "$COMMIT" | tr '[:upper:]' '[:lower:]')

MAJOR_MATCH="(major|breaking)[:|\/|\(]"
MINOR_MATCH="feat[:|\/|\(]"
PATCH_MATCH="fix[:|\/|\(]"

[[ $USE_LATEST_TAG == "true" ]] && OLD_VERSION=$(git tag -l 'v*.*.*'| sort -V | tail -n 1)
[[ $USE_LATEST_TAG == "false" ]] && OLD_VERSION=$(git tag -l 'v*.*.*'| sort -V | grep $OLD_VERSION | tail -n 1)

OLD_VERSION=$(sed 's:^v::' <<<"$OLD_VERSION")
if [[ $HOTFIX == "true" ]]; then
  BASE=$(sed 's:-.*::g' <<<"$OLD_VERSION")
  [[ $OLD_VERSION =~ "-" ]] &&
    HOTFIX=$(sed 's:^.*-::g' <<<"$OLD_VERSION") ||
    HOTFIX=0

  HOTFIX=$((HOTFIX + 1))
  VERSION="v$BASE-$HOTFIX"

else
  MAJOR=$(sed 's:\..*$::' <<<"$OLD_VERSION")
  MINOR=$(sed 's:^[0-9]*\.\([0-9]*\)\..*$:\1:' <<<"$OLD_VERSION")
  PATCH=$(sed 's:^[0-9]*\.[0-9]*\.\([0-9]*\).*$:\1:' <<<"$OLD_VERSION")

  if [[ $COMMIT =~ $MAJOR_MATCH ]]; then
    MAJOR=$((MAJOR + 1))
    MINOR="0"
    PATCH="0"

  elif [[ $COMMIT =~ $MINOR_MATCH ]]; then
    MINOR=$((MINOR + 1))
    PATCH="0"

  elif [[ $COMMIT =~ $PATCH_MATCH ]]; then
    PATCH=$((PATCH + 1))

  else
    PATCH=$((PATCH + 1))
  fi

  VERSION="v$MAJOR.$MINOR.$PATCH"
fi

[[ $VERSION_ONLY == "true" ]] && echo "$VERSION"

[[ ! $VERSION_ONLY == "true" ]] && echo "Old version: v$OLD_VERSION"
[[ ! $VERSION_ONLY == "true" ]] && echo "New version: $VERSION"
exit 0

