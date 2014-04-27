#!/bin/bash

# JSON function to fetch the needed parameters from JSON string
function JSONfinder {
    temp=`echo $json | sed 's/\\\\\//\//g' | sed 's/[{}]//g' | awk -v k="text" '{n=split($0,a,","); for (i=1; i<=n; i++) print a[i]}' | sed 's/\"\:\"/\|/g' | sed 's/[\,]/ /g' | sed 's/\"//g' | grep -w $prop`
   
    str=${temp##*|}
    str2=${str#"]"}
		str2=${str2%"]"}
		groupId=$str2
    echo $str2
}

# function to fetch userId from user profile name 
function get_ID_value_for_FB_User {

	json=`curl -s -X GET http://graph.facebook.com/$userId`
	prop='id'
	JSONfinder
}

# function to fetch userId from user profile name 
function get_Full_Name_of_FB_User {

	json=`curl -s -X GET http://graph.facebook.com/$userName`
	prop='name'
	JSONfinder
}

# function to fetch userId from user profile name 
function get_ID_value_for_FB_Group {

	json=`curl -s -X GET "https://graph.facebook.com/search?q=$groupName&type=group&access_token=$tokenId"`
	prop='id'
	JSONfinder
}

# function to fetch the members of any group using groupID
function fetch_group_members {

	get_ID_value_for_FB_Group
	members=`curl -s -X GET "https://graph.facebook.com/$groupId/members?access_token=$tokenId"`
	echo "$members" > fb_members.txt
	echo "Members exported.."
}

# function to fetch the members of any group using groupID
function fetch_group_feeds {

	get_ID_value_for_FB_Group
	feeds=`curl -s -X GET "https://graph.facebook.com/$groupId/feed?access_token=$tokenId"`
	echo "$feeds" > fb_feeds.txt
	echo "feeds exported.."
}

# Public variables.
var="$1dummy"
main_script_err="usage: $0 -type [user (-i id or -n nickname) | group (-n name) -f|-m (f for feeds, m for members) (-t token)].
Examples: 
User: ./facebook.sh -type user -n john_smith
Group: ./facebook.sh -type group -n cosmology -f -t segertgkfgwlegekntewkrmewrew"

# Script inputs parameters
if [ $var == "dummy" ]; then 
	  echo  "$main_script_err"
else

if [ $1 == "-type" ]; then
		command="l$2"
				if [ $command == "luser" ]; then
							if [ "$3dummy" != "dummy" ] && [ "$4dummy" != "dummy" ]; then 
                  if [ $3 == "-n" ]; then 
											userId=$4
											get_ID_value_for_FB_User
									elif [ $3 == "-i" ]; then
											userName=$4
											get_Full_Name_of_FB_User
								 	else
										echo "$main_script_err"
									fi
							else
								echo "$main_script_err"
							fi
				else
							if [ $command == "lgroup" ] ; then
									if [ "$3dummy" != "dummy" ] && [ $3 == "-n" ] && [ $6 == "-t" ] && [ "$7dummy" != "dummy" ]; then 
											if [ $5 == "-m" ]; then
													groupName=$4
													tokenId=$7
													fetch_group_members
											elif [ $5 == "-f" ]; then
													groupName=$4
													tokenId=$7
													fetch_group_feeds
											else 
											echo >&2 \
											
											fi
									else
										echo "$main_script_err"
									fi
               else
                    echo "$main_script_err"
               fi
        fi
 else
			echo "$main_script_err"
fi
fi
