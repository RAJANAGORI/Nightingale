#!/usr/bin/env python3

import ldap

def authenticate(username, password):
    ldap_server = "ldap://ldap.example.com"
    ldap_port = 389
    ldap_base_dn = "dc=example,dc=com"

    try:
        conn = ldap.initialize(ldap_server)
        conn.set_option(ldap.OPT_REFERRALS, 0)
        conn.simple_bind_s("cn={},{}".format(username, ldap_base_dn), password)
        conn.unbind_s()
        return True
    except ldap.INVALID_CREDENTIALS:
        return False
    except ldap.LDAPError as e:
        print(e)
        return False

if __name__ == "__main__":
    import sys
    if len(sys.argv) == 3:
        username = sys.argv[1]
        password = sys.argv[2]
        if authenticate(username, password):
            sys.exit(0)
    sys.exit(1)