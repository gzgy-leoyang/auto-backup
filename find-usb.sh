#!/bin/bash

usb_storage_path="/proc/scsi/"

declare -a usb_dev_list
declare -i usb_dev_counter

find_usb_device(){

    for usb_dev_file in `ls -l $usb_device_path`
    do
        if [ x"$usb_dev_file" != x"." -a x"$usb_dev_file" != x".." ];then
            if [ -d "$usb_device_path/$usb_dev_file/device/block" ];then
                echo "USB : $usb_device_path/$usb_dev_file/device/block"
                for sd_file in `ls $usb_device_path/$usb_dev_file/device/block`
                do
                    echo "sd*: $sd_file"
                    if [ -f "$usb_device_path/$usb_dev_file/device/block/$sd_file/removable" ];then
                        echo "sd*: removeable"
                        usb_dev_file[$usb_dev_counter]="$sd_file"
                        ((usb_dev_counter=usb_dev_counter+1))
                    fi
                done
            fi
        fi
    done
    return 
}


find_usb_storage(){

    if [ -d "$usb_storage_path/usb-storage" ];then
        echo "Found usb-storage"
        find_usb_device
        # return
    else
        echo "No usb-device"
    fi  

    return 
}

usb_device_path="/sys/class/scsi_device"


find_usb_storage 
