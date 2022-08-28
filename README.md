# SmartInventory
SmartInventory predicts sales and supplier response times, responses to customer demands and uses a recommender system for senior management decision making, using artificial intelligence


# SmartInventory environment
SmartInventory environment required to run Laravel (based on official php and mysql docker hub repositories).

[Source code]([https://github.com/devopstoolsiasoft/smartinv])
[Imagen Docker]([https://hub.docker.com/repository/docker/smartinventoryproductions1/smartinventory])

## Requirements
* Docker version Version: 20.10.17 or later
* Docker compose version  2.10.2 or later
* An editor or IDE

Note: OS recommendation - Linux Ubuntu based vesion 22.04.

## Components:
1. Apache 7.2.24
2. PHP 7.2.24 (cli) (Apache handler)
3. MySQL 5.7.29
4. Laravel Framework 5.8.33

## Setting up DEV environment
1.Clone this repository from GitHub.
```bash
git clone https://github.com/devopstoolsiasoft/smartinv.git
Cloning into 'smartinv'...
Username for 'https://github.com': devopstoolsiasoft
Password for 'https://devopstoolsiasoft@github.com': 
```
- Accessing the repository and unzipping the persistent folder of the database used in the docker-compose file
```bash
cd smartinv/
sudo tar -zxvf storage.tar.gz
```
2. Download image docker Docker Hub 
- have previously installed docker and docker-compose and login in docker hub
 ```bash
 cd smartinv/
 docker login
 docker pull devopstoolsiasoft/smartinv:latest
 ```
- List the docker images
 ```bash 
 docker@docker:~/smartinv$ docker images
 REPOSITORY                   TAG                 IMAGE ID            CREATED             SIZE
 devopstoolsiasoft/smartinv   latest              c220712e7e8d        35 minutes ago      1.36GB
 composer                     latest              e3c905742d7c        3 weeks ago         179MB
 phpmyadmin/phpmyadmin        latest              366fde4f732e        3 weeks ago         468MB
 mysql                        5.7.29              84164b03fa2e        6 weeks ago         456MB
 php                          7.2.24-apache       071b437a2194        5 months ago        410MB
 ```
3. Create docker services with docker-compose file
 ```bash
 docker@docker:~/smartinv$ docker-compose up -d
 Creating network "smartinv_default" with the default driver
 Creating mysql ... done
 Creating supervisord           ... done
 Creating smartinv              ... done
 Creating smartinv_phpmyadmin_1 ... done
 ```
- Check containers, services and ports that are running
 ```bash
 docker@docker:~/smartinv$ docker-compose ps -a
        Name                       Command               State                     Ports                   
 -----------------------------------------------------------------------------------------------------------
 mysql                   docker-entrypoint.sh --def ...   Up      0.0.0.0:33061->3306/tcp, 33060/tcp        
 smartinv                docker-php-entrypoint apac ...   Up      0.0.0.0:443->443/tcp, 0.0.0.0:8080->80/tcp
 smartinv_phpmyadmin_1   /docker-entrypoint.sh apac ...   Up      0.0.0.0:8081->80/tcp                      
 supervisord             docker-php-entrypoint /usr ...   Up      80/tcp                                    
 ```
 ```bash
 docker30@docker30:~/development_docker_test/test-clone-git-docker/smartinv$ docker ps -a
 CONTAINER ID        IMAGE                               COMMAND                  CREATED             STATUS              PORTS                                        NAMES
 58095463ddd0        phpmyadmin/phpmyadmin               "/docker-entrypoint.…"   51 seconds ago      Up 48 seconds       0.0.0.0:8081->80/tcp                         smartinv_phpmyadmin_1
 a6a13527fb1a        devopstoolsiasoft/smartinv:latest   "docker-php-entrypoi…"   51 seconds ago      Up 49 seconds       0.0.0.0:443->443/tcp, 0.0.0.0:8080->80/tcp   smartinv
 c8ed27eb0c50        devopstoolsiasoft/smartinv:latest   "docker-php-entrypoi…"   51 seconds ago      Up 48 seconds       80/tcp                                       supervisord
 2d2d6713ed74        mysql:5.7.29                        "docker-entrypoint.s…"   52 seconds ago      Up 51 seconds       33060/tcp, 0.0.0.0:33061->3306/tcp           mysql
  ```
4. Verify web applications
- verify web applications on port 8080 smartinv in http://IP_HOST:8080/
- verify web applications phpmyadmin on port 8081 in http://IP_HOST:8081/

5. Build and start the image from your terminal
 ```bash
 make start
 make stop
 ```

6.Set key for application:
 ```bash
 make ssh
 make ssh-mysql
 ```
7.Stop and clean the container
 ```bash
 make stop
 docker-compose down -v
 make clean
 ```
