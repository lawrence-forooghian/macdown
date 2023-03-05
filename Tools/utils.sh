# TODO I think that for released versions, we will stick to the rules. For unreleased versions, we’ll do our own semantic version thing
function get_short_version() {
    # CFBundleShortVersionString:
    #
    # From https://developer.apple.com/documentation/bundleresources/information_property_list/cfbundleshortversionstring:
    #
    # > This key is a user-visible string for the version of the bundle. The required format is three period-separated integers, such as 10.14.1. The string can only contain numeric characters (0-9) and periods.
    # >
    # > Each integer provides information about the release in the format [Major].[Minor].[Patch]:
    # >
    # > Major: A major revision number.
    # > Minor: A minor revision number.
    # > Patch: A maintenance release number.
    # >
    # > This key is used throughout the system to identify the version of the bundle.
    #
    # From https://developer.apple.com/library/archive/documentation/General/Reference/InfoPlistKeyReference/Articles/CoreFoundationKeys.html#//apple_ref/doc/uid/TP40009249-111349-TPXREF113:
    #
    # > CFBundleShortVersionString (String - iOS, macOS) specifies the release version number of the bundle, which identifies a released iteration of the app.
    # >
    # > The release version number is a string composed of three period-separated integers. The first integer represents major revision to the app, such as a revision that implements new features or major changes. The second integer denotes a revision that implements less prominent features. The third integer represents a maintenance release revision.
    # >
    # > The value for this key differs from the value for CFBundleVersion, which identifies an iteration (released or unreleased) of the app.
    # >
    # > This key can be localized by including it in your InfoPlist.strings files.

    local tools_dir=$(dirname "${BASH_SOURCE[0]:-${(%):-%x}}")
    local next_version=$(cat "$tools_dir/version.txt")

    if [ "$CI" == "true" ]; then
        # TODO check semantic versioning rules
        SHORT_VERSION="${next_version}-preview"
    else
        SHORT_VERSION="${next_version}-dev"
    fi

    echo $SHORT_VERSION
}

function get_bundle_version() {
    if [ "$CI" == "true" ]; then
        # TODO note about how this breaks the 255-max rule but so did the previous code
        # GITHUB_RUN_NUMBER: A unique number for each run of a particular workflow in a repository. This number begins at 1 for the workflow's first run, and increments with each new run. This number does not change if you re-run the workflow run. For example, 3.
        #
        # GITHUB_RUN_ATTEMPT: A unique number for each attempt of a particular workflow run in a repository. This number begins at 1 for the workflow run's first attempt, and increments with each re-run. For example, 3.
        BUNDLE_VERSION="${GITHUB_RUN_NUMBER}.${GITHUB_RUN_ATTEMPT}"
    else
        BUNDLE_VERSION=$(date +%s)
    fi
    echo $BUNDLE_VERSION
}
