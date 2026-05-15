echo "Все данные ldap"
ldapsearch -x -H ldap://localhost -b "dc=example,dc=com" -D "cn=admin,dc=example,dc=com" -w "admin"


echo "вывод конкретного пользователя"
ldapsearch -x -H ldap://localhost -b "dc=example,dc=com" -D "cn=admin,dc=example,dc=com" -w "admin" "(uid=john.doe)"


ldapwhoami -x -H ldap://localhost -D "uid=john.doe,ou=People,dc=example,dc=com" -w "password"
