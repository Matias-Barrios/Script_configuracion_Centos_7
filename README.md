### Este script trata de automatizar la configuracion basica de Centos 7

Funciona mediante un archivo de configuracion llamado **config.conf**, que tiene la siguiente syntaxis :

```
[GROUPS]
    soporte
    informix
[END-GROUPS]

[USERS]
    informix
[END-USERS]

[IPCONFIG]
    ip_addr=10
    lin_hostname=informix_server
    device=eth0
    base_ip=10.0.0
    gateway=1
[END-IPCONFIG]

[DIRS]
    /matias_test 0700 matias.matias
    /prueba/vasos 0777 matias.informix
[END-DIRS]
```
