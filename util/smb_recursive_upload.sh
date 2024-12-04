#!/bin/bash

# Function to display help menu
show_help() {
    echo "Usage: $0 [OPTIONS]"
    echo ""
    echo "Recursively upload files to the lab research drive, transferring only changed or new files."
    echo ""
    echo "Required arguments:"
    echo "  -l, --local-path     Local directory path to upload from"
    echo "  -r, --remote-path    Remote directory path on research drive to upload to"
    echo ""
    echo "Optional arguments:"
    echo "  -h, --help           Show this help message"
    echo ""
    echo "Example:"
    echo "  $0 -l magory13/data -r gluckthaler_backup/magory13/data"
    echo ""
}

# Parse command-line arguments
LOCAL_PATH=""
REMOTE_PATH=""

PARSED_ARGUMENTS=$(getopt -a -n upload-script -o l:r:h --long local-path:,remote-path:,help -- "$@")
VALID_ARGUMENTS=$?

# Check if getopt was successful
if [ "$VALID_ARGUMENTS" != "0" ]; then
    show_help
    exit 1
fi

# Process parsed arguments
eval set -- "$PARSED_ARGUMENTS"
while :
do
    case "$1" in
        -l | --local-path)
            LOCAL_PATH="$2"
            shift 2
            ;;
        -r | --remote-path)
            REMOTE_PATH="$2"
            shift 2
            ;;
        -h | --help)
            show_help
            exit 0
            ;;
        --) 
            shift
            break
            ;;
        *)
            show_help
            echo "Unexpected option: $1"
            exit 1
            ;;
    esac
done

# Validate required arguments
if [[ "$REMOTE_PATH" != *"$LOCAL_PATH" ]]; then
    show_help
    echo "Error: The local directory path should be repeated at the end of the remote directory path to ensure consistency in directory structures. See example above."
    exit 1
fi

# Make sure local and remote directories match
if [ -z "$LOCAL_PATH" ] || [ -z "$REMOTE_PATH" ]; then
    show_help
    echo "Error: Both local and remote paths are required."
    exit 1
fi


# Validate local path exists
if [ ! -d "$LOCAL_PATH" ]; then
    echo "Error: Local path does not exist: $LOCAL_PATH"
    exit 1
fi

# Source path to the Lab ResearchDrive 
SOURCE="//research.drive.wisc.edu/gluckthaler/"

# Function to recursively compare and put files
recursive_smb_update() {
    local local_path="$1"
    local remote_path="$2"
    
    # Create remote parent directory if it does not exist
	if [ "$remote_path" != "." ]; then
		smbclient -q -k "$SOURCE" -c "mkdir \"$remote_path\"" 2>/dev/null
	fi

    # Find all local files recursively
    find "$local_path" -type f | while read -r local_file; do
        # Get relative path
        relative_path="${local_file#$local_path/}"
        absolute_path="${local_path}/${relative_path}/"
				
        # Get local file size
        local_size=$(stat -c '%s' "$local_file")
        
		 # Extract directory path for the remote file
        remote_dir=$(dirname "$relative_path")        
        
        # Create remote directory structure
        if [ "$remote_dir" != "." ]; then
            smbclient -q -k "$SOURCE" -c "cd \"$remote_path\"; mkdir \"$remote_dir\"" 2>/dev/null
        fi

        # Check remote file existence and size
        remote_size=$(smbclient -q -k "$SOURCE" -c "cd \"$remote_path\"; allinfo \"$relative_path\"" 2>/dev/null | grep stream: | grep :: | awk '{print $3}')
		
        # Transfer if file doesn't exist or sizes are different
        if [[ -z "$remote_size" ]] || [[ "$local_size" -ne "$remote_size" ]]; then
            
            # Upload the file
            smbclient -q -k "$SOURCE" -c "cd \"$remote_path\"; put \"$local_file\" \"$relative_path\"" 2>/dev/null
            echo "[$(date '+%Y-%m-%d %H:%M:%S')] uploaded: $absolute_path"
        fi
    done
}

# Start the recursive update
recursive_smb_update "$LOCAL_PATH" "$REMOTE_PATH"