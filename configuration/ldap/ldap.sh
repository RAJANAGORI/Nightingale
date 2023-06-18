LDAP_URI=ldap://openldap:389
LDAP_BASE_DN=dc=local,dc=com
LDAP_BIND_DN=cn=admin,dc=local,dc=com
LDAP_BIND_PASSWORD=admin_pass

# Update nsswitch.conf to use LDAP for passwd, group, shadow, hosts, and netgroup
sed -i 's/^passwd:\s*files$/passwd:         files ldap compat/' /etc/nsswitch.conf
sed -i 's/^group:\s*files$/group:         files ldap compat/' /etc/nsswitch.conf
sed -i 's/^shadow:\s*files$/shadow:         files ldap compat/' /etc/nsswitch.conf
sed -i 's/^netgroup:\s*nis$/netgroup:       nis/' /etc/nsswitch.conf

# Update libnss-ldap.conf to use the correct LDAP server and base DN, and bind with admin credentials
sed -i "s/base dc=example,dc=net/base ${LDAP_BASE_DN}/" /etc/libnss-ldap.conf
sed -i "s#uri ldapi:///#uri ${LDAP_URI}#" /etc/libnss-ldap.conf
sed -i "s/\#binddn cn=proxyuser,dc=padl,dc=com/binddn ${LDAP_BIND_DN}/" /etc/libnss-ldap.conf
sed -i "s/\#bindpw secret/bindpw ${LDAP_BIND_PASSWORD}/" /etc/libnss-ldap.conf
sed -i "s/\#base dc=example,dc=net/base ${LDAP_BASE_DN}/" /etc/libnss-ldap.conf

# Update common-auth to use nullok_secure for pam_unix.so
sed -i 's/^\(auth\s*required\s*pam_unix.so\)/#\1/' /etc/pam.d/common-auth
sed -i 's/pam_unix\.so nullok$/pam_unix.so nullok_secure try_first_pass/' /etc/pam.d/common-auth
sed -i '$a auth sufficient pam_ldap.so' /etc/pam.d/common-auth

#The common-account file specifically is used to manage the user account information, such as password aging and lockout policies, and to configure the use of external authentication sources like OpenLDAP.
sed -i '$a account sufficient pam_ldap.so' /etc/pam.d/common-account
# Update common-password to use sha512 instead of yescrypt for password hashing
sed -i 's/^\(password\s*requisite\s*pam_cracklib.so\)/#\1/' /etc/pam.d/common-password
sed -i 's/^\(password\s*\[success=1\s*default=ignore\]\s*pam_unix.so\)/#\1/' /etc/pam.d/common-password
sed -i '$ a\password sufficient pam_ldap.so' /etc/pam.d/common-password

# Add pam_mkhomedir.so to common-session to automatically create home directories on login
sed -i '$ a\session  required  pam_mkhomedir.so umask=0022 skel=/etc/skel' /etc/pam.d/common-session