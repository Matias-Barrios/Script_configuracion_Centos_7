#!/bin/bash

# Este script configura el server de acuerdo a los contenidos de config.conf
# 

## Aca en functions.sh van algunas funciones para cosas miscelaneas
source functions.sh

## Si no puedo encontrar el archivo salgo con exit status 1
if [[ ! -f config.conf ]]
then
    echo "No veo ningun archivo llamado 'config.conf', por lo tanto, nos vemos!!"
    exit 1
fi

## Si no puedo leer el archivo salgo con status 2
if [[ ! -r config.conf ]]
then
    echo "No tengo permisos de lectura a 'config.conf', por lo tanto, nos vemos!!"
    exit 2
fi

grupos=$( sed -n '/^\[GROUPS\]$/,/^\[END-GROUPS\]$/ { /^\[GROUPS\]$/d; /^\[END-GROUPS\]$/d; p; }' config.conf | sed 's/#.*$//g' | Trimm )
usuarios=$( sed -n '/^\[USERS\]$/,/^\[END-USERS\]$/ { /^\[USERS\]$/d; /^\[END-USERS\]$/d; p; }' config.conf | sed 's/#.*$//g' | Trimm )
config_IP=$( sed -n '/^\[IPCONFIG\]$/,/^\[END-IPCONFIG\]$/ { /^\[IPCONFIG\]$/d; /^\[END-IPCONFIG\]$/d; p; }' config.conf | sed 's/#.*$//g' | Trimm )
dirs=$( sed -n '/^\[DIRS\]$/,/^\[END-DIRS\]$/ { /^\[DIRS\]$/d; /^\[END-DIRS\]$/d; p; }' config.conf | sed 's/#.*$//g' | Trimm )

## Crear grupos
while read grupo
do
  grupo=$( Trimm "$grupo" )
  if [[ ! $grupo =~ ^[a-z]{4,16}$ ]] && [[ ! $grupo =~ ^[^_][^_]*_?[^_]*[^_]$ ]]
  then
    ## Si el nombre no es valido, salgo con  status 3
    echo "Nombre de grupo no valido : $grupo"
    exit 3
  fi

  groupadd $grupo

done <<< "$grupos"

## Crear Usuarios
while read usuario
do
  usuario=$( Trimm "$usuario" )
  nombre_usuario=$( echo "$usuario" | awk '{print $1}' | Trimm )
  grupos_usuario=$( echo "$usuario" | awk '{print $2}' | Trimm )
  passwd_usuario=$( echo "$usuario" | awk '{print $3}' | Trimm )
  ## Si el nombre no es valido, salgo con  status 3
  if [[ ! $nombre_usuario =~ ^[a-z]{4,20}$ ]]  
  then
    echo "Nombre de usuario no valido : $nombre_usuario "
    exit 4
  fi
  ## Si el formato de los grupos no es valido, salgo con  status 15
  if [[ ! $grupos_usuario =~ ^([a-z]{4,20}[,]?)$ ]]  
  then
    echo "Grupos de usuario no validos : $grupos_usuario "
    exit 15
  fi
  ## Si el formato de el password no es valido, salgo con  status 16
  ## Esto busca que el password asignado sea seguro, aunque sea solo un password temporal
  if [[ -z $( echo "$passwd_usuario" | grep -P '^(?=.*[A-Z].*[A-Z])(?=.*[!@#$&*])(?=.*[0-9].*[0-9])(?=.*[a-z].*[a-z].*[a-z]).{8,}$' ) ]]
  then
    echo "Password de usuario no valido : $passwd_usuario "
    exit 16
  fi

  useradd -m -d /home/$nombre_usuario $nombre_usuario
  ## Si no se pudo crear el usuario por algun error, salgo con  status 17
  if [[ $? -ne 0 ]]
  then
    echo "Ocurrio un error al crear el usuario"
    exit 17
  fi
  echo -e "$passwd_usuario\n$passwd_usuario" | passwd nombre_usuario

done <<< "$usuarios"


## Crear DIRS
while read dir
do
  dir=$( Trimm "$dir" )
  dir_name=$( echo "$dir" | awk '{print $1}' | Trimm )
  dir_permissions=$( echo "$dir" | awk '{print $2}' | Trimm )
  dir_owner_group=$( echo "$dir" | awk '{print $3}' | Trimm )
  ## Si el nombre no es valido, salgo con  status 10
  if [[ ! $dir_name =~ ^/[a-z/_{}]{5,250}$ ]] 
  then
    echo "Nombre de directorio no valido : $dir_name "
    exit 10
  fi
  ## Si el formato de permisos no es valido, salgo con  status 11
  if [[ ! $dir_permissions =~ ^0[0-7][0-7][0-7]$ ]] 
  then
    echo "Formato de permisos no valido : $dir_permissions "
    exit 11
  fi
  ## Si el formato de ownership no es valido, salgo con  status 12
  if [[ ! $dir_owner_group =~ ^[a-z]{4,20}[.][a-z]{4,20}$ ]] && [[ ! $dir_owner_group =~ ^[^_][^_]*_?[^_]*[^_]$ ]]
  then
    echo "Formato de ownership no valido : $dir_owner_group "
    exit 12
  fi


  mkdir -p $dir_name
  ## Si no se puede crear una carpeta fallar con status 13
  if [[ $? -ne 0 ]]
  then
    echo "Fallo al crear directorio! : $dir_name"
    exit 13
  fi

  chmod $dir_permissions $dir_name
  ## Si no se puede cambiar los permisos de carpeta fallar con status 14
  if [[ $? -ne 0 ]]
  then
    echo "Fallo al cambiar permisos $dir_permissions de  directorio! : $dir_name"
    exit 14
  fi

  chown $dir_owner_group $dir_name
  ## Si no se puede cambiar el ownership de una carpeta fallar con status 15
  if [[ $? -ne 0 ]]
  then
    echo "Fallo al cambiar el ownership $dir_owner_group de  directorio! : $dir_name"
    exit 15
  fi

done <<< "$dirs"

ip=$(  Parse_value "ip_addr" "$config_IP" | Trimm )
lin_hostname=$(  Parse_value "lin_hostname" "$config_IP" | Trimm  )
device=$(  Parse_value "device" "$config_IP" | Trimm  )
base_ip=$(  Parse_value "base_ip" "$config_IP" | Trimm  )
gateway=$(  Parse_value "gateway" "$config_IP" | Trimm  )

if [[ ! "$ip" =~ ^[0-9][0-9]?[0-9]?$ ]]
then
    ## Si la ip no es valida salir con status 5
    echo "Ip no valida : $ip"
    exit 5
fi


if [[ ! $lin_hostname =~ ^[a-z]{4,25}$ ]] && [[ ! $lin_hostname =~ ^[^_][^_]*_?[^_]*[^_]$ ]]
then
    ## Si el hostname no es valido salir con status 6
    echo "Hostname no valido : $lin_hostname"
    exit 6
fi

if [[ ! $device =~ ^[a-z]{2,16}[0-9][0-9]?$ ]]
then
    ## Si el nombre de la interfaz no es valido salir con status 6
    echo "Interfaz no valida : $device"
    exit 7
fi


if [[ ! $base_ip =~ ^[0-9]{1,3}[.][0-9]{1,3}[.][0-9]{1,3}$ ]]
then
    ## Si la ip base no es valida salir con status 8
    echo "Ip base no valida : $base_ip"
    exit 8
fi


if [[ ! $gateway =~ ^[0-9][0-9]?[0-9]?$ ]]
then
    ## Si la ip base no es valida salir con status 8
    echo "Ip base no valida : $gateway"
    exit 9
fi

## Si no es asi, los seteo.
Setear_IP_Hostname_DNS $lin_hostname $device $base_ip $ip $gateway

