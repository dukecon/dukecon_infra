#!/bin/sh

set -e

: ${NEXUS_BASE_URL:="http://localhost:8081"}

: ${NEXUS_ADMIN_DEFAULT_PW:="admin123"}
: ${NEXUS_ADMIN_NEW_PW:="test1234"}

: ${NEXUS_ADMIN_PW:="${NEXUS_ADMIN_DEFAULT_PW}"}

update_user () {
	user=$1
	oldpass=$2
	newpass=$3
	
	curl -v -u "admin:${NEXUS_ADMIN_PW}" -H "Content-Type: application/xml" -d @- "${NEXUS_BASE_URL}/service/local/users_changepw" <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<user-changepw>
  <data>
    <oldPassword>${oldpass}</oldPassword>
    <userId>${user}</userId>
    <newPassword>${newpass}</newPassword>
  </data>
</user-changepw>
EOF

}

update_user admin "${NEXUS_ADMIN_PW}" "${NEXUS_ADMIN_NEW_PW}"
NEXUS_ADMIN_PW="${NEXUS_ADMIN_NEW_PW}"
update_user deployment "deployment123" "x9y8z7a6"