Golang webapp with database as MySQL and Monitored by SENSU


Vagrant Up order:

   1. Sensu 
   2. Database 
   3. Webapp


Output:

  Once all three stacks are brought up we should be able to do the following 

   1. View UCHIWA dashboard for sensu in your browser eg: http://yourip:3000
   2. View Blueprint webpage and also create a account and login to it in your browser  eg: http://yourip


Tools Used and the use of them

   1. Sensu - Monitoring Disk, Load, Memory, Mysql, Url
   2. Uchiwa - Dashboard for Sensu
   3. Golang - Blueprint Webapp
   4. Mysql - Database
   5. Salt - Automation(Configuration Management)
   6. Vagrant - Provisioning

