#!/bin/bash

# Author: Matthew Fritz <matthew.fritz@csun.edu>

# This tool performs a double-bind using ldapsearch. The idea is that the initial bind will
# be done with a DN/password combination, perform a lookup on the search UID, and then
# do another bind using the found DN and the supplied password.

# Error codes
E_MISSING_CONF=80 # Configuration file is missing
E_INITIAL_BIND=81 # First bind (bind DN/PW) failed
E_SEARCH_UID=82 # UID does not exist within the base DN subtree
E_SECOND_BIND=83 # Second bind (search DN/PW) failed

# The conf file expects the following values as Bash constants:
# LDAP_VERSION (-P attribute)
# LDAP_HOST (-H attribute)
# LDAP_BASE_DN (-b attribute)
# LDAP_BIND_DN (-D attribute)
# LDAP_BIND_PW (-w attribute)
# LDAP_SEARCH_UID (uid filter attribute)
# LDAP_SEARCH_PW (password matching the search UID)
CONF_PATH="$HOME/doublebind.conf"

# Check for the existence of the configuration file
if [ ! -f "$CONF_PATH" ]; then
   echo "Please create a $CONF_PATH file before continuing"
   exit $E_MISSING_CONF
fi

# Bring in the values
source $CONF_PATH

# Perform the intitial bind and search; dn is used as the retrieval attribute
# since it will blank out the attribute list and we will only get back the
# DN by default (as the dn itself isn't an attribute)
LDAP_INITIAL=`ldapsearch -LLL -P $LDAP_VERSION -H $LDAP_HOST -b $LDAP_BASE_DN -D $LDAP_BIND_DN -w $LDAP_BIND_PW -x uid=$LDAP_SEARCH_UID dn`

# Check response code
if [ ! "$?" -eq "0" ]; then
   echo "Could not perform the initial bind using $LDAP_BIND_DN"
   exit $E_INITIAL_BIND
fi

# Check search response
if [ -z "$LDAP_INITIAL" ]; then
   echo "The record with the search UID ($LDAP_SEARCH_UID) could not be resolved"
   exit $E_SEARCH_UID
fi

# Generate the DN to use when binding for the searched UID; this will strip off
# the leading "dn: " substring from the returned DN
LDAP_SEARCH_DN=${LDAP_INITIAL#dn: }

# Now perform the second bind with the generated DN from the search UID; it will
# just perform a self-search for simplicity
LDAP_SECOND=`ldapsearch -LLL -P $LDAP_VERSION -H $LDAP_HOST -b $LDAP_BASE_DN -D $LDAP_SEARCH_DN -w $LDAP_SEARCH_PW -x uid=$LDAP_SEARCH_UID dn`

# Check response code
if [ ! "$?" -eq "0" ]; then
   echo "Could perform the second bind using $LDAP_SEARCH_DN"
   exit $E_SECOND_BIND
fi

echo "The double bind was successful"
exit 0
