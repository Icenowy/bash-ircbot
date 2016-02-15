#! /bin/bash
if [ ! "$N" ]; then
	N=OveruseShell
fi
if [ ! "$C" ]; then
	C="##Orz"
fi

V="Mo"

echo "Stub Bash IRC Bot Version $V" >&2 
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
			if echo "$a" | grep -q "PRIVMSG $C.*$N"; then
				echo "PRIVMSG $C :I'm Stub Bash IRC Bot! Version $V~" >&3
				echo "Got request" >&2
			fi
			;;
		esac
	done
) &

cat >&3 # Write through
