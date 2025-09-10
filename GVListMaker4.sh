#!/bin/bash

#	v 1.0.0 - Versão base do programa com funções básicas.
#	v 2.0.0 - Versão com lógica aprimorada do programa e adição de logo.
#	v 3.0.0 - Foi adicionado a opção de excluir hosts do scan.
#	v 4.0.0 - Hosts não se repetiram mais em arquivos de ip gerados.


#   Cabeçalho do Programa & Logo Art
cat ArtLogo.txt

echo -e "
\033[34m[*] Programa que gera Listas de Ips separados por tecnologias apartir de um arquivo grepable do Nmap\033[m"

#   Mensagem de Help
MENSAGEM="

                Em casos de Problemas com o funcionamento do Programa
                    verifique as permições do arquivo...



    -g | --grepable         Inserir o Arquivo Grepable no Programa.

    -h | --help             Mostra mensagem de ajuda.

    -v | --version          Mostra versão do programa.

    -n | --nmap             Utiliza o Nmap para gerar arquivo grepable.

    -nF | --nmap-filtred    Utiliza o Nmap em modo filtrado, excluindo endereços específicos do scan.

"

#   Inicialização das chaves do Programa.
GREPABLE=0
NMAP=0
NMAPFILTERED=0


#   Estrutura do Shift
while test -n "$1"
do
    case "$1" in

    -h | --help)
        echo "$MENSAGEM"
        exit
    ;;

    -v | --version)
        echo "[*] GvListMaker versão 3.0.0"
        exit
    ;;

    -g | --grepable)
        GREPABLE=1
        FILE="$2"
    ;;

    -n | --nmap)
        NMAP=1
        SUBREDE="$2"
        echo "[*] Iniciando Scan de Rede com Nmap em $2 ..."
    ;;

    -nF | --nmap-filtred)
	NMAPFILTERED=1
	SUBREDE="$2"
	FILTERIPS="$3"
	echo "[*] Iniciando Scan de Rede com Nmap em $2, excluindo $3 ..."
    ;;

    esac

shift
done

if [ "$NMAPFILTERED" -eq 1 ]; then

    [ -z "$SUBREDE" ] && {
        echo -e "\033[31m[*] Valor para ferramenta Nmap inválida!\033[m"
        exit
    }

    [ -z "$FILTERIPS" ] && {
        echo -e "\033[31m[*] Valores para serem excluidos da ferramenta Nmap inválidos!\033[m"
        exit
    }

    nmap -T 4 -sn "$SUBREDE" --excludefile "$FILTERIPS" -oG TEMPgrepablefile.txt
    cat TEMPgrepablefile.txt | grep -oE '([0-9]{1,3}\.){3}[0-9]{1,3}' > TEMPUPHOSTS.txt
    nmap -sV -Pn -T 4 -iL TEMPUPHOSTS.txt --excludefile "$FILTERIPS" -oG BRUTEFILEGREPABLE.txt
    FILE=BRUTEFILEGREPABLE.txt

    #Limpando Diretorio...
    rm -rf TEMPgrepablefile.txt
    rm -rf TEMPUPHOSTS.txt

    DIRNAME="CREATEDIN_$(date +%Y%m%d_%H:%M)"
    mkdir "$DIRNAME"

fi

if [ "$NMAP" -eq 1 ]; then

    [ -z "$SUBREDE" ] && {
        echo -e "\033[31m[*] Valor para ferramenta Nmap inválida!\033[m"
        exit
    }

    nmap -T 4 -sn "$SUBREDE" -oG TEMPgrepablefile.txt
    cat TEMPgrepablefile.txt | grep -oE '([0-9]{1,3}\.){3}[0-9]{1,3}' > TEMPUPHOSTS.txt
    nmap -sV -Pn -T 4 -iL TEMPUPHOSTS.txt -oG BRUTEFILEGREPABLE.txt
    FILE=BRUTEFILEGREPABLE.txt

    #Limpando Diretorio...
    rm -rf TEMPgrepablefile.txt
    rm -rf TEMPUPHOSTS.txt

    DIRNAME="CREATEDIN_$(date +%Y%m%d_%H:%M)"
    mkdir "$DIRNAME"

fi

#   Criar Pasta com data e hora exata
if [ "$GREPABLE" -eq 1 ]; then

    [ -z "$FILE" ] && {
        echo "[*] Usuário não informou nenhuma lista ou uma lista válida para o program!"
        exit
    }

    DIRNAME="CREATEDIN_$(date +%Y%m%d_%H:%M)"
    mkdir "$DIRNAME"

fi


#   Receber arquivo grepable do nmap
echo "[*] Gerando Listas com base no arquivo $FILE ..."


#   usar expresão regular para filtrar o texto por bancos de dados
#   e criar um arquivo de texto com ips que possuem esse serviço.
#   Para servidores Web...
while IFS= read -r line || [[ -n "$line" ]]
do

    cat "$FILE" | sed -n "/http\/\/${line}/{s/Host: \([^ ]*\).*/\1/p}" >> "$DIRNAME"/TEMPWEBSERVICE.txt

done < WordLists/WebServicesWordList.txt

# Ajustando Arquivo...
cat "$DIRNAME"/TEMPWEBSERVICE.txt | sort | uniq > "$DIRNAME"/WebServiceIpList.txt
rm -rf "$DIRNAME"/TEMPWEBSERVICE.txt

#   Para Bancos de Dados...
while IFS= read -r line || [[ -n "$line" ]]
do

    cat "$FILE" | sed -n "/tcp\/\/${line}/{s/Host: \([^ ]*\).*/\1/p}" >> "$DIRNAME"/TEMPDATABASES.txt

done < WordLists/DataBasesWordList.txt

# Ajustando Arquivo...
cat "$DIRNAME"/TEMPDATABASES.txt | sort | uniq > "$DIRNAME"/DataBasesIpList.txt
rm -rf "$DIRNAME"/TEMPDATABASES.txt

#   Para Serviços de Autentificação
while IFS= read -r line || [[ -n "$line" ]]
do

    cat "$FILE" | sed -n "/tcp\/\/${line}/{s/Host: \([^ ]*\).*/\1/p}" >> "$DIRNAME"/TEMPAUTHSERVICES.txt

done < WordLists/AuthServicesWordList.txt

# Ajustando Arquivo...
cat "$DIRNAME"/TEMPAUTHSERVICES.txt | sort | uniq > "$DIRNAME"/AuthServicesIpList.txt
rm -rf "$DIRNAME"/TEMPAUTHSERVICES.txt

# Tornando cada host único por lista...
# Comparanto AuthList com WebList...
grep -vxFf "$DIRNAME"/AuthServicesIpList.txt "$DIRNAME"/WebServiceIpList.txt > OUTPUT && cat OUTPUT > "$DIRNAME"/WebServiceIpList.txt

# Comparando AuthList com DbList...
grep -vxFf "$DIRNAME"/AuthServicesIpList.txt "$DIRNAME"/DataBasesIpList.txt > OUTPUT && cat OUTPUT > "$DIRNAME"/DataBasesIpList.txt

# Comparando WebList com DbList...
grep -vxFf "$DIRNAME"/WebServiceIpList.txt "$DIRNAME"/DataBasesIpList.txt > OUTPUT && cat OUTPUT > "$DIRNAME"/DataBasesIpList.txt

