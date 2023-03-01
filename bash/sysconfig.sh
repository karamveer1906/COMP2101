#!/bin/bash
# this script displays system information

# TASK: This script produces a report. It does not communicate errors or deal with the user pressing ^C
#       Create the 4 functions described in the comments for
#         help display
#         error message display (2 of these)
#         temporary files cleanup to be used with interrupts
#       Create a trap command to attach your interrupt handling function to the signal that will be received if the user presses ^C while the script is running

# Start of section to be done for TASK
# This is where your changes will go for this TASK
#Starting Task 1
#Help Display Function
display_help() {
    echo "This script performs some task."
    echo "Use the following options:"
    echo "-i <input file>  Specify input file"
    echo "-o <output file>  Specify output file"
    echo "-h  Show this help message"
}

# Error message display function
display_error() {
    echo "Error: $1"
}

# Error message and exit function
display_error_and_exit() {
    display_error "$1"
    exit 1
}

# Temporary files cleanup function
cleanup_temp_files() {
    rm -f "$@"
}
# Trap function for interrupt signals
interrupt_handler() {
    echo "Interrupt signal received. Cleaning up temporary files and exiting."
    cleanup_temp_files "$temp_file"
    exit 1
}

# Attach interrupt handler to SIGINT signal (Ctrl-C)
trap interrupt_handler SIGINT
# Main script code
temp_file="temp.txt"

# Display help message if requested
if [[ $1 == "-h" ]]; then
    display_help
    exit 0
fi

# Perform task with input and output files if specified
if [[ $1 == "-i" && $2 != "" && $3 == "-o" && $4 != "" ]]; then
    input_file=$2
    output_file=$4
    # Perform task here
else
    display_error_and_exit "Invalid arguments. Use -h for help."
fi

# Clean up temporary files at end of script
cleanup_temp_files "$temp_file"


# End of section to be done for TASK
# Remainder of script does not require any modification, but may need to be examined in order to create the functions for TASK

# DO NOT MODIFY ANYTHING BELOW THIS LINE

#This function produces the network configuration for our report
function getipinfo {
  # reuse our netid.sh script from lab 4
  netid.sh
}

# process command line options
partialreport=
while [ $# -gt 0 ]; do
  case "$1" in
    -h|--help)
      displayhelp
      error-exit
      ;;
    --host)
      hostnamewanted=true
      partialreport=true
      ;;
    --domain)
      domainnamewanted=true
      partialreport=true
      ;;
    --ipconfig)
      ipinfowanted=true
      partialreport=true
      ;;
    --os)
      osinfowanted=true
      partialreport=true
      ;;
    --cpu)
      cpuinfowanted=true
      partialreport=true
      ;;
    --memory)
      memoryinfowanted=true
      partialreport=true
      ;;
    --disk)
      diskinfowanted=true
      partialreport=true
      ;;
    --printer)
      printerinfowanted=true
      partialreport=true
      ;;
    *)
      error-exit "$1 is invalid"
      ;;
  esac
  shift
done

# gather data into temporary files to reduce time spent running lshw
sudo lshw -class system >/tmp/sysinfo.$$ 2>/dev/null
sudo lshw -class memory >/tmp/memoryinfo.$$ 2>/dev/null
sudo lshw -class bus >/tmp/businfo.$$ 2>/dev/null
sudo lshw -class cpu >/tmp/cpuinfo.$$ 2>/dev/null

# extract the specific data items into variables
systemproduct=`sed -n '/product:/s/ *product: //p' /tmp/sysinfo.$$`
systemwidth=`sed -n '/width:/s/ *width: //p' /tmp/sysinfo.$$`
systemmotherboard=`sed -n '/product:/s/ *product: //p' /tmp/businfo.$$|head -1`
systembiosvendor=`sed -n '/vendor:/s/ *vendor: //p' /tmp/memoryinfo.$$|head -1`
systembiosversion=`sed -n '/version:/s/ *version: //p' /tmp/memoryinfo.$$|head -1`
systemcpuvendor=`sed -n '/vendor:/s/ *vendor: //p' /tmp/cpuinfo.$$|head -1`
systemcpuproduct=`sed -n '/product:/s/ *product: //p' /tmp/cpuinfo.$$|head -1`
systemcpuspeed=`sed -n '/size:/s/ *size: //p' /tmp/cpuinfo.$$|head -1`
systemcpucores=`sed -n '/configuration:/s/ *configuration:.*cores=//p' /tmp/cpuinfo.$$|head -1`

# gather the remaining data needed
sysname=`hostname`
domainname=`hostname -d`
osname=`sed -n -e '/^NAME=/s/^NAME="\(.*\)"$/\1/p' /etc/os-release`
osversion=`sed -n -e '/^VERSION=/s/^VERSION="\(.*\)"$/\1/p' /etc/os-release`
memoryinfo=`sudo lshw -class memory|sed -e 1,/bank/d -e '/cache/,$d' |egrep 'size|description'|grep -v empty`
ipinfo=`getipinfo`
diskusage=`df -h -t ext4`
printerlist="`lpstat -e`
Default printer: `lpstat -d|cut -d : -f 2`"

# create output

[[ (! "$partialreport" || "$hostnamewanted") && "$sysname" ]] &&
  echo "Hostname:     $sysname" >/tmp/sysreport.$$
[[ (! "$partialreport" || "$domainnamewanted") && "$domainname" ]] &&
  echo "Domainname:   $domainname" >>/tmp/sysreport.$$
[[ (! "$partialreport" || "$osinfowanted") && "$osname" && "$osversion" ]] &&
  echo "OS:           $osname $osversion" >>/tmp/sysreport.$$
[[ ! "$partialreport" || "$cpuinfowanted" ]] &&
  echo "System:       $systemproduct ($systemwidth)
Motherboard:  $systemmotherboard
BIOS:         $systembiosvendor $systembiosversion
CPU:          $systemcpuproduct from $systemcpuvendor
CPU config:   $systemcpuspeed with $systemcpucores core(s) enabled" >>/tmp/sysreport.$$
[[ (! "$partialreport" || "$memoryinfowanted") && "$memoryinfo" ]] &&
  echo "RAM installed:
$memoryinfo" >>/tmp/sysreport.$$
[[ (! "$partialreport" || "$diskinfowanted") && "$diskusage" ]] &&
  echo "Disk Usage:
$diskusage" >>/tmp/sysreport.$$
[[ (! "$partialreport" || "$printerinfowanted") && "$printerlist" ]] &&
  echo "Printer(s):
$printerlist" >>/tmp/sysreport.$$
[[ (! "$partialreport" || "$ipinfowanted") && "$ipinfo" ]] &&
  echo "IP Configuration:" >>/tmp/sysreport.$$ &&
  echo "$ipinfo" >> /tmp/sysreport.$$

cat /tmp/sysreport.$$

# cleanup temporary files
cleanup
