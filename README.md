```
  _____  _    ___      __        _           _       
 |  __ \| |  | \ \    / /\      | |         (_)      
 | |  | | |__| |\ \  / /  \   __| |_ __ ___  _ _ __  
 | |  | |  __  | \ \/ / /\ \ / _` | '_ ` _ \| | '_ \ 
 | |__| | |  | |  \  / ____ \ (_| | | | | | | | | | |
 |_____/|_|  |_|   \/_/    \_\__,_|_| |_| |_|_|_| |_|
               
```

# DESCRIPTION

DHVAdmin (Дохуя виювер Админитстратор) - на создание утилиты был вдохновлен утилитой, под названием DomainHostingView, к сожалению аналогов не оказалось под linux, поэтому был создан данный скрипт, скрипт создан для помоши и быстрой оценки домена его DNS, или вебсервера. утилита по задумке должна помочь технической поддержке хостингов, наиболее полно и быстро оценивать проблемы по вопросам работы, сайтов DNS и хостинга сервера в целом.

# INSTALLATION

Для работы утилиты требуются некоторые зависимости, если у вас их нет то установите их через ваш пакетный мененджер.

wget, curl, whatweb, dig, openssl

```
git clone https://github.com/solo10010/DHVAdmin
cd DHVAdmin
chmod +x dhv.sh
./dhv.sh --help
```

# REFERENCE

```
./dhv.sh --help

 Usage: ./dhv.sh --help [options...] -d <domain> -resolver <ip resolver> -dns -ip -whois -whatweb -redirect -ping <file>

  -d, --domain            <domain.name>      Required argument for many operations
  -dns, --dns                                Get all available DNS records for the current domain
  -resolver, --resolver   <dns.resolver>     Default DNS resolver IP is always 8.8.8.8
  -ip, --ip                                  Get all available information by ip from a domain A record
  -whois, --whois                            Get all available whosi information for the current domain
  -whatweb, --whatweb                        Get website cms, or get information on what technologies it is based on
  -redirect, --redirect                      Check the domain for the entire chain of consecutive redirects
  -ping, --ping           <host_list.txt>    Check checks for pings to hosts from the list in the file

```

# LAUNCH EXAMPLES

1. Get all DNS records, including PTR, and information about which organization serves which service

```
./dhv.sh -d hoster.kz -dns
```

2. Get all DNS records as well as whois by main ip

```
./dhv.sh -d hoster.kz -dns -ip
```

3. Get all DNS records as well as whois by main ip

```
./dhv.sh -d hoster.kz -dns -ip
```

3. Get just Whois by domain

```
./dhv.sh -d hoster.kz -whois
```

4. Ping all hosts from a file in an infinite loop

```
./dhv.sh -ping ping_host.txt
```