#!/bin/bash

########################################
####     the100.io Grimoire v2.3    ####
####  Calls Bungie API to get grim  ####
#### 	  the100:  /u/L0r3          ####
####      Reddit:  /u/L0r3_Titan    ####
####      Twitter: @L0r3_Titan      ####
########################################

clear

#### NUMBER AND NAME OF A GRIM CARD ####
currentCard='603010,raidCompletions'

#### INCLUDE FILE WITH YOUR BUNGIE API KEY ####
source ${BASH_SOURCE[0]/%grimScores.sh/apiKey.sh}
source ${BASH_SOURCE[0]/%grimScores.sh/hundredMembers.sh}

#### SEPRATE GRIM CARD ID AND NAME ####
grimID=`echo $currentCard | sed 's/,.*[^,]*//'`
grimName=`echo $currentCard | rev | sed 's/,.*[^,]*//' | rev`

#######################################
#### BEGIN 100 MEMBER LIST SECTION ####
#######################################

hundredMembers
# outputs data to /tmp/100_users.txt
# outputs data to /tmp/100_usersClean.txt

#####################################
#### END 100 MEMBER LIST SECTION ####
#####################################

selectedAccountType='1'
playerList="/tmp/100_usersClean.txt"
echo


### MEMBER ID ###
funcMemID ()
{
getUser=`curl -s -X GET \
-H "Content-Type: application/json" -H "Accept: application/xml" -H "$authKey" \
"http://www.bungie.net/Platform/Destiny/SearchDestinyPlayer/$selectedAccountType/$player/"`
memID=`echo "$getUser" | grep -o 'membershipId.*' | cut -c 16- | sed 's/displayName.*[^displayName]*//' | rev | cut -c 4- | rev`
#echo "$player: $memID"
}

funcGrimAll ()
{
grimAll=`curl -s -X GET \
-H "Content-Type: application/json" -H "Accept: application/xml" -H "$authKey" \
"https://www.bungie.net/Platform/Destiny/Vanguard/Grimoire/$selectedAccountType/$memID/"`
#echo "grimAll: $grimAll"
}

let playerCnt='0'

while read 'player'; do
	funcMemID
	funcGrimAll
	grimCurrent=`echo "$grimAll" | grep -o 'score":.*'| sed 's/cardCollection.*[^cardCollection]*//' | cut -c 8- | rev | cut -c 3- | rev`
	scorePlayer="$grimCurrent,$player"
	echo "echo out the progress here"
	let playerCnt=playerCnt+1
	grimArr[$playerCnt]="$scorePlayer"
done < "$playerList"


function arrSort 
{ for i in ${grimArr[@]}; do echo "$i"; done | sort -n -r -s ; }


grimScoresSort=( $(arrSort) )
printf '%s\n' "${grimScoresSort[@]}"


exit



