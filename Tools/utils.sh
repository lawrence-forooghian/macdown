# First, check for git in $PATH
hash git 2>/dev/null || { echo >&2 "Git required, not installed.  Aborting build number update script."; exit 0; }

# Build version (closest-tag-or-branch "-" commits-since-tag "-" short-hash dirty-flag)
function get_build_version() {
    echo $(git describe --tags --always --dirty=+)
}

# Use the latest tag for short version (expected tag format "vn[.n[.n]]")
# or if there are no tags, we make up version 0.0.<commit count>
function get_short_version() {
    LATEST_TAG=$(git describe --tags --match 'v*' --abbrev=0 2>/dev/null) || LATEST_TAG="HEAD"
    if [ $LATEST_TAG = "HEAD" ]; then
        COMMIT_COUNT=$(git rev-list --count HEAD)
        LATEST_TAG="0.0.$COMMIT_COUNT"
        COMMIT_COUNT_SINCE_TAG=0
    else
        COMMIT_COUNT_SINCE_TAG=$(git rev-list --count ${LATEST_TAG}..)
        LATEST_TAG=${LATEST_TAG##v} # Remove the "v" from the front of the tag
    fi

    if [ $COMMIT_COUNT_SINCE_TAG = 0 ]; then
        SHORT_VERSION="$LATEST_TAG"
    else
        local tools_dir=$(dirname "${BASH_SOURCE[0]:-${(%):-%x}}")
        local next_version=$(cat "$tools_dir/version.txt")
        SHORT_VERSION="${next_version}d${COMMIT_COUNT_SINCE_TAG}"
    fi
    echo $SHORT_VERSION
}

# Bundle version (commits-on-master[-until-branch "." commits-on-branch])
# Assumes that two release branches will not diverge from the same commit on master.
function get_bundle_version() {
    if [ $(git rev-parse --abbrev-ref HEAD) = "master" ]; then
        MASTER_COMMIT_COUNT=$(git rev-list --count HEAD)
        BRANCH_COMMIT_COUNT=0
        BUNDLE_VERSION="$MASTER_COMMIT_COUNT"
    else
        if [ $(git rev-list --count master..) = 0 ]; then   # The branch is attached to master. Just count master.
            MASTER_COMMIT_COUNT=$(git rev-list --count HEAD)
        else
            MASTER_COMMIT_COUNT=$(git rev-list --count $(git rev-list master.. | tail -n 1)^)
        fi
        BRANCH_COMMIT_COUNT=$(git rev-list --count master..)
        if [ $BRANCH_COMMIT_COUNT = 0 ]; then
            BUNDLE_VERSION="$MASTER_COMMIT_COUNT"
        else
            BUNDLE_VERSION="${MASTER_COMMIT_COUNT}.${BRANCH_COMMIT_COUNT}"
        fi
    fi
    echo $BUNDLE_VERSION
}
