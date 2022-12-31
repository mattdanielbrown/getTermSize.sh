#!/usr/bin/env bash
#===============================================================================
#  getTermSize
#-------------------------------------------------------------------------------
#  * VERSION 2.1.7
#  * CREATED 2022-12-29
#  * UPDATED 2022-12-31
#	 * BY MATT DANIEL BROWN <dev@mattbrown.email>
#  * https://github.com/mattdanielbrown/getTermSize.sh
#  * COPYRIGHT (C) 2022. ALL RIGHTS RESERVED.
#===============================================================================
# USAGE
#   getTermSize [-vwHe]
#
# DESCRIPTION
#   Get and report the width and/or height of terminal window... 
# 	Alternatively, get, set, and export the values as variables.
#
# FLAGS
#   -w, --width    The terminal window width
#   -H, --height   The terminal window height
#   -e, --export   Only source & export values as variables 
# 								 (e.g., Don't print to STDOUT)
#
# STANDARD OPTIONS
#   -V, --verbose  Enable verbose mode
#   -h, --help     Show this help
#   -v, --version  Show script version
#===============================================================================

#-------------------------------------------------------------------------------
# Variables
#-------------------------------------------------------------------------------

# Standard Script Utility Values
_SCRIPT_NAME="$(basename "$0")"
_VERSION=0.1.0
_ARGSHIFT=1
_VERBOSE=

# Script's main values
get_term_width=
get_term_height=
source_and_export_values=
TERM_HEIGHT=
TERM_WIDTH=

# Script's final result values
OUTPUT_SCRIPT_RESULT=true
SCRIPT_RESULT=

#-------------------------------------------------------------------------------
# Utility Functions
#-------------------------------------------------------------------------------

# Print error message [ execute command ] and exit [ with defined status ]
error() {
    echo "${_SCRIPT_NAME}: $1" > /dev/stderr
    [ $# -gt 2 ] && eval "$2" && exit "$3"
    [ $# -gt 1 ] && exit "$2"
    exit 1
}

# Print log message
log() {
    echo "${_SCRIPT_NAME}: $1" > /dev/stderr
}

# Print debug message if script called with verbose mode
debug() {
    [ "$_VERBOSE" ] && echo "${_SCRIPT_NAME}: $1" > /dev/stderr
}

# Print the usage/help message
usage() {
cat << EOF
USAGE
  \$  ${_SCRIPT_NAME} [-vwHe]

DESCRIPTION
  Get and report the width and or height of the terminal window, or export the values as variables.

FLAGS:
  -w, --width    The terminal window width
  -H, --height   The terminal window height
  -e, --export   Only source and export the values as variables. Do not print to STDOUT.

Standard Options:
  -V, --verbose  Enable verbose mode
  -h, --help     Show this help
  -v, --version  Show script version

EOF
}

#-------------------------------------------------------------------------------
# Main Script Functions
#-------------------------------------------------------------------------------

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
	TERMINAL_WINDOW_WIDTH="$(terminal_window_width)"
	TERMINAL_WINDOW_HEIGHT="$(terminal_window_height)"
}

function print_terminal_height_line {
	for (( i = 0; i < ${TERMINAL_WINDOW_HEIGHT}; i++ )); do
		printf "| \n"
	done
}
function print_terminal_window_width_line {
	for (( i = 0; i < ${TERMINAL_WINDOW_WIDTH}; i++ )); do
		printf "-"
	done
}

function try_to_set_term_width {
	
	if [[ "$(tput cols)" ]]; then
		TERM_WIDTH="$(tput cols)"
	else
		TERM_WIDTH="$(stty -a | grep columns | sed 's/^.*;\(.*\)columns\(.*\);.*$/\1\2/' | sed 's/;.*$//' | sed 's/[^0-9]//g')"
	fi
}
function try_to_set_term_height {
	if [[ "$(tput lines)" ]]; then
		TERM_HEIGHT="$(tput lines)"
	else
		TERM_HEIGHT="$(stty -a | grep rows | sed 's/^.*;\(.*\)rows\(.*\);.*$/\1\2/' | sed 's/;.*$//' | sed 's/[^0-9]//g')"
	fi
}

#-------------------------------------------------------------------------------
# Functions To Handle CLI, Parameters, Options, Main Runtime, etc.
#-------------------------------------------------------------------------------

# Get and parse options/flags
get_options() {
    _SILENT=
    _OPTSTRING="${_SILENT}vwHe-:"
    while getopts "${_OPTSTRING}" _OPTION
    do
      case "${_OPTION}" in
        v)
          _ARGSHIFT="${OPTIND}"
          _VERBOSE=1
          ;;
        w)
          _ARGSHIFT="${OPTIND}"
          get_term_width=1
          ;;
        H)
          _ARGSHIFT="${OPTIND}"
          get_term_height=1
          ;;
        e)
          _ARGSHIFT="${OPTIND}"
          source_and_export_values=1
					OUTPUT_SCRIPT_RESULT=false
          ;;
        -)
          case "${OPTARG}" in
            help) usage && exit 0;;
            version) echo "$_VERSION" && exit 0;;
            verbose)
              _VERBOSE=1
              _ARGSHIFT="${OPTIND}"
              ;;
            width)
              get_term_width=1
              _ARGSHIFT="${OPTIND}"
              ;;
            height)
              get_term_height=1
              _ARGSHIFT="${OPTIND}"
              ;;
            export)
              source_and_export_values=1
							OUTPUT_SCRIPT_RESULT=false
              _ARGSHIFT="${OPTIND}"
              ;;
            *)
              if [ "$OPTERR" = 1 ] && [ -z "$_SILENT" ]; then
                error "illegal option -- ${OPTARG}" usage 1
              fi
              ;;
            esac;;
       \?)
          # VERBOSE MODE
          # invalid option: _OPTION is set to ? (question-mark) and OPTARG is unset
          # required argument not found: _OPTION is set to ? (question-mark), OPTARG is unset and an error message is printed
          [ -z "$_SILENT" ] && usage && exit 1
          # SILENT MODE
          # invalid option: _OPTION is set to ? (question-mark) and OPTARG is set to the (invalid) option character
          [ ! -z "$_SILENT" ] && echo "illegal option -- ${OPTARG}"
          ;;
        :)
          # SILENT MODE
          # required argument not found: _OPTION is set to : (colon) and OPTARG contains the option-character in question
          echo "option requires an argument -- ${OPTARG}"
          ;;
      esac
    done
}

# Get and parse arguments
get_arguments() {
    _ARGS=""

    shift $(( _ARGSHIFT - 1 ))

    for _ARG in $_ARGS
    do
      if [ ! -z "$1" ]; then
        eval "$_ARG=$1"
      fi
      shift
    done
}

# The Main Script Function
init() {
    get_options "$@"
    get_arguments "$@"
		
		try_to_set_term_width
		# echo "(width set ${TERM_WIDTH})"
		try_to_set_term_height
		# echo "(height set ${TERM_HEIGHT})"
		
		if [[ source_and_export_values -eq 1 ]]; then
			OUTPUT_SCRIPT_RESULT=false
			export TERM_HEIGHT="$(tput lines)"
			# export "$TERM_HEIGHT"
		else
			OUTPUT_SCRIPT_RESULT=true
		fi
		
		if [[ $OUTPUT_SCRIPT_RESULT ]]; then
			if [[ get_term_width -eq 1 ]]; then
				SCRIPT_RESULT=$TERM_WIDTH
				echo $SCRIPT_RESULT
			elif [[ get_term_height -eq 1 ]]; then
				SCRIPT_RESULT=$TERM_HEIGHT
				echo $SCRIPT_RESULT
			fi
			
		fi

		


   # FLAGS:
   debug " -- FLAGS"
   debug "|"
   # $_VERBOSE : Enable verbose mode
   debug "|   _VERBOSE=$_VERBOSE"
   # $get_term_width : The terminal window width
   debug "|   get_term_width=$get_term_width"
   # $get_term_height : The terminal window height
   debug "|   get_term_height=$get_term_height"
   # $source_and_export_values : Only source and export the values as variables. Do not print to STDOUT.
   debug "|   source_and_export_values=$source_and_export_values"
   debug "|"
}

#-------------------------------------------------------------------------------
# Actual Script runtime
#-------------------------------------------------------------------------------

# (Initiate the script's main function and supply it with provided parameters)
init "$@"

#===============================================================================

### Script End ###
