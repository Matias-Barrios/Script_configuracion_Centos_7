### Este script trata de automatizar la configuracion basica de Centos 7

Funciona mediante un archivo de configuracion llamado **config.conf**, que tiene la siguiente sintaxis :

```
[GROUPS]
    soporte         ## Aca se ingresan los nombres de grupos a crear
    informix        ## Forzamos el formato [[ ! $grupo =~ ^[a-z]{4,16}$ ]] && [[ ! $grupo =~ ^[^_][^_]*_?[^_]*[^_]$ ]]
[END-GROUPS]

[USERS]
    informix                                # Aca se insertan los nombres de usuario, los grupos a los que pertenecera, 
    lucia soporte,wheel Clavesecreta@2018   # y un password para el mismo. El formato es ^(?=.*[A-Z].*)(?=.*[!@#$&*])(?=.*[0-9].*[0-9])(?=.*[a-z].*[a-z].*[a-z]).{8,}$
[END-USERS]

[IPCONFIG]
    ip_addr=10                              # Aca se ingresa la informacion concerniente a la red. Antes de correr el script se 
    lin_hostname=informix_server            # nos debemos asegurar de que el 'device' existe
    device=ens33
    base_ip=10.0.0
    gateway=1
[END-IPCONFIG]

[DIRS]
    /matias_test 0700 matias.matias         # Aca se ingresan los directorios a crearse, los permisos y el ownership
    /prueba/vasos 0777 matias.informix      # Los permisos deben ser especificados en octal
[END-DIRS]
```
