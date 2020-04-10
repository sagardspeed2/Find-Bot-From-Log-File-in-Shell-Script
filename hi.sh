#!/bin/bash
count=0

previousUniqueTime='00:00:00'

previousUser=''
previousUserCount=0

actionCount=0

declare -a bots

while IFS= read -r line;
        do
		    uniqueTime=`echo $line | grep -oP [0-9]{2}:[0-9]{2}:[0-9]{2}`
            userid=`echo $line | cut -d '|' -f 3 | tr -d ' '`
            action=`echo $line | cut -d '|' -f 5 | sed -e 's/^ //' | sed -e 's/ $//'`

            # for checking time
            if [ $uniqueTime == $previousUniqueTime ]
            then
                ((count++))
            else
                count=0
            fi

            # for checking user
            if [ "$userid" == "$previousUser" ]
            then
                if [ "$action" == "user logged in" ]
                then
                    actionCount=0
                else
                    ((previousUserCount++))
                fi
            else
                previousUserCount=0
            fi

            # for checking action
            if [ $previousUserCount == 0 ]
            then
                if [ "$action" == "user logged in" ]
                then
                    actionCount=0
                fi
            fi

            # for checking action
            if [ $previousUserCount == 1 ]
            then
                if [ "$action" == "user changed password" ]
                then
                    ((actionCount++))
                else
                    actionCount=0
                fi
            fi

            # for checking action
            if [ $previousUserCount == 2 ]
            then
                if [ "$action" == "user logged off" ]
                then
                    ((actionCount++))
                else
                    actionCount=0
                fi
            fi

            # bot found
            if [ $count -ge 2 ]
            then
                if [ $previousUserCount -ge 2 ]
                then
                    if [ $actionCount == 2 ]
                    then
                        bots+=($userid)
                    fi
                fi
            fi

            previousUniqueTime=$uniqueTime
            previousUser=$userid
            
        done < log.txt

current_time=$(date "+%Y%m%d-%H%M%S")
for i in "${bots[@]}"
do
    echo $i
done >> output-$current_time.txt