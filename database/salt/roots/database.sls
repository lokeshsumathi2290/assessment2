debconf-utils:
  pkg.installed

python-mysqldb:
  pkg.installed


mysql_setup:
  debconf.set:
    - name: mysql-server
    - data:
        'mysql-server/root_password': {'type': 'password', 'value': 'mysqlPassword' }
        'mysql-server/root_password_again': {'type': 'password', 'value': 'mysqlPassword' }
    - require:
      - pkg: debconf-utils

mysql-server-5.6:
  pkg.installed:
    - require:
      - debconf: mysql-server
      - pkg: python-mysqldb

mysql:
  service.running:
    - watch:
      - pkg: mysql-server-5.6
      - file: /etc/mysql/my.cnf
    - require:
      - cmd: commands

/etc/mysql/my.cnf:
  file.managed:
    - source: salt://my.cnf.jinja
    - template: jinja
    - user: root
    - group: root
    - mode: 640
    - require:
      - pkg: mysql-server-5.6

commands:
  cmd.wait:
    - name: /bin/sed -i "s/\['//g" /etc/mysql/my.cnf ; /bin/sed -i "s/']//g" /etc/mysql/my.cnf
    - watch:
        - file: /etc/mysql/my.cnf
    
webapp:
  mysql_user.present:
    - host: '%'
    - password: mysqlWebapp
    - connection_host: localhost
    - connection_user: root
    - connection_pass: mysqlPassword
    - connection_charset: utf8
    - require:
       - service: mysql

grant_permission:
   mysql_grants.present:
       - grant: all privileges
       - database: '*.*'
       - user: webapp
       - host: '%'
       - connection_host: localhost
       - connection_user: root
       - connection_pass: mysqlPassword
       - connection_charset: utf8
       - require:
          - mysql_user: webapp
