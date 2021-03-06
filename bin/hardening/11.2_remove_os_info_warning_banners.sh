#!/bin/bash

#
# harbian audit 7/8/9  Hardening
#

#
# 11.2 Remove OS Information from Login Warning Banners (Scored)
#

set -e # One error, it's over
set -u # One variable unset, it's over

HARDENING_LEVEL=3

FILES='/etc/motd /etc/issue /etc/issue.net'
PATTERN='(\\v|\\r|\\m|\\s|Debian)'

# This function will be called if the script status is on enabled / audit mode
audit () {
    for FILE in $FILES; do
        does_pattern_exist_in_file $FILE "$PATTERN"
        if [ $FNRET = 0 ]; then
            crit "$PATTERN is present in $FILE"
        else
            ok "$PATTERN is not present in $FILE"
        fi
    done
}

# This function will be called if the script status is on enabled mode
apply () {
    for FILE in $FILES; do
        does_pattern_exist_in_file $FILE "$PATTERN"
        if [ $FNRET = 0 ]; then
            warn "$PATTERN is present in $FILE"
            echo "Authorized uses only. All activity may be monitored and reported." > $FILE 
        else
            ok "$PATTERN is not present in $FILE"
        fi
    done
}

# This function will check config parameters required
check_config() {
    :
}

# Source Root Dir Parameter
if [ -r /etc/default/cis-hardening ]; then
    . /etc/default/cis-hardening
fi
if [ -z "$CIS_ROOT_DIR" ]; then
     echo "There is no /etc/default/cis-hardening file nor cis-hardening directory in current environment."
     echo "Cannot source CIS_ROOT_DIR variable, aborting."
    exit 128
fi

# Main function, will call the proper functions given the configuration (audit, enabled, disabled)
if [ -r $CIS_ROOT_DIR/lib/main.sh ]; then
    . $CIS_ROOT_DIR/lib/main.sh
else
    echo "Cannot find main.sh, have you correctly defined your root directory? Current value is $CIS_ROOT_DIR in /etc/default/cis-hardening"
    exit 128
fi
