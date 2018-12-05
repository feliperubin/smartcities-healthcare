





## Installing Thingsboard



Access: [thingsboard.io](https://thingsboard.io)

### Docker

Install Docker

```bash
docker login
# Enter the docker hub credentials
docker run -it -p 9090:9090 -p 1883:1883 -p 5683:5683/udp -v ~/.mytb-data:/data --name mytb --restart always thingsboard/tb-cassandra

```
Access: localhost:9090
Username: tenant@thingsboard.org
Password: tenant

### VM:

Dependencies

```bash
sudo apt-get install -y software-properties-common
sudo apt-add-repository ppa:webupd8team/java
sudo apt-get update
sudo apt-get install -y oracle-java8-installer
sudo apt install postgresql postgresql-contrib
sudo -u postgres createdb thingsboard
sudo -u postgres createuser thingsboard
sudo -u postgres psql thingsboard
\q
```

Download the 2.1 release 2.2 is NOT working

```bash
wget https://github.com/thingsboard/thingsboard/releases/download/v2.1/thingsboard-2.1.deb
sudo dpkg -i thingsboard-2.1.deb
```


Edit the configuration

```bash
sudo nano /usr/share/thingsboard/conf/thingsboard.yml
```
Comment all of HSQLDB DAO Configuration
```yaml
# HSQLDB DAO Configuration
#spring:
#  data:
#    jpa:
#      repositories:
#        enabled: "true"
#  jpa:
#    hibernate:
#      ddl-auto: "validate"
#    database-platform: "${SPRING_JPA_DATABASE_PLATFORM:org.hibernate.dialect.HSQLDialect}"
#  datasource:
#    driverClassName: "${SPRING_DRIVER_CLASS_NAME:org.hsqldb.jdbc.JDBCDriver}"
#    url: "${SPRING_DATASOURCE_URL:jdbc:hsqldb:file:${SQL_DATA_FOLDER:/tmp}/thingsboardDb;sql.enforce_size=false;hsqldb.log_size=5}"
#    username: "${SPRING_DATASOURCE_USERNAME:sa}"
#    password: "${SPRING_DATASOURCE_PASSWORD:}"
```
Uncomment Postgrees part (right below)
```yaml
# PostgreSQL DAO Configuration
spring:
  data:
    sql:
      repositories:
        enabled: "true"
  sql:
    hibernate:
      ddl-auto: "validate"
    database-platform: "${SPRING_JPA_DATABASE_PLATFORM:org.hibernate.dialect.PostgreSQLDialect}"
  datasource:
    driverClassName: "${SPRING_DRIVER_CLASS_NAME:org.postgresql.Driver}"
    url: "${SPRING_DATASOURCE_URL:jdbc:postgresql://localhost:5432/thingsboard}"
    username: "${SPRING_DATASOURCE_USERNAME:thingsboard}"
    password: "${SPRING_DATASOURCE_PASSWORD:thingsboard}"
```
Install it

```bash
sudo /usr/share/thingsboard/bin/install/install.sh --loadDemo
```

Ports to use:
Web UI: 8081

Mqtt: 9090


## Python Server
Install Requirements for MQTT

```bash
sudo pip install paho-mqtt
```



curl -v -X POST -d "{\"temperature\": 25}" localhost:9090/api/v1/9jmb70LAdydySSHQWzRi/telemetry --header "Content-Type:application/json"



























