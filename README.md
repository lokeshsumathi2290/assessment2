Golang webapp with database as MySQL and Monitored by SENSU


Prerequisites:
  
   1. Vagrant 
   2. Virtual Box
   3. GIT


Vagrant Up order and its Prerequisites:

   1. Sensu VM -  Atleast 2GB of ram , default is 2GB 
   2. Database VM - Atleast 1.5 GB of ram , default is 1.5 GB
   3. Webapp VM - Atleast 600 MB of ram , default is 600 MB

How To:
 
   1. Clone the repository using this command       
          
	   git clone https://github.com/lokeshsumathi2290/assessment2.git

   2. Navigate to ##sensu## directory and exceute the below command

           vagrant up

   3. Navigate to ##database## directory and exceute the below command

           vagrant up

   4. Navigate to ##webapp## directory and exceute the below command

           vagrant up


Output:

  Once all three stacks are brought up we should be able to do the following 

   1. View UCHIWA dashboard for sensu in your browser eg: http://yourip:3000
   2. View Blueprint webpage and also create a account and login to it from your browser  eg: http://yourip

       Note: yourip is the local ip of the machine in which vagrant is installed

Tools Used and the use of them

   1. Sensu - Monitoring Disk, Load, Memory, Mysql, Url
   2. Uchiwa - Dashboard for Sensu
   3. Golang - Blueprint Webapp
   4. Mysql - Database
   5. Salt - Automation(Configuration Management)
   6. Vagrant - Provisioning

