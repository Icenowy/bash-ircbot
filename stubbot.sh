#! /bin/bash
if [ ! "$N" ]; then
	N=OveruseShell
fi
if [ ! "$C" ]; then
	C="##Orz"
fi

echo "Stub Bash IRC Bot Version M" >&2 
echo "I'm $N" >&2
echo "Target is $C" >&2

exec 3<>/dev/tcp/irc.freenode.net/6667
echo "User $N 8 * : $N" >&3
echo "Nick $N" >&3
# logined

stat=init

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
				stat=joined
			fi
			;;
		joined)
			# Insert dealing code here!
			if echo "$a" | grep -q "PRIVMSG $C.*$N"; then
				echo "PRIVMSG $C :I'm Stub Bash IRC Bot! Version M~" >&3
				echo "Accessed" >&2
			fi
			;;
		esac
	done
) &

cat >&3 # Write through
