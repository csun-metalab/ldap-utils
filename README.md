# LDAP Utilities

This repository contains various tools for testing or performing LDAP operations.

## Tools

### Test Double-Bind for Authentication

This tool mimics the process of a double-bind for PAM-based LDAP authentication on *nix-based systems. This can be used to ensure your LDAP authentication settings are correct for something like SSH.

A double-bind is defined as the following:

1. Bind using a DN/password combination that can perform `ldapsearch` operations to find other users
2. Perform a lookup on a user by his `uid` attribute
3. Use the DN from the retrieved record and a provided password to perform a second bind as that user for the purposes of validating credentials

The tool and its configuration file are located in the `tools/doublebind` directory.
