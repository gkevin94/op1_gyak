#!/bin/sh

szotar="./magyar_szavak.txt"
empty="\."
jatekok=0


echo  "*********  Akasztófa  *********"
echo "A játék lényege, hogy kitaláljuk a gép által véletlenszerűen választott magyar szót."


if [ ! -r $szotar ] ; then
 echo "$0: Hiányzó szótár $szotar" >&2
 exit 1
fi

while [ "$tipp" != "KILÉPÉS" ] ; do
	talalat="$(cat $szotar | sort --random-sort | head -n 1)"
	
	if [ $jatekok -gt 0 ] ; then
		echo ""
		echo "*** Új játék! ***"
	fi
	
	jatekok="$(( $jatekok + 1 ))"
	tippelt=""  ; tipp="" ; hiba=${1:-10}
	resz="$(echo $talalat | sed "s/[^$empty${tippelt}]/-/g")"
	
	while [ "$tipp" != "$talalat" -a "$tipp" != "KILÉPÉS" ] ; do
		echo ""
		if [ ! -z "$tippelt" ] ; then
			echo -n "tippelt: $tippelt, "
		fi
		echo "ennyi lépés van még hátra: $hiba, a szó eddig: $resz"
		echo "segítséghez írja be hogy \"help\", kilpéshez pedig hogy \"kilépés\""
  
		echo -n "Írjon be egy betűt: "
		read tipp
		echo ""
  
		tipp=$(echo $tipp | gawk '{print toupper($0)}')
		if [ "$tipp" = "$talalat" ] ; then
			echo "Pontosan ez a keresett szó!"
		elif [ "$tipp" = "HELP" ] ; then
			hossz=${#talalat}
			echo $talalat | cut -c1-$((hossz / 2))
		elif [ "$tipp" = "KILÉPÉS" ] ; then
			sleep 0
		elif [ -z "$(echo $tipp | sed "s/[$empty$tippelt]//g")" ] ; then
			echo "Már próbálta: $tipp"
		elif [ "$(echo $talalat | sed "s/$tipp/-/g")" != "$talalat" ] ; then
			tippelt="$tippelt$tipp"
			resz="$(echo $talalat | sed "s/[^$empty${tippelt}]/-/g")"
			if [ "$resz" = "$talalat" ] ; then
				echo "** Gratulálok! A szó: \"$talalat\"."
				tipp="$talalat"
			else
				echo "* Szuper, \"$tipp\" benne van a szóban!"
			fi
		elif [ $hiba -eq 1 ] ; then
			echo "** A jáétéknak vége, nincs több lehetőség!"
			echo "** A kitalálandó szó \"${talalat}\" volt."
			tipp="$talalat"
		else
			echo "*Nem jó, \"$tipp\" nincs benne."
			tippelt="$tippelt$tipp"
			hiba=$(( $hiba - 1 ))
		fi
	done
done
exit 0