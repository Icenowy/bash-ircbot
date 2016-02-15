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

V="M"

echo "##Orz Nvzhuang IRC Bot Version $V" >&2 
echo "I'm $N" >&2
echo "Target is $C" >&2

exec 3<>/dev/tcp/irc.freenode.net/6667
echo "User $N 8 * : $N" >&3
echo "Nick $N" >&3
# logined

stat=init

send() {
	echo "PRIVMSG $C :$*" >&3
	echo "PRIVMSG $C :$*" >&2
}

get_command() {
	echo "$1" | grep -q "PRIVMSG $C.*$2@$N"
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
				send "pong! All guys in ##Orz will have girl's clothes clothed! I'm version $V~"
			fi
			;;
		esac
	done
) &

cat >&3 # Write through
