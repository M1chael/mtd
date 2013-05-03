#!/bin/bash 
# collect referers
wget -qO- http://rutracker.org/forum/viewtopic.php?t=3242662 --load-cookies rt.cookie | grep \<a\ href\=\"http\:\/\/rutracker\.org\/forum\/viewtopic\.php\?t\=[^\"]*\"\ class=\"postLink\" -o | grep http:\/\/[^\"]* -o > referers
# collect links on torrents
cat referers | sed 's/[^=]*=\([0-9]*\)/http\:\/\/dl\.rutracker\.org\/forum\/dl\.php\?t=\1/' > links
# collect POST parameters
cat links | sed 's/[^=]*=\([0-9]*\)/\1/' > posts

# making referers array
i=0
while read line; do
	referers[$i]="$line"
	i=$(($i+1))
done < referers

# making links array
i=0
while read line; do
	links[$i]="$line"
	i=$(($i+1))
done < links

# making posts array
i=0
while read line; do
	posts[$i]="$line"
	i=$(($i+1))
done < posts

# downloading torrents
for ((i=0; i<${#links[*]}; i++))
do
	wget "${links[$i]}" -P ./torrents/ --load-cookies rt.cookie --referer="${referers[$i]}" --header="Content-Type: application/x-www-form-urlencoded" --post-data="t=${posts[$i]}"
done

#transmission-remote 192.168.1.12:9091 --auth=user:pa\$\$w0rd -a ./torrents/* - not working for me
# starting downloads on remote transmission
find ./torrents/ -name dl.* -exec transmission-remote 192.168.1.12:9091 --auth=user:pa\$\$w0rd -a {} \;