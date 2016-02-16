#! /bin/bash
if [ ! "$N" ]; then
	N=orznzbot
fi
if [ ! "$C" ]; then
	if [ ! -d .git ]; then
		C="##Orz"
	elif LC_ALL=C git status | grep -q "nothing to commit"; then
		C="##Orz"
	else
		C="##icenowy"
	fi
fi

V="Mo"

echo "##Orz Nvzhuang IRC Bot Version $V" >&2 
echo "I'm $N" >&2
echo "Target is $C" >&2

exec 3<>/dev/tcp/irc.freenode.net/6667
echo "User $N 8 * : $N" >&3
echo "Nick $N" >&3
# logined

# String table

PONGINFO="pong! All guys in ##Orz will have girl's clothes clothed! I'm version $V~"
NZSTR="%s 快女装！"
NZZSTR="%s 这家伙还没有登记过的女装照。"

stat=init

send() {
	echo "PRIVMSG $C :$*" >&3
	echo "PRIVMSG $C :$*" >&2
}

get_command() {
	echo "$1" | grep -q "PRIVMSG $C.*'$2@$N[ ]"
}

sec_mask() {
	sed 's/\*/_/g' | sed 's/\?/_/g' | sed 's/\[/【/g' | sed 's/\]/】/g'
}

get_paramaters() {
	echo "$1" | sed "s/^.*PRIVMSG $C.*'$2@$N[ ]//g" | sed 's/^ //g' | sed 's///g' | sec_mask
}

nz(){
	local ok
	ok=0
	[ -e special_response_list ] && 
	for i in $(cat special_response_list); do
		if echo "$*" | grep -q $i; then
			[ ! -e "special_response_item_$(echo $i | base64)" ] ||
			send "$(cat "special_response_item_$(echo $i | base64)")"
			ok=1
			break
		fi
	done
	if [ "$ok" = "0" ]; then
		send "$(printf "$NZSTR" "$*")"
	fi
}

regnz(){
	local i
	i=$1
	echo $1 >> special_response_list
	shift
	echo "$*" > "special_response_item_$(echo $i | base64)"
	send "Registered $i for $*"
}

nzz(){
	local ok
	ok=0
	[ -e picture_list ] && 
	for i in $(cat picture_list); do
		if echo "$*" | grep -q $i; then
			[ ! -e "picture_item_$(echo $i | base64)" ] ||
			send "$(cat "picture_item_$(echo $i | base64)")"
			ok=1
			break
		fi
	done
	if [ "$ok" = "0" ]; then
		send "$(printf "$NZZSTR" "$*")"
	fi
}

regnzz(){
	local i
	i=$1
	shift
	echo $i >> picture_list
	echo "$*" > "picture_item_$(echo $i | base64)"
	send "Registered $i for $*"
}

# message dealer
(
	while read a <&3; do
		[ "$(echo $a | cut -c 1-6)" = "PING :" ] && echo $a >&3
		echo "$a" >&2
		case $stat in
		init)
			if echo "$a" | grep -q '^:.*\.freenode\.net.*'"$N"' :End of /MOTD command.$'; then
				echo "JOIN $C" >&2
				echo "JOIN $C" >&3
				stat=joining
			fi
			;;
		joining)
			if echo "$a" | grep -q "^:$N\!.* JOIN $C"; then
				echo "JOINED $C" >&2
				stat=joined
			fi
			;;
		joined)
			# Insert dealing code here!
			if get_command "$a" ping; then
				send "$PONGINFO"
				param="$(get_paramaters "$a" ping)"
				[ "$param" != "" ] && send "$param"
			fi
			if get_command "$a" nz; then
				param="$(get_paramaters "$a" nz)"
				nz $param
			fi
			if get_command "$a" regnz; then
				param="$(get_paramaters "$a" regnz)"
				regnz $param
			fi
			if get_command "$a" nzz; then
				param="$(get_paramaters "$a" nzz)"
				nzz $param
			fi
			if get_command "$a" regnzz; then
				param="$(get_paramaters "$a" regnzz)"
				regnzz $param
			fi
			;;
		esac
	done
) &

cat >&3 # Write through
