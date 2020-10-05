#!/bin/bash
set -e

rm -f /var/run/postgresql/*.pid
/etc/init.d/postgresql start

/bin/bash
