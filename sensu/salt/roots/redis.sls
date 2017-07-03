redis-server:
  pkg.installed 

ulimt:
  cmd.wait:
    - name: "/bin/sed -i 's/# ULIMIT=65536/ULIMIT=65536/g' /etc/default/redis-server" 
    - watch:
       - pkg: redis-server

/etc/sensu:
  file.directory:
    - user: root
    - group: root
    - dir_mode: 755

/etc/sensu/conf.d:
  file.directory:
    - user: root
    - group: root
    - dir_mode: 755
    - require:
       - file: /etc/sensu
 
/etc/sensu/conf.d/redis.json:
   file.managed:
    - source: salt://redis.json 
    - user: root
    - group: root
    - mode: 644
    - require:
        - file: /etc/sensu/conf.d
