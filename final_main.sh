#!/bin/bash
# Define colors
BOLD='\033[1m'
RESET='\033[0m'
RED='\033[0;31m'
GREEN='\033[0;32m'
CYAN='\033[0;36m'
YELLOW='\033[0;33m'
MAGENTA='\033[0;35m'
BLUE='\033[0;34m'
homedir="$HOME/address_database"
logfile="$homedir/log.txt"
database="$homedir/database.csv"
entrytime=20 #if user didn't give input for input, it will go to the main menu

function checkEnvironment() {
    echo -e "${CYAN}${BOLD}Checking environment...${RESET}"
    log "User Entered the application"
    if [ ! -d $homedir ]; then
        mkdir -p $homedir
        log "Created directory: $homedir"
    fi

    if [ ! -f $database ]; then
        touch $database
        log "Created database file: $database"
    fi

    if [ ! -f $logfile ]; then
        touch $logfile
        log "Created log file: $logfile"
    fi

    if [ ! -s $database ]; then
        echo -e "${YELLOW}${BOLD}The database is empty.${RESET}"
    fi
}

function log() {
    local msg=$1
    echo "$(date) - $msg" >>$logfile
}

function main_menu() {
    while true; do
        clear
        echo -e "${BLUE}${BOLD}*********************************************************${RESET}"
        echo -e "${GREEN}${BOLD}*              WELCOME TO ADDRESS DATABASE              *${RESET}"
        echo -e "${BLUE}${BOLD}*********************************************************${RESET}"
        echo
        echo -e "${CYAN}${BOLD}1) Add an Entry${RESET}"
        echo -e "${YELLOW}${BOLD}2) Search / Edit an Entry${RESET}"
        echo -e "${RED}${BOLD}3) Exit${RESET}"
        read -p "$(echo -e "${MAGENTA}${BOLD}Enter your choice: ${RESET}")" choice
        case $choice in
        1) add_entry ;;
        2) search_edit ;;
        3) log "User exited the application"
            exit 0
           
 ;;
        *)echo -e "${RED}${BOLD}Enter a valid choice. Try again...${RESET}"
            sleep 1.5
            ;;
        esac
    done
}

function add_entry() {
    echo -e "${MAGENTA}${BOLD}*************************************************${RESET}"
    echo -e "${GREEN}${BOLD}----------------ADD YOUR ENTRY-------------------${RESET}"
    echo -e "${MAGENTA}${BOLD}*************************************************${RESET}"
    
    # Enter and validate name
    read -t $entrytime -p "$(echo -e "${CYAN}${BOLD}Enter Name (alphabets and spaces only): ${RESET}")" name
    if [ $? -ne 0 ]; then
        echo -e "${RED}${BOLD}User Timed-out Returning to Main Menu.${RESET}"
        log "User Timed-out while Entering Name"
        sleep 2
        return
    fi

    # Trim and capitalize the input
    name=$(echo "$name" | xargs | sed 's/.*/\L&/; s/[a-z]*/\u&/g')

    # Validation for name

    if ! [[ "$name" =~ ^[a-zA-Z[:space:]]+$  ]]; then
        echo -e "${RED}${BOLD}Invalid Name. Only alphabets and spaces allowed.${RESET}"
        log "Invalid Name input: $name"
        sleep 2
        return
    fi
    # Enter and validate email
    read -t $entrytime -p "$(echo -e "${CYAN}${BOLD}Enter Email: ${RESET}")" email
    if [ $? -ne 0 ]; then
        echo -e "${RED}${BOLD}Timed out! Returning to menu.${RESET}"
        log "User timed out while adding Email."
        sleep 2
        return
    fi

    if ! [[ "$email" =~ ^[a-zA-Z0-9._]+@[a-zA-Z0-9]+\.[a-zA-Z]{2,}$ ]]; then
        echo -e "${RED}${BOLD}Invalid Email format ! Returning to menu.${RESET}"
        log "Invalid Email input: $email"
        sleep 2
        return
    fi

    # Enter and validate telephone
    read -t $entrytime -p "$(echo -e "${CYAN}${BOLD}Enter Telephone Number (numbers only): ${RESET}")" telephone
    if [ $? -ne 0 ]; then
        echo -e "${RED}${BOLD}Timed out! Returning to menu.${RESET}"
        log "User timed out while adding Telephone Number."
        sleep 2
        return
    fi

    if ! [[ "$telephone" =~ ^[0-9]+$ ]]; then
        echo -e "${RED}${BOLD}Invalid Telephone Number. Only numbers allowed. ${RESET}"
        log "Invalid Telephone Number input: $telephone"
        sleep 2
        return
    fi

    # Enter and validate mobile
    read -t $entrytime -p "$(echo -e "${CYAN}${BOLD}Enter Mobile Number (10 digits only): ${RESET}")" mobile
    if [ $? -ne 0 ]; then
        echo -e "${RED}${BOLD}Timed out! Returning to menu.${RESET}"
        log "User timed out while adding Mobile Number."
        sleep 2
        return
    fi

    if ! [[ "$mobile" =~ ^[0-9]{10}$ ]]; then
        echo -e "${RED}${BOLD}Invalid Mobile Number. Only 10-digit numbers allowed.${RESET}"
        log "Invalid Mobile Number input: $mobile"
        sleep 2
        return
    fi

    mobile="+91 $mobile"

    # Enter and validate address
    read -t $entrytime -p "$(echo -e "${CYAN}${BOLD}Enter Address (alphabets, numbers, and spaces only): ${RESET}")" address
    if [ $? -ne 0 ]; then
        echo -e "${RED}${BOLD}Timed out! Returning to menu.${RESET}"
        log "User timed out while adding Address."
        sleep 2
        return
    fi

    # Trim and capitalize address input
    address=$(echo "$address" | xargs | sed 's/.*/\L&/; s/[a-z0-9]*/\u&/g')

    # Validation for address
    if ! [[ "$address" =~ ^[a-zA-Z[:space:]]+$  ]]; then
        echo -e "${RED}${BOLD}Invalid Address. Only alphabet,spaces  allowed.${RESET}"
        log "Invalid Address input: $address"
        sleep 2
        return
    fi

    read -t $entrytime -p "$(echo -e "${CYAN}${BOLD}Enter Message: ${RESET}")" message
    if [ $? -ne 0 ]; then
        echo -e "${RED}${BOLD}Timed out! Returning to menu.${RESET}"
        log "User timed out while adding Message."
        sleep 2
        return
    fi

    # Add the entry to the database
    entry="$name,$email,$telephone,$mobile,\"$address\",\"$message\",$(date)"
    echo $entry >>$database
    log "Added new entry: $entry"
    echo -e "${GREEN}${BOLD}Entry added successfully.${RESET}"
}

function search_edit() {
    echo -e "${YELLOW}${BOLD}****************************************************${RESET}"
    echo -e "${GREEN}${BOLD}----------------SEARCH/EDIT ENTRY-------------------${RESET}"
    echo -e "${YELLOW}${BOLD}****************************************************${RESET}"
    echo
    read -t $entrytime -p "$(echo -e "${CYAN}${BOLD}Enter the name to be searched: ${RESET}")" searchname
    res=$(grep -i "^$searchname" "$database")
    if [ -z "$res" ]; then
        echo -e "${RED}${BOLD}No Matching entry found.... Redirecting to main menu.${RESET}"
        log "Search failed for name: $searchname"
        sleep 2
        return
    fi
    echo -e "${GREEN}${BOLD}Matching entry:${RESET}"
    echo "$res"
    read -p "$(echo -e "${CYAN}${BOLD}Do you want to edit this entry? (y/n): ${RESET}")" choice
    if [ "$choice" == "y" ]; then
        local tempfile=$(mktemp)
        grep -v -i "^$searchname" "$database" >"$tempfile"
        mv $tempfile $database
        log "Deleted entry for editing: $res"
        echo -e "${CYAN}${BOLD}Re-enter details for the edited entry -> Redirecting to add entry menu${RESET}"
        sleep 2
	add_entry
    fi
}

checkEnvironment
main_menu
