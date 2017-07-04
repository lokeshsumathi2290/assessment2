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

/etc/sensu/config.json:
   file.managed:
     - source: salt://sensufiles/config.json
     - user: root
     - group: root
     - mode: 644
     - require:
         - pkg: sensu

/etc/sensu/conf.d/web_check.json:
   file.managed:
     - source: salt://sensufiles/web_check.json
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
           - file: /etc/sensu/conf.d/client.json

install_memory_check:
  cmd.run:
      - name: "/usr/bin/sensu-install -p memory-checks"
      - unless: test -f /opt/sensu/embedded/bin/check-memory-percent.rb
      - require:
          - file: /etc/sensu/conf.d/client.json

install_load_checks:
  cmd.run:
    - name: "/usr/bin/sensu-install -p load-checks"
    - unless: test -f /opt/sensu/embedded/bin/check-load.rb
    - require:
         - file: /etc/sensu/conf.d/client.json
'g++':
   pkg.installed


install_url_check:
   cmd.run:
     - name: "/usr/bin/sensu-install -p http"
     - unless: test -f /opt/sensu/embedded/bin/check-http.rb
     - require:
         - file: /etc/sensu/conf.d/client.json
         - pkg: 'g++'

sensu-client:
  service.running:
    - enable: True
    - require:
       - file: /etc/sensu/conf.d/client.json
       - file: /etc/sensu/config.json
       - file: /etc/sensu/conf.d/web_check.json
       - cmd: install_disk_check
       - cmd: install_memory_check
       - cmd: install_load_checks
       - cmd: install_url_check
       - pkg: 'g++'
     
