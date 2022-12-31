#!/usr/bin/env bash
#===============================================================================
#
#  Get Terminal Size (v2.1.3)
#  ./getTermSize.sh
#
#  Created 2022-12-29.
#  Copyright (c) 2022 MATT DANIEL BROWN. ALL RIGHTS RESERVED.
#
#===============================================================================

####################
### SCRIPT START ###
####################

#———————————————————————————————————————————————————————————————————————————————
#---| Section [1] |-------------------------------------------------------------
#---| Variable Declaration & Definition |---------------------------------------
#———————————————————————————————————————————————————————————————————————————————

# [1.1] : Definitions —— Standard/universal script-utility variables
_SCRIPT_NAME="$(basename "${0}")"
_VERSION=2.1.3
_ARGSHIFT=1
_VERBOSE=

unset TERMINAL_WINDOW_WIDTH
unset TERMINAL_WINDOW_HEIGHT
unset TERMINAL_WINDOW_SIZE


#———————————————————————————————————————————————————————————————————————————————
#---| Section [2] |-------------------------------------------------------------
#---| Function Declaration & Definition |---------------------------------------
#———————————————————————————————————————————————————————————————————————————————

# [2.1] : Function (error) —— Print error message and exit with non-zero status
function error() {
  echo "${_SCRIPT_NAME}: $1" > /dev/stderr
  [ $# -gt 2 ] && eval "$2" && exit "$3"
  [ $# -gt 1 ] && exit "$2"
  exit 1
}

# [2.2] : Function (log) —— Print logged message
function log() {
	echo "${_SCRIPT_NAME}: $1" > /dev/stderr
}

# [2.3] : Function (debug) —— Print debug message when verbose mode is enabled
function debug() {
	[ "$_VERBOSE" ] && echo "${_SCRIPT_NAME}: $1" > /dev/stderr	
}

# [2.4] : Function (usage) —— Print the help/usage message text
function usage() {
	cat << EOF


  ${WHITE}${BOLD}NAME${RESET}
    ${GREEN}${BOLD}${_SCRIPT_NAME}${RESET}

  ${WHITE}${BOLD}VERSION${RESET}
    ${_VERSION}

  ${WHITE}${BOLD}DESCRIPTION${RESET}
    Get the width of the terminal window (in characters)

  ${WHITE}${BOLD}USAGE${RESET}
    ${GRAY}\$ ${GREEN}${_SCRIPT_NAME} ${RESET}


EOF
}

# [2.5] : Function (get_options) —— Parse options supplied by user
function get_options() {
	_SILENT=
  _OPTSTRING="VHhvw-:"
  while getopts "${_OPTSTRING}" _OPTION
	do
	case "${_OPTION}" in
    
    V)
      _ARGSHIFT="${OPTIND}"
      _VERBOSE=1
      ;;
      
    h) usage && exit 0;;
    v) echo "$_VERSION" && exit 0;;
		w) echo "$(tput cols)" && exit 0;;
		H) echo "$(tput lines)" && exit 0;;
    -)
      
      case "${OPTARG}" in
        help) usage && exit 0;;
        version) echo "$_VERSION" && exit 0;;
				width) echo "$(tput cols)" && exit 0;;
				height) echo "$(tput lines)" && exit 0;;
        verbose)
          _VERBOSE=1
          _ARGSHIFT="${OPTIND}"
          ;;
        esac;;
     
     \?)
        
        # VERBOSE MODE
        # invalid option: _OPTION is set to ? (question-mark) and OPTARG is unset
        # required argument not found: _OPTION is set to ? (question-mark), OPTARG is unset and an error message is printed
        [ -z "$_SILENT" ] && usage && exit 1
        
        # SILENT MODE
        # invalid option: _OPTION is set to ? (question-mark) and OPTARG is set to the (invalid) option character
        ### [ ! -z "$_SILENT" ] && echo "illegal option -- ${OPTARG}"
        [ -n "$_SILENT" ] && echo "illegal option -- ${OPTARG}"
        ;;
      :)
        # SILENT MODE
        # required argument not found: _OPTION is set to : (colon) and OPTARG contains the option-character in question
        echo "option requires an argument -- ${OPTARG}"
        ;;
    esac
  done
}

# [2.6] : Function (get_arguments) —— Parse arguments supplied by user
function get_arguments() {
  _ARGS="filename"
	
  shift $(( _ARGSHIFT - 1 ))

  for _ARG in $_ARGS
  do
    if [ -n "$1" ]; then
      eval "$_ARG=$1"
    fi
    shift
  done
}

function terminal_window_width {
	printf "$(tput cols)"
}
function terminal_window_height {
	printf "$(tput lines)"
}

function terminal_window_width_fallback {
	printf "$(stty -a | grep columns | sed 's/^.*;\(.*\)columns\(.*\);.*$/\1\2/' | sed 's/;.*$//' | sed 's/[^0-9]//g')"
}
function terminal_window_height_fallback {
	printf "$(stty -a | grep columns | sed 's/^.*;\(.*\)columns\(.*\);.*$/\1\2/' | sed 's/;.*$//' | sed 's/[^0-9]//g')"
}

function get_terminal_window_size {
	
	### [A] ----------------------------------------------------------------------
	### ... [ If `tput` is available ] <--> use it (it's the easy, reliable way)
	
	# Terminal window width 						... (~>) [e.g., *COLUMN* count]
	TERMINAL_WINDOW_WIDTH="$(tput cols)"
	
	# Terminal window height 						... (~>) [e.g., *LINE* or *ROW* count]
	TERMINAL_WINDOW_HEIGHT="$(tput lines)"
	
	
	
	### [B] ----------------------------------------------------------------------
	### ... [ But if not ] <--> do it the hard way (which *usually* works)
	
	# Terminal window height 					... (~>) [e.g., *COLUMN* count]
	TERMINAL_WINDOW_HEIGHT="$(stty -a | grep rows | sed 's/^.*;\(.*\)rows\(.*\);.*$/\1\2/' | sed 's/;.*$//' | sed 's/[^0-9]//g')"
	
	# Terminal window width 					... (~>) [e.g., *LINE* or *ROW* count]
	TERMINAL_WINDOW_WIDTH="$(stty -a | grep columns | sed 's/^.*;\(.*\)columns\(.*\);.*$/\1\2/' | sed 's/;.*$//' | sed 's/[^0-9]//g')"
	
}
function set_terminal_window_size {
	TERMINAL_WINDOW_WIDTH="$(tput cols)"
	TERMINAL_WINDOW_HEIGHT="$(tput lines)"
}

function print_terminal_height {
	printf "${TERMINAL_WINDOW_HEIGHT}\n"
}
function print_terminal_window_width_line {
	printf "${TERMINAL_WINDOW_WIDTH}\n"
}


#———————————————————————————————————————————————————————————————————————————————
#---| Section [3] |-------------------------------------------------------------
#---| Script Main Function |----------------------------------------------------
#———————————————————————————————————————————————————————————————————————————————

# [3.1] : Script's Main Function --- Only thing executed when script is run
main() {
  get_options "$@"
  get_arguments "$@"
	
	
	
  # ARGUMENTS:
  debug " -- ARGUMENTS"
  debug "|"
  # $filename : Name of the (local) file whose contents will be copied.
  debug "|   filename=$filename"
  debug "|"

	# OPTIONS:
	debug " -- OPTIONS"
	debug "|"
	# $multipleFiles : Option indicating multiple files are to have their contents copied.
	debug "|   multipleFiles=$multipleFiles"
	debug "|"

	# FLAGS:
	debug " -- FLAGS"
	debug "|"
	# $_VERBOSE : Enable verbose mode
	debug "|   _VERBOSE=$_VERBOSE"
	# $useFileList : Flag indicating a list of files will be supplied and each item in list will have contents copied.
	debug "|   useFileList=$useFileList"
	debug "|"
	debug " "
	debug "----------------[EXECUTION RESULT FOLLOWS BELOW]--------------------"
	
	local termWidth
	
	if [[ ! terminal_window_width ]]; then
		termHeight="$(terminal_window_height_fallback)"
	else
		termHeight="$(terminal_window_height)"
	fi
	printf "${termHeight}\n"
}

#———————————————————————————————————————————————————————————————————————————————
#---| Section [4] |-------------------------------------------------------------
#---| Script Execution Runtime |------------------------------------------------
#———————————————————————————————————————————————————————————————————————————————

# [4.1] : Script's Runtime Execution --- (Only calls `main()` with script args)
main "$@"

##################
### SCRIPT END ###
##################

