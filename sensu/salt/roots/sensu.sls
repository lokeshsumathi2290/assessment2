sensu_key:
  cmd.run:
    - name: "wget -q https://sensu.global.ssl.fastly.net/apt/pubkey.gpg -O- | sudo apt-key add -"

/etc/apt/sources.list.d/sensu.list:
   file.managed:
     - source: salt://sensufiles/sensu.list
     - user: root
     - group: root
     - mode: 644
     - require:
        - cmd: sensu_key

update_repo:
  cmd.wait:
    - name: "apt-get update -y"
    - watch:
        - file: /etc/apt/sources.list.d/sensu.list

sensu:
  pkg.installed:
    - require:
        - cmd: update_repo

/etc/sensu/conf.d/client.json:
   file.managed:
     - source: salt://sensufiles/client.json
     - user: root
     - group: root
     - mode: 644
     - require:
        - pkg: sensu

/etc/sensu/conf.d/transport.json:
   file.managed:
     - source: salt://sensufiles/transport.json
     - user: root
     - group: root
     - mode: 644
     - require:
        - pkg: sensu

/etc/sensu/conf.d/api.json:
   file.managed:
     - source: salt://sensufiles/api.json
     - user: root
     - group: root
     - mode: 644
     - require:
        - pkg: sensu

/etc/sensu/conf.d/check_disk_usage.json:
   file.managed:
     - source: salt://sensufiles/check_disk_usage.json
     - user: root
     - group: root
     - mode: 644
     - require:
        - pkg: sensu

/etc/sensu/conf.d/memory_checks.json:
   file.managed:
     - source: salt://sensufiles/memory_checks.json
     - user: root
     - group: root
     - mode: 644
     - require:
        - pkg: sensu

/etc/sensu/conf.d/load_check.json:
   file.managed:
     - source: salt://sensufiles/load_check.json
     - user: root
     - group: root
     - mode: 644
     - require:
        - pkg: sensu

install_disk_check:
   cmd.run:
       - name: "/usr/bin/sensu-install -p disk-checks"
       - unless: test -f /opt/sensu/embedded/bin/check-disk-usage.rb
       - require:
           - file: /etc/sensu/conf.d/check_disk_usage.json

install_memeory_check:
  cmd.run:
      - name: "/usr/bin/sensu-install -p memory-checks"
      - unless: test -f /opt/sensu/embedded/bin/check-memory-percent.rb
      - require:
          - file: /etc/sensu/conf.d/memory_checks.json

install_load_checks:
  cmd.run:
      - name: "/usr/bin/sensu-install -p load-checks"
      - unless: test -f /opt/sensu/embedded/bin/check-load.rb
      - require:
          - file: /etc/sensu/conf.d/load_check.json

sensu-server:
  service.running:
    - enable: True
    - require: 
       - file: /etc/sensu/conf.d/memory_checks.json
       - file: /etc/sensu/conf.d/check_disk_usage.json
       - file: /etc/sensu/conf.d/load_check.json
       - file: /etc/sensu/conf.d/transport.json

sensu-client:
  service.running:
    - enable: True
    - require:
       - file: /etc/sensu/conf.d/client.json

sensu-api:
  service.running:
    - enable: True
    - require:
       - file: /etc/sensu/conf.d/api.json



