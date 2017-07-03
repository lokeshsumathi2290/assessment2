downloading_erlang_repo:
  cmd.run:
    - name: "wget http://packages.erlang-solutions.com/erlang-solutions_1.0_all.deb" 
    - cwd: /opt
    - unless: test -f /opt/erlang-solutions_1.0_all.deb

installing_erlang_repo:
  cmd.wait:
    - name: "dpkg -i erlang-solutions_1.0_all.deb"
    - cwd: /opt
    - watch:
        - cmd: downloading_erlang_repo

/etc/apt/sources.list.d/rabbitmq.list:
  file.managed:
    - source: salt://rabbitmq.list
    - user: root
    - group: root
    - mode: 644
    - require:
        - cmd: installing_erlang_repo

rabbitmq_key:
  cmd.wait:
    - name: "wget -O- https://www.rabbitmq.com/rabbitmq-release-signing-key.asc | apt-key add -"
    - watch:
        - file: /etc/apt/sources.list.d/rabbitmq.list

updating_repo:
  cmd.wait:
    - name: apt-get update -y
    - watch: 
        - cmd: installing_erlang_repo
    - require:
        - cmd: rabbitmq_key
socat:
  pkg.installed:
    - require: 
       - cmd: updating_repo

erlang-nox: 
  pkg.installed:
    - require:
       - cmd: updating_repo

rabbitmq-server:
  pkg.installed:
    - require: 
       - cmd: updating_repo

adding_vhost:
  cmd.wait:
    - name: "rabbitmqctl add_vhost /sensu"
    - require:
        - pkg: rabbitmq-server
    - watch: 
        - pkg: rabbitmq-server

rabbitmq_user:
  cmd.wait:
    - name: "rabbitmqctl add_user sensu secret"
    - require:
        - cmd: adding_vhost
    - watch:
        - pkg: rabbitmq-server

rabbitmq_permission:
  cmd.wait:
    - name: 'rabbitmqctl set_permissions -p /sensu sensu ".*" ".*" ".*"'
    - require:
        - cmd: rabbitmq_user
    - watch:
        - pkg: rabbitmq-server

rabbitmq_ulimit:
  cmd.wait:
    - name: "/bin/sed -i 's/#ulimit -n 1024/ulimit -n 65536/g' /etc/default/rabbitmq-server"
    - watch:
       - pkg: rabbitmq-server


/etc/sensu/conf.d/rabbitmq.json:
  file.managed:
    - source: salt://rabbitmq.json
    - user: root
    - group: root
    - mode: 644
    - require:
       - cmd: rabbitmq_ulimit  
