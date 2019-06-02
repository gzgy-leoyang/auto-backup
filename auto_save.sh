#!/bin/bash

WORKING="/home/dd/Working"
BACKUP="/home/dd/Working_1"

# WORKING="/home/dd/Working"
# BACKUP="/media/dd/dd-udisk/Working"

declare -a Refresh_list # refresh file list
declare -a Add_list     # add file list

declare -i add_new_file refresh_file add_new_dir loop

add_new_file=0
refresh_file=0
add_new_dir=0
loop=0

# 空格表
string='                                            '

find_new_file(){
    local working_path="$1"
    local backup_path="$2"
    local file2=""

    # 列出所有文件，逐一加入 file2 中进行处理
    # for file2 in `ls -a $working_path`
    for file2 in `ls -l $working_path`
    do        
        if [ x"$file2" != x"." -a x"$file2" != x".." ];then
            # 首先，判断是否是 dir，如果是 dir，则递归调用本函数 
            if [ -d "$working_path/$file2" ];then
                # if [ "$file2" != ".git" ];then
                if [[ "$file2" != ".git" && "$file2" != ".settings" && "$file2" != ".vscode" && "$file2" != "Debug" ]];then
                    if [ ! -d "$backup_path/$file2" ];then
                        mkdir -p "$backup_path/$file2"
                        ((add_new_dir=add_new_dir+1))    
                        echo -e "\033[1;36;40m${string:0:$loop}|--<$file2> +\033[0m"
                    else
                        echo -e "\033[1;30;40m${string:0:$loop}|--<$file2>\033[0m"
                    fi
                    working_path="$working_path"
                    backup_path="$backup_path"
                    
                    ((loop=$loop+3))
                    find_new_file "$working_path/$file2" "$backup_path/$file2"
                    ((loop=$loop-3))
                fi
            else
                if [ -f "$working_path/$file2" ];then
                    local type=${file2##*.}
                    # if [[ "$type" == "c" || "$type" == "cpp" || "$type" == "qml" || "$type" == "h"  || "$type" == "xml" || "$type" == "png"  ]];then
                        if [ -f "$backup_path/$file2" ];then
                            if [ "$working_path/$file2" -nt "$backup_path/$file2" ];then
                                # Refresh
                                echo -e "\033[1;31;40m${string:0:$loop}|--$file2 *\033[0m"
                                cp "$working_path/$file2" "$backup_path/$file2"
                                ((refresh_file=refresh_file+1))
                                Refresh_list[$refresh_file]=$working_path/$file2
                            else
                                # dont need refresh
                                echo -e "\033[1;30;40m${string:0:$loop}|--$file2\033[0m"
                            fi
                        else
                            # Add
                            echo -e "\033[1;36;40m${string:0:$loop}|--$file2 +\033[0m" 
                            cp "$working_path/$file2" "$backup_path/"
                            ((add_new_file=add_new_file+1))
                            Add_list[$add_new_file]=$working_path/$file2
                        fi                
                    # fi
                fi
            fi  
        fi  
    done
    return 
}

echo "Auto backup V1.0 2019/05/30"
read -p "[$WORKING] --> [$BACKUP] (yes/no) :" confirm

if [[ "$confirm" == "yes" || "$confirm" == "y" ]];then
    find_new_file "$WORKING" "$BACKUP"
else
    read -p "type SOURCE path: " WORKING    
    read -p "type BACKUP path: " BACKUP

    find_new_file "$WORKING" "$BACKUP"
fi
# find_new_file "$WORKING" "$BACKUP"

echo "======================="
echo -e "\033[1;31;40mRefersh   files(*):$refresh_file\033[0m"
for i in ${Refresh_list[@]}
do
    echo $i
done

# add files
echo -e "\033[1;36;40mAdd new   files(+):$add_new_file\033[0m"
for i in ${Add_list[@]}
do
    echo $i
done
echo "======================="
########
sync
sync
echo SYNC
# umount /dev/sda1
echo UMOUNT...
# sudo eject /dev/sda
echo SAFELEY REMOVE UDISK