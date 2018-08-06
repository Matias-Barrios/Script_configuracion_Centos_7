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
ip_addr=10.0.0.10
hostname=informix_server
[END-IPCONFIG]
```
