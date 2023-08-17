#!/bin/bash

# global vars
dhv_version="0.0.1"
# default resolver ip dns
dns_resolver="8.8.8.8"
# ping sleep
ping_sleep="2"
# Array with record types
record_types=("A" "AAAA" "NS" "CNAME" "MX" "TXT" "SRV" "CAA")
# check install tools
required_tools=("wget" "curl" "whatweb" "dig")
# header line
header="--------------------------------------------------------------------------------------------"

function help(){
        echo ""
        echo " Usage: ./dhv.sh --help [options...] -d <domain> -resolver <ip resolver> -dns -ip -whois -whatweb -redirect -ping <file> "
        echo ""
        echo "  -d, --domain            <domain.name>      Required argument for many operations"
        echo "  -all, --all                                Get all domain or ip information"
        echo "  -dns, --dns                                Get all available DNS records for the current domain"
        echo "  -resolver, --resolver   <dns.resolver>     Default DNS resolver IP is always 8.8.8.8"
        echo "  -ip, --ip                                  Get all available information by ip from a domain A record"
        echo "  -whois, --whois                            Get all available whosi information for the current domain"
        echo "  -whatweb, --whatweb                        Get website cms, or get information on what technologies it is based on"
        echo "  -redirect, --redirect                      Check the domain for the entire chain of consecutive redirects"
        echo "  -ping, --ping           <host_list.txt>    Check checks for pings to hosts from the list in the file"
        echo ""
        exit
}

# parse arguments

if [[ -z "$1" ]]
then
        help # calls help
fi

while [[ $# -gt 0 ]]
do
key="$1"
case $key in
    -d|--domain)
    domain="$2"
    shift # past argument
    shift # past value
    ;;
    -dns|--dns)
    dns="true"
    shift # past argument
    ;;
    -ip|--ip)
    ip="true"
    shift # past argument
    ;;
    -whois|--whois)
    whois="true"
    shift # past argument
    ;;
    -history|--history)
    dnshistory="true"
    shift # past argument
    ;;
    -whatweb|--whatweb)
    whatweb="true"
    shift # past argument
    ;;
    -spam|--spam)
    spam="true"
    shift # past argument
    ;;
    -redirect|--redirect)
    redirect="true"
    shift # past argument
    shift # past value
    ;;
    -cert|--cert)
    cert="true"
    shift # past argument
    shift # past value
    ;;
    -ping|--ping)
    get_ping="$2"
    shift # past argument
    shift # past value
    ;;
    -resolver|--resolver)
    resolver="$2"
    shift # past argument
    shift # past value
    ;;
    -all|--all)
    all="true"
    shift # past argument
    shift # past value
    ;;
    -h|--help) # reference
    shift # past argument
    shift # past value
    help # function calls help display
    ;;
    *) # processing of unknown parameters
    echo "  unknown parameter: $key"
    echo "  -h, --help help on dhv.sh"
    exit 1
    ;;
esac
done

if [[ -n $resolver ]]; then
    dns_resolver="$resolver"
fi

function intall_tools(){
    missing_tools=()

    for tool in "${required_tools[@]}"; do
        if ! command -v "$tool" &> /dev/null; then
            missing_tools+=("$tool")
        fi
    done

    if [[ ${#missing_tools[@]} -ne 0 ]]; then
        echo ""
        echo "ERROR - Missing tools: ${missing_tools[@]}"
        echo ""
        exit
    fi
}

function dns(){
    
    echo ""

    # Check domain registration info
    domain_registrar=$(whois $domain | grep "Registar created:" | awk '{print $3}')
    if [[ $domain_registrar == "" && $domain_registrar == "," ]]; then
        domain_registrar=$(whois $domain | grep "registrar:" | awk '{print $2}')
        if [[ $domain_registrar != "" ]]; then
            echo "Domain is registered with:   $domain_registrar"
        fi
    else
        echo "Domain is registered with:   $domain_registrar"
    fi

    # Check web hosting info
    web_hosting_ip=$(dig +short -t A "$domain" @$dns_resolver)
    web_hosting_info_desc=$(whois "$web_hosting_ip" | grep "descr:" | awk '{print $2}')
    web_hosting_info_country=$(whois "$web_hosting_ip" | grep "country:" | awk '{print $2}')
    echo "Web hosting info:            $web_hosting_info_desc, $web_hosting_info_country"

    # Check DNS hosting info
    dns_server_info=$(dig NS "$domain" @$dns_resolver | grep "IN" | awk '{print $5}' | grep -oE '[a-zA-Z0-9-]+\.[a-zA-Z]{2,}(\.[a-zA-Z]{2,})?' | head -n 1)
    dns_server_ip=$(dig A "$dns_server_info" @$dns_resolver | grep "IN" | awk '{print $5}' | grep -oE '([0-9]{1,3}\.){3}[0-9]{1,3}' | head -n 1)

    if [[ -n "$dns_server_ip" ]]; then
        dns_server_hosted=$(whois "$dns_server_ip" | grep "descr:" | awk '{print $2}')
        echo "Domain Name Hosted by:       $dns_server_hosted"
    fi


    # Check mail server info
    mail_server_info=$(dig +short -t MX "$domain" @$dns_resolver | awk '{print $2}' | head -n 1 )
    mail_server_info_mx_ip=$(dig A "$mail_server_info" @$dns_resolver | grep "IN" | grep -oE '([0-9]{1,3}\.){3}[0-9]{1,3}' | head -n 1 )
    mail_server_info_hosted_whois=$(whois "$mail_server_info_mx_ip")
    mail_server_info_hosted_whois_org_name=$(echo "$mail_server_info_hosted_whois" | grep "org-name:" | awk '{print $2}' | head -n 1)
    mail_server_info_hosted_whois_org_country=$(echo "$mail_server_info_hosted_whois" | grep "country:" | awk '{print $2}' | head -n 1)
    if [[ $mail_server_info_hosted_whois_org_name != "" && $mail_server_info_hosted_whois_org_name != "," ]]; then
        echo "Mail Server is hosted by:    $mail_server_info_hosted_whois_org_name, $mail_server_info_hosted_whois_org_country"
    fi
    

    # Check domain creation date
    creation_date=$(whois "$domain" | grep "Domain created:" | awk '{print $3}')
    if [[ $creation_date != "" && $creation_date != "," ]]; then
        echo "Domain Created Data:         $creation_date"
    fi

    # Check web server string
    web_server_string=$(curl -sI "http://$domain" | grep "Server:" | awk '{print $2}')
    if [[ $web_server_string != "" && $web_server_string != "," ]]; then
        echo "Web server string:           $web_server_string"
    fi



    echo ""
    echo "---------------"
    echo "| DNS Records |"
    echo "---------------"
    echo ""
    echo "$header"



    # Enumerating record types and doing dig
    printf "| %-6s | %-30s | %-16s | %-5s | %-40s \n" "Record" "Host Name" "IP Address" "TTL" "More Data "
    echo "$header"
    for record_type in "${record_types[@]}"; do
        output=$(dig $domain $record_type @$dns_resolver | grep -E "^$domain" | grep -vE "SOA")
        if [ -n "$output" ]; then
            while read -r line; do
                host_name=$(echo "$line" | awk '{print $1}')
                ttl=$(echo "$line" | awk '{print $2}')
                data=$(echo "$line" | awk '{for (i=5; i<=NF; i++) printf "%s ", $i; print ""}')

                domain_grep_data=$(echo "$data" | grep -oE '([a-zA-Z0-9-]+\.)?[a-zA-Z0-9-]+\.[a-zA-Z]{2,}')
                ip_grep_data=$(echo "$data" | grep -oE '([0-9]{1,3}\.){3}[0-9]{1,3}')


                if [[ $record_type != "TXT" && $record_type != "AAAA" && $record_type != "SRV" && $record_type != "CAA" && $record_type != "SOA" && $record_type != "MX" && $domain_grep_data != "" ]]; then
                    # if a domain or subdomain get its IP
                    ip_address=$(dig $domain_grep_data A +short @$dns_resolver)
                    printf "| %-6s | %-30s | %-16s | %-5s | %-40s \n" "$record_type" "$data" "$ip_address" "$ttl"  ""
                else
                    # if IP is specified in the date, just display this IP
                    if [[ $record_type != "TXT" && $record_type != "AAAA" && $record_type != "SRV" && $record_type != "CAA" && $record_type != "SOA" && $record_type != "MX" ]];then
                        printf "| %-6s | %-30s | %-16s | %-5s | %-40s \n" "$record_type" "$host_name" "$ip_grep_data" "$ttl"  ""
                    else
                        if [[ $record_type != "MX" ]];then
                            printf "| %-6s | %-30s | %-16s | %-5s | %-40s \n" "$record_type" "" "" "$ttl" "$data"
                        fi
                    fi
                fi
                if [[ $record_type == "MX" ]]; then
               # if the MX record is caught, we process it
                    mx_record_nuber=$(echo "$data" | awk '{print $1}')
                    mx_domain=$(echo "$data" | cut -d ' ' -f 2-)
                    printf "| %-6s | %-30s | %-16s | %-5s | %-40s \n" "$record_type" "$mx_domain" "$ip_address" "$ttl"  "Preference: $mx_record_nuber"
                fi
                

            done <<< "$output"
        fi
    done

        # В конце получаем SOA записи домена
        soa_result=$(dig $domain SOA @$dns_resolver | grep -E "^$domain" | grep "SOA")
        host_name=$(echo "$soa_result" | awk '{print $1}')
        record_type=$(echo "$soa_result" | awk '{print $4}')
        ttl=$(echo "$soa_result" | awk '{print $2}')
        data=$(echo "$soa_result" | awk '{for (i=5; i<=NF; i++) printf "%s ", $i; print ""}')
        printf "| %-6s | %-30s | %-16s | %-5s | %-40s \n" "$record_type" "$host_name" "" "$ttl"  "$data"

        # At the end we get SOA records of the domain

        ip_addresses=$(dig +short $domain @$dns_resolver | grep -E '^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$')
        for ip_ptr_check in $ip_addresses; do
            ptr_record=$(dig +short -x $ip_ptr_check)
            printf "| %-6s | %-30s | %-16s | %-5s | %-40s \n" "PTR" "" "$ip_ptr_check" ""  "$ptr_record"
        done

        # get PTR for MX records

        mx_domains=$(dig +short MX $domain @$dns_resolver | awk '{print $2}' | sed 's/.$//')

        # We iterate over each domain and get a PTR record
        for mx_domain in $mx_domains; do
            mx_ip_addresses=$(dig +short $mx_domain @$dns_resolver | grep -E '^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$')
            ptr_record=$(dig +short -x $mx_ip_addresses)
            printf "| %-6s | %-30s | %-16s | %-5s | %-40s \n" "PTR" "" "$mx_domain" ""  "$ptr_record"
        done
        echo "$header"
        
        # Теперь выводим информацию какой компании принадлежать почтовые сервер хостинг и NS сервера.
        echo ""
        echo "----------------------------"
        echo "| IP Addresses Information |"
        echo "----------------------------"
        echo ""

        # get info Web server or ip address info 
        webhosting_ip_info_netname=$(whois "$web_hosting_ip" | grep -i "netname:" | awk '{print $2}')
        webhosting_ip_info_organization=$(whois "$web_hosting_ip" | grep -i "org-name:" | awk '{for (i=2; i<=NF; i++) printf "%s ", $i; print ""}')
        # get info Mail server or ip address info
        webhosting_ip_info_mail_netname=$(whois "$mail_server_info_mx_ip" | grep -i "netname:" | awk '{print $2}')
        webhosting_ip_info_mail_organization=$(whois "$mail_server_info_mx_ip" | grep -i "org-name:" | awk '{for (i=2; i<=NF; i++) printf "%s ", $i; print ""}')
        # get info Name server or ip address info
        webserver_ns_ip_info_mail_netname=$(whois "$dns_server_ip" | grep -i "netname:" | awk '{print $2}')
        webserver_ns_ip_info_mail_organization=$(whois "$dns_server_ip" | grep -i "org-name:" | awk '{for (i=2; i<=NF; i++) printf "%s ", $i; print ""}')

        echo "$header"
        printf "| %-19s | %-16s | %-25s | %-60s \n" "Address Type " "IP Address " "Network Name" "Organization "
        echo "$header"
        printf "| %-19s | %-16s | %-25s  | %-60s \n" "Web Server " "$web_hosting_ip" "$webhosting_ip_info_netname" "$webhosting_ip_info_organization"
        printf "| %-19s | %-16s | %-25s  | %-60s \n" "Mail Server  " "$mail_server_info_mx_ip" "$webhosting_ip_info_mail_netname" "$webhosting_ip_info_mail_organization"
        printf "| %-19s | %-16s | %-25s  | %-60s \n" "Domain Name Server " "$dns_server_ip" "$webserver_ns_ip_info_mail_netname" "$webserver_ns_ip_info_mail_organization" 

    # end with dash
    printf "%s\n" "$header"
    echo ""
}

function get_ip(){
    

    if [[ -n $ip || -n $all ]]; then

        ip=$(dig +short $domain @$dns_resolver | grep -E '^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$')
        
        echo ""
        echo "-------------------------------------"
        echo "| Web Server IP Address Information |"
        echo "-------------------------------------"
        echo ""

        whois $ip

    fi


}

function get_whois(){


    echo ""
    echo "--------------------------"
    echo "| Raw Domain Information |"
    echo "--------------------------"
    echo ""

    whois $domain
    
}


function get_whatweb(){

    echo ""
    echo "-----------------------"
    echo "| WhatWeb Information |"
    echo "-----------------------"
    echo ""

    whatweb_output=$(whatweb "$domain")

    # Cleaning up the output by removing ANSI color codes

    cleaned_output=$(echo "$whatweb_output" | sed 's/\x1b\[[0-9;]*m//g')

    # Divide the output into paragraphs and output line by line

    IFS=$'\n'
    for paragraph in $cleaned_output; do
        echo "$paragraph"
        echo "$header"
    done
    echo ""

}

function check_redirect(){
    echo ""
    echo "-------------------------"
    echo "| Domain check redirect |"
    echo "-------------------------"
    echo ""

    redirect_checks=$(curl -sIL "$domain")

    # Getting information about redirects using curl

    redirect_checks=$(curl -sIL "$domain")

    # Breaking Output into Lines with IFS

    IFS=$'\n'
    redirects=()
    for line in $redirect_checks; do
        redirects+=("$line")
    done

    # Iterate over each line in the redirects array

    echo "> ----------------------------"
    for ((i = 0; i < ${#redirects[@]}; i++)); do
        line="${redirects[i]}"
        
        # Skip blank lines

        if [[ "$line" =~ ^[[:space:]]*$ ]]; then
            continue
        fi
        
        # If the line starts with HTTP/, then this is information about the status of the redirect

        echo $line
        if [[ "$line" =~ ^[[:space:]]*HTTP/.* ]]; then
            while [[ ! "${redirects[i+1]}" =~ ^[[:space:]]*$ && ! "${redirects[i+1]}" =~ ^[[:space:]]*[0-9]{3}.* ]]; do
                i=$((i+1))
                echo "  ${redirects[i]}"
            done
            echo
            echo "> ----------------------------"
        fi
    done

    

}


function get_ping(){

    echo ""
    echo "------------------"
    echo "| ping hosts file |"
    echo "------------------"
    echo "" 

    echo "$get_ping"

    hosts=($(cat "$get_ping"))

    # Endless cycle
    while true; do
        clear  # Screen cleaning

        echo "Ping Status:"
        echo "------------------------------------------------------"

        # Looping through all hosts from the list
        for host in "${hosts[@]}"; do
            ping_output=$(ping -c 4 "$host" 2>&1)
            if [[ $? -eq 0 ]]; then
                status="OK"
                packet_loss=$(echo "$ping_output" | grep "packet loss" | awk '{print $6}')
                avg_ping=$(echo "$ping_output" | grep "rtt" | awk -F '/' '{print $5}')
            else
                status="FAIL"
                packet_loss="100%"
                avg_ping="N/A"
            fi
            echo "$host: $status | Packet Loss: $packet_loss | Avg Ping: $avg_ping ms"
        done

        sleep $ping_sleep  # Pause between iterations
    done

}

# check the regular expression for the correctness of the domain \ subdomain

if [[ -n $domain ]]; then
    domain=$(echo "$domain" | grep -oE '[a-zA-Z0-9-]+\.[a-zA-Z]{2,}(\.[a-zA-Z]{2,})?')

    if [[ -z $domain ]]; then
        echo "Error domain perdan is not correct $domain"
        exit
    fi
fi


function init(){
intall_tools

if [[ -n $domain && -z $all ]]; then
    if [[ -n $dns ]]; then 
        dns
    fi
    if [[ -n $whois ]]; then 
        get_whois
    fi
    if [[ -n $whatweb ]]; then 
        get_whatweb
    fi
    if [[ -n $redirect ]]; then 
        check_redirect "$domain"
    fi
    if [[ -n $ip ]]; then 
        get_ip
    fi
else
    if [[ -n $domain ]]; then
        dns
        get_ip
        get_whois
        get_whatweb
        check_redirect "$domain"
    fi
fi

if [[ -n $get_ping ]]; then
    get_ping
fi


}

init