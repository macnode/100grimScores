#!/bin/bash

########################################
####     the100.io Grimoire v3.1    ####
####   Call the100 API get members  ####
####   Call Bungie API get grim     ####
#### 	  the100:  /u/L0r3          ####
####      Reddit:  /u/L0r3_Titan    ####
####      Twitter: @L0r3_Titan      ####
########################################

clear

#### NUMBER AND NAME OF GRIM CARD ####
currentCard='603010,raidCompletions'

#### INCLUDE FILE WITH YOUR BUNGIE API KEY ####
source ${BASH_SOURCE[0]/%grimScores.sh/apiKeys.sh}
source ${BASH_SOURCE[0]/%grimScores.sh/hundredMembers.sh}

#### SEPRATE GRIM CARD ID AND NAME ####
grimID=`echo $currentCard | sed 's/,.*[^,]*//'`
grimName=`echo $currentCard | rev | sed 's/,.*[^,]*//' | rev`

#### XBOX OR PSN ####
selectedAccountType='1'

#### CALL FUNCTION TO GET THE100 GROUP MEMBERS ####
hundredMembers

#### FUCTION TO SEND GAMERTAG TO BUNGIE TO GET MEMBER ID ####
funcMemID ()
{
getUser=`curl -s -X GET \
-H "Content-Type: application/json" -H "Accept: application/xml" -H "$authKeyBungie" \
"https://www.bungie.net/Platform/Destiny/SearchDestinyPlayer/$selectedAccountType/$player/"`
memID=`echo "$getUser" | grep -o 'membershipId.*' | cut -c 16- | sed 's/displayName.*[^displayName]*//' | rev | cut -c 4- | rev`
#echo "$player: $memID"
}

#### FUNCTION TO GET ALL GRIM FOR EACH PLAYER ####
funcGrimAll ()
{
grimAll=`curl -s -X GET \
-H "Content-Type: application/json" -H "Accept: application/xml" -H "$authKeyBungie" \
"https://www.bungie.net/Platform/Destiny/Vanguard/Grimoire/$selectedAccountType/$memID/"`
#echo "grimAll: $grimAll"
}

#### LOOP THROUGH MEMBERS TO GET SCORES FROM BUNGIE ####
echo; echo "#### GET RESULTS FROM BUNGIE ####"
let playerCnt='0'
while [ "$playerCnt" -lt "$totalMembers" ]; do
	player=`echo "${arrMembers[$playerCnt]}"`
	funcMemID
	funcGrimAll
	grimCurrent=`echo "$grimAll" | grep -o 'score":.*'| sed 's/cardCollection.*[^cardCollection]*//' | cut -c 8- | rev | cut -c 3- | rev`
	scorePlayer="$grimCurrent,$player"
	echo "$scorePlayer"
	let playerCnt=playerCnt+1
	grimArr[$playerCnt]="$scorePlayer"
done


#### SORT SCORES HIGHEST TO LOWEST ####
function arrSort 
{ for i in ${grimArr[@]}; do echo "$i"; done | sort -n -r -s ; }
grimScoresSort=( $(arrSort) )

sortList=`printf '%s\n' "${grimScoresSort[@]}" | sed 's/,/ /g' | sed 's/%20/ /g'`

echo; echo "#### SORTED CLEAN LIST ####"
echo "$sortList"

echo; echo
exit
