downloading_go:
  cmd.run:
    - name: /usr/bin/curl -O https://storage.googleapis.com/golang/go1.8.3.linux-amd64.tar.gz
    - cwd: /usr/local
    - unless: test -f /usr/local/go1.8.3.linux-amd64.tar.gz

extracting_go:
  cmd.wait:
    - name: /bin/tar -xzf go1.8.3.linux-amd64.tar.gz
    - cwd: /usr/local
    - watch:
       - cmd: downloading_go

/opt/gocode:
  file.directory:
    - user: root
    - group: root
    - dir_mode: 755

exporting_path:
  cmd.wait:
    - name: echo "export PATH=$PATH:/usr/local/go/bin" >> /etc/profile ; echo "export GOROOT="/usr/local/go"" >> /etc/profile ; echo "export GOPATH="/opt/gocode"" >> /etc/profile
    - watch:
       - cmd: extracting_go
    - require:
       - file: /opt/gocode

sourcing_path:
  cmd.wait:
    - name: sudo -s source /etc/profile
    - watch:
       - cmd: exporting_path


git:
  pkg.installed


installing_blueprint:
  cmd.run:
    - name: export GOPATH="/opt/gocode" ; /usr/local/go/bin/go get github.com/blue-jay/blueprint
    - unless: test -f /opt/gocode/bin/blueprint
    - require:
        - cmd: sourcing_path
        - pkg: git

installing_jay:
  cmd.run:
     - name: export GOPATH="/opt/gocode" ; /usr/local/go/bin/go get github.com/blue-jay/jay
     - unless: test -f /opt/gocode/bin/jay
     - require:
         - cmd: sourcing_path
         - pkg: git


/opt/gocode/src/github.com/blue-jay/blueprint/env.json:
  file.managed:
    - source: salt://env.json.jinja
    - template: jinja
    - user: root
    - group: root
    - mode: 644
    - require:
       - cmd: installing_blueprint 

exporting_env_path:
  cmd.wait: 
    - name: echo "export JAYCONFIG=/opt/gocode/src/github.com/blue-jay/blueprint/env.json" >> /etc/profile
    - watch:
        - cmd: installing_blueprint

sourcing_env_path:
  cmd.wait:
    - name: sudo -s source /etc/profile
    - watch:
        - cmd: exporting_env_path

creating_tables:
  cmd.wait:
    - name: export JAYCONFIG="/opt/gocode/src/github.com/blue-jay/blueprint/env.json" ; /opt/gocode/bin/jay migrate:mysql all
    - cwd: /opt/gocode/src/github.com/blue-jay/blueprint
    - require:
       - cmd: sourcing_env_path
    - watch:
       - file: /opt/gocode/src/github.com/blue-jay/blueprint/env.json

downloading_nohup:
  cmd.run:
    - name: /usr/bin/curl -O http://manpages.ubuntu.com/manpages.gz/trusty/man1/nohup.1.gz
    - cwd: /opt/gocode/src/github.com/blue-jay/blueprint
    - unless: test -f /opt/gocode/src/github.com/blue-jay/blueprint/nohup.1.gz

extracting_nohup:
  cmd.run:
    - name: /bin/gunzip nohup.1.gz ; mv nohup.1 nohup
    - cwd: /opt/gocode/src/github.com/blue-jay/blueprint
    - unless: test -f /opt/gocode/src/github.com/blue-jay/blueprint/nohup

/opt/gocode/src/github.com/blue-jay/blueprint/start.sh:
  file.managed:
    - source: salt://start.sh
    - user: root
    - group: root
    - mode: 755
    - require:
        - cmd: extracting_nohup

starting_service:
  cmd.run:
    - name: /bin/sh -x start.sh
    - cwd: /opt/gocode/src/github.com/blue-jay/blueprint
    - require:
       - file: /opt/gocode/src/github.com/blue-jay/blueprint/start.sh
