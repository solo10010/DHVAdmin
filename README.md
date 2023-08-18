
![logo](https://raw.githubusercontent.com/solo10010/trash/main/static/image/dahua.png "DHVAdmin Logo")

# DESCRIPTION

DHVAdmin (Dohua Hosting Viewer Administrator) - the creation of the utility was inspired by a utility called DomainHostingView, unfortunately not available for Linux, so this script was created, the script was created to help and quickly evaluate the domain of its DNS, or web server. usefulness is supposed to help the technical support of hostings, most fully and quickly evaluate problems with work, DNS sites and hosting servers in general.

# INSTALLATION

The utility requires some dependencies to work, if you do not have them, then install them through your package manager.

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
./dhv.sh -d oibai.ru -dns
```

2. Get all DNS records as well as whois by main ip

```
./dhv.sh -d oibai.ru -dns -ip
```

3. Get all DNS records as well as whois by main ip

```
./dhv.sh -d oibai.ru -dns -ip
```

3. Get just Whois by domain

```
./dhv.sh -d oibai.ru -whois
```

4. Ping all hosts from a file in an infinite loop

```
./dhv.sh -ping ping_host.txt
```

5. Check all redirects to domain until status 200OK

```
./dhv.sh -d oibai.ru -redirect
```
