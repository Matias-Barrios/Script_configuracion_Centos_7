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
done

## Si no puedo leer el archivo salgo con status 2
if [[ ! -r config.conf ]]
then
    echo "No tengo permisos de lectura a 'config.conf', por lo tanto, nos vemos!!"
    exit 2
done

grupos=$( sed -n '/^\[GROUPS\]$/,/^\[END-GROUPS\]$/ { /^\[GROUPS\]$/d; /^\[END-GROUPS\]$/d; p; }' config.conf | sed 's/#.*$//g' | Trimm )
usuarios=$( sed -n '/^\[USERS\]$/,/^\[END-USERS\]$/ { /^\[USERS\]$/d; /^\[END-USERS\]$/d; p; }' config.conf | sed 's/#.*$//g' | Trimm )
config_IP=$( sed -n '/^\[IPCONFIGUSERS\]$/,/^\[END-IPCONFIG\]$/ { /^\[IPCONFIG\]$/d; /^\[END-IPCONFIG\]$/d; p; }' config.conf | sed 's/#.*$//g' | Trimm )

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

done <<< "$grupos"

## Crear Usuarios
while read usuario
do
  usuario=$( Trimm "$usuario" )
  ## Si el nombre no es valido, salgo con  status 3
  if [[ ! $usuario =~ ^[a-z]{4,10}[.][a-z]{4,10}$ ]] && 
  then
    echo "Nombre de usuario no valido : $usuario "
    exit 4
  fi

done <<< "$usuarios"


ip=$(  Parse_value "ip_addr" "$config_IP" | Trimm )
lin_hostname=$(  Parse_value "hostname" "$config_IP" | Trimm  )
device=$(  Parse_value "device" "$config_IP" | Trimm  )
base_ip=$(  Parse_value "base_ip" "$config_IP" | Trimm  )
gateway=$(  Parse_value "gateway" "$config_IP" | Trimm  )


if [[ ! "$ip" ~= ^[0-9][0-9]?[0-9]?$ ]]
then
    ## Si la ip no es valida salir con status 5
    echo "Ip no valida : $ip"
    exit 5
fi


if [[ ! $lin_hostname =~ ^[a-z]{4,16}$ ]] && [[ ! $lin_hostname =~ ^[^_][^_]*_?[^_]*[^_]$ ]]
then
    ## Si el hostname no es valido salir con status 6
    echo "Hostname no valido : $lin_hostname"
    exit 6
fi

if [[ ! $device =~ ^[a-z]{4,16}[0-9]$ ]]
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
    exit 8
fi

## Si no es asi, los seteo.

Setear_IP_Hostname_DNS $lin_hostname $device $base_ip $ip_addr $gateway

