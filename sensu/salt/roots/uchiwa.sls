uchiwa:
  pkg:
    - installed
  service:
    - running
    - enable: True
    - require:
       - pkg: uchiwa
        

/etc/sensu/uchiwa.json:
   file.managed:
     - source: salt://uchiwa.json
     - user: root
     - group: root
     - mode: 644 
     - require:
         - pkg: uchiwa

service_reload:
   cmd.wait:
     - name: "service uchiwa restart"
     - watch:
         - file: /etc/sensu/uchiwa.json
