#!/bin/bash

#   Cabeçalho do Programa
echo "
Programa que gera Listas de Ips separados por tecnologias
apartir de um arquivo grepable do Nmap
"

#   Mensagem de Help
MENSAGEM="
    -g | --grepable         Inserir o Arquivo Grepable no Programa.
"

#   Inicialização das chaves do Programa.
GREPABLE=0


#   Estrutura do Shift
while test -n "$1"
do
    case "$1" in

    -h | --help)
        echo "$MENSAGEM"
        exit
    ;;

    -g | --grepable)
        GREPABLE=1
        FILE="$2"
        
    ;;

    esac

shift
done



#   Criar Pasta com data e hora exata
if [ "$GREPABLE" -eq 1 ]; then

    DIRNAME="CREATEDIN_$(date +%Y%m%d_%H:%M)"
    mkdir "$DIRNAME"
    
fi


#   Receber arquivo grepable do nmap
echo "[*] Gerando Listas com base no arquivo $FILE ..."


#   usar expresão regular para filtrar o texto por bancos de dados
#   e criar um arquivo de texto com ips que possuem esse serviço.                                                                                    
cat "$FILE" | sed -n '/http\/\/Apache httpd/{s/Host: \([^ ]*\).*/\1/p}' >> "$DIRNAME"/TEMPWEBSERVICE.txt    #   Para servidores                                                                                  
cat "$FILE" | sed -n '/http\/\/nginx /{s/Host: \([^ ]*\).*/\1/p}' >> "$DIRNAME"/TEMPWEBSERVICE.txt          #                                                      
cat "$FILE" | sed -n '/http\/\/Node.js /{s/Host: \([^ ]*\).*/\1/p}' >> "$DIRNAME"/TEMPWEBSERVICE.txt                                                  
cat "$FILE" | sed -n '/http\/\/Apache Tomcat/{s/Host: \([^ ]*\).*/\1/p}' >> "$DIRNAME"/TEMPWEBSERVICE.txt                                                         
cat "$FILE" | sed -n '/http\/\/Microsoft IIS/{s/Host: \([^ ]*\).*/\1/p}' >> "$DIRNAME"/TEMPWEBSERVICE.txt

# Ajustando Arquivo...
cat "$DIRNAME"/TEMPWEBSERVICE.txt | sort | uniq > "$DIRNAME"/WebServiceIpList.txt
rm -rf "$DIRNAME"/TEMPWEBSERVICE.txt
                                                       
cat "$FILE" | sed -n '/tcp\/\/mysql/{s/Host: \([^ ]*\).*/\1/p}' >> "$DIRNAME"/TEMPDATABASES.txt              #   Para Bancos                                                                                         
cat "$FILE" | sed -n '/tcp\/\/.*MariaDB/{s/Host: \([^ ]*\).*/\1/p}' >> "$DIRNAME"/TEMPDATABASES.txt         
cat "$FILE" | sed -n '/tcp\/\/postgresql/{s/Host: \([^ ]*\).*/\1/p}' >> "$DIRNAME"/TEMPDATABASES.txt 
cat "$FILE" | sed -n '/tcp\/\/ms-sql-s/{s/Host: \([^ ]*\).*/\1/p}' >> "$DIRNAME"/TEMPDATABASES.txt 
cat "$FILE" | sed -n '/tcp\/\/oracle/{s/Host: \([^ ]*\).*/\1/p}' >> "$DIRNAME"/TEMPDATABASES.txt 
cat "$FILE" | sed -n '/tcp\/\/mongodb/{s/Host: \([^ ]*\).*/\1/p}' >> "$DIRNAME"/TEMPDATABASES.txt 
cat "$FILE" | sed -n '/tcp\/\/cassandra/{s/Host: \([^ ]*\).*/\1/p}' >> "$DIRNAME"/TEMPDATABASES.txt 

# Ajustando Arquivo...
cat "$DIRNAME"/TEMPDATABASES.txt | sort | uniq > "$DIRNAME"/DataBasesIpList.txt
rm -rf "$DIRNAME"/TEMPDATABASES.txt
                                                       
cat "$FILE" | sed -n '/tcp\/\/kerberos/{s/Host: \([^ ]*\).*/\1/p}' >> "$DIRNAME"/TEMPAUTHSERVICES.txt          #   Para Serviços                                                         
cat "$FILE" | sed -n '/tcp\/\/ldap/{s/Host: \([^ ]*\).*/\1/p}' >> "$DIRNAME"/TEMPAUTHSERVICES.txt              
cat "$FILE" | sed -n '/tcp\/\/netbios-ssn/{s/Host: \([^ ]*\).*/\1/p}' >> "$DIRNAME"/TEMPAUTHSERVICES.txt
cat "$FILE" | sed -n '/tcp\/\/ssh/{s/Host: \([^ ]*\).*/\1/p}' >> "$DIRNAME"/TEMPAUTHSERVICES.txt
cat "$FILE" | sed -n '/tcp\/\/vnc/{s/Host: \([^ ]*\).*/\1/p}' >> "$DIRNAME"/TEMPAUTHSERVICES.txt
cat "$FILE" | sed -n '/tcp\/\/snmp/{s/Host: \([^ ]*\).*/\1/p}' >> "$DIRNAME"/TEMPAUTHSERVICES.txt
cat "$FILE" | sed -n '/tcp\/\/msrpc/{s/Host: \([^ ]*\).*/\1/p}' >> "$DIRNAME"/TEMPAUTHSERVICES.txt

# Ajustando Arquivo...
cat "$DIRNAME"/TEMPAUTHSERVICES.txt | sort | uniq > "$DIRNAME"/AuthServicesIpList.txt
rm -rf "$DIRNAME"/TEMPAUTHSERVICES.txt