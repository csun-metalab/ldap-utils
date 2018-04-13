# LDAP Utilities

This repository contains various tools for testing or performing LDAP operations.

## Tools

### Test Double-Bind for Authentication

This tool mimics the process of a double-bind for PAM-based LDAP authentication on *nix-based systems. This can be used to ensure your LDAP authentication settings are correct for something like SSH.

The tool and its configuration file are located in `tools/doublebind/`.
