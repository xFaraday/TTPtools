#!/bin/bash

printf "
Enter path to folder with .CSVs (relative folder/ or absolute /home/user/folder/)
"
read -p "---> " folderpath

function startanalysis() {
    CSVcount=$(ls $folderpath | cut -d'.' -f2- | grep -i "csv" | wc -l)
    printf "[+] CSV count: $CSVcount\n"
    ls $folderpath | grep -i "csv" | xargs -I _ cat $folderpath/_ > analysis/combined.csv && printf "[+] $(pwd)/analysis/combined.csv made\n"
    cut -d',' -f2,4- analysis/combined.csv > analysis/prepped && printf "[+] $(pwd)/analysis/prepped made\n"
    cat analysis/prepped | sort | uniq -c | sort -nr > analysis/sorted && printf "[+] $(pwd)/analysis/sorted made\n"
    printf "[+] started counting process...\n\n"
    for i in {1..20}; do
        multiple=$(($CSVcount * $i))
        top=$(cat analysis/sorted | awk '{print $1}' | grep -nw "$multiple" | head -n 1 | cut -d':' -f1)
        bot=$(cat analysis/sorted | awk '{print $1}' | grep -nw "$multiple" | tail -n 1 | cut -d':' -f1)
        printf "[+] Multiple: $multiple"
        if [ -z "$top" ]; then
            printf "\n[-] Multiple: $multiple has no canidates...\n\n"
        else
            printf "\n[+] Multiple: $multiple has canidates!\n"
            echo -e "\tTop Index: $top"
            echo -e "\tBot Index: $bot\n"
            head -$bot analysis/sorted | tail +$top > analysis/sorted$multiple.csv
        fi 
    done
    printf "\n\n[+] ALL ANALYSIS FILES IN $(PWD)/anaylsis"
}

if [ -d "$folderpath" ]; then
    printf "\n[+] $folderpath exists!\n"
    printf "[+] making analysis/ folder\n"
    if [ -d "analysis/" ]; then
        printf "[-] analysis/ folder already made. Delete?(y/n)\n"
        read -p "---> " answer
        if [[ $answer == "y" || $answer == "Y" ]]; then
            rm -rf analysis/
            mkdir analysis
            startanalysis
        else
            exit 2
        fi
    else 
        mkdir analysis
        startanalysis
    fi
else
    printf "[-] $folderpath does not exist :(\n"
    exit 2
fi
