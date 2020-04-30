################################################################
# Script: idbe.sh
# Purpose: Parse iDevice backup directory contents, determine
#          the files types of the contents and sort and place
#	   them on the user's desktop.
# Author: John P. Richardson, paul@reverendlinux.com
# License: This script is released under the GNU
#          General Public License Version 2.0.
#          See http://www.gnu.org/licenses/gpl-2.0.html
#          for full license information.
################################################################
# Get user name
USER=$(id -un)

# Store the IFS for setting back later
OIFS=$IFS

# Set user backup directory
BUD="/Users/$USER/Library/Application Support/MobileSync/Backup/"

# Get directory listing
DIRLIST=$(ls -m "$BUD")

# Count entries in the dir
COUNT=$(ls -l | wc -l)

# Make sure we have some backups
if [ $COUNT -lt 1 ]; then
    echo "No backups found."
    sleep 1
    clear
    break
fi

# Split DIRLIST at the comma
ARRAY=(${DIRLIST//,/ })

while true; do

    # Print a header
    clear
    echo "iDevice Backup Processor V0.1"
    echo ""

    # Display DTG of backups and ask user to choose
    echo ""

    for i in "${!ARRAY[@]}"; do
        DIR=$(echo "${ARRAY[i]}" | tr -d ' ')
        DIR=$(echo "${ARRAY[i]}" | tr -d '\n')

        echo "$i: "$(stat -f "%t%Sm" "$BUD"$DIR)
    done

    echo ""
    echo "Choose which backup to process."
    echo "Press Enter to exit."
    read CHOICE

    # Check user input
    if [ "$CHOICE" = "" ]; then
        # User chose to exit
        echo "Exiting..."
        sleep 1
        clear
        exit
    elif [ $CHOICE -gt $COUNT ]; then
        # User entered a number outside the valid amount
        echo ""
        echo "Not a valid choice."
        sleep 1
        clear
    elif [ $CHOICE -le $COUNT ]; then
        # User entered valid choice, process
        echo ""
        echo "Processing the selected backup..."
        echo ""

        # Make a dir on the user's desktop if not already there
        ExDIR="/Users/$USER/Desktop/Extracted iDevice Backups"
        if [ -e "$ExDIR" ] && [ -d "$ExDIR" ]; then
            echo "Extraction Directory Exists...continuing..."
        else
            $(mkdir "/Users/$USER/Desktop/Extracted iDevice Backups")
            echo "Created Extraction Directory...continuing..."
        fi

        # Set our source dir
        SRC=$BUD"${ARRAY[$CHOICE]}"

        # Get the date time of our source dir and format it
        DTG=$(stat -f "%t%Sm" "$SRC")
        DTG=$(echo ${DTG// /_})
        DTG=$(echo ${DTG//:/})

        # Set our target dir
        TGT=$ExDIR"/$DTG"

        # Make target dir if already there
        if [ -e "$TGT" ] && [ -d "$TGT" ]; then
            echo "Target Directory Exists...continuing..."
        else
            $(mkdir "$TGT")
            echo "Created Target Directory...continuing..."
        fi

        # Make a bunch of file type dirs if not already there
        if [ -e "$TGT/Audio" ] && [ -d "$TGT/Audio" ]; then
            echo "Audio Directory Exists...continuing..."
        else
            $(mkdir "$TGT/Audio")
            echo "Created Audio Directory...continuing..."
        fi

        if [ -e "$TGT/Video" ] && [ -d "$TGT/Video" ]; then
            echo "Video Directory Exists...continuing..."
        else
            $(mkdir "$TGT/Video")
            echo "Created Video Directory...continuing..."
        fi

        if [ -e "$TGT/Image" ] && [ -d "$TGT/Image" ]; then
            echo "Image Directory Exists...continuing..."
        else
            $(mkdir "$TGT/Image")
            echo "Created Image Directory...continuing..."
        fi

        if [ -e "$TGT/DB" ] && [ -d "$TGT/DB" ]; then
            echo "DB Directory Exists...continuing..."
        else
            $(mkdir "$TGT/DB")
            echo "Created Database Directory...continuing..."
        fi

        if [ -e "$TGT/Txt" ] && [ -d "$TGT/Txt" ]; then
            echo "Txt Directory Exists...continuing..."
        else
            $(mkdir "$TGT/Txt")
            echo "Created Database Directory...continuing..."
        fi

        if [ -e "$TGT/Misc" ] && [ -d "$TGT/Misc" ]; then
            echo "Miscellaneous Directory Exists...continuing..."
        else
            $(mkdir "$TGT/Misc")
            echo "Created Miscellaneous Directory...continuing..."
        fi

        # Process the source directory
        # Get the list of files in the src dir
        for f in $(ls "$SRC"); do
            # Get file type
            FILE=$(file "$SRC/$f")

            # Split file at the : LEFT is file name, RIGHT is file type
            IFS=: read LEFT RIGHT <<<"$FILE"

            # Split RIGHT at space
            IFS=" "
            set $RIGHT

            # Get Date and time for the file and format it
            FDTG=$(stat -f "%t%Sm" "$SRC/$f")
            FDTG=$(echo ${FDTG// /-})
            FDTG=$(echo ${FDTG//:/})
            FDTG=$(sed -e 's/^[[:space:]]*//' <<<"$FDTG")

            # Copy the file over based on what type of file it is
            if [ "$2" = "image" ]; then
                $(cp "$SRC/$f" "$TGT/Image/$FDTG.$1")
                echo "Extracted JPG Image File...continuing..."
            elif [ "$1" = "ASCII" ] || [ "$1" = "UTF-8" ] && [ "$2" != "C++" ]; then
                $(cp "$SRC/$f" "$TGT/Txt/$FDTG.txt")
                echo "Extracted Text File...continuing..."
            elif [ "$1" = "XML" ]; then
                $(cp "$SRC/$f" "$TGT/Txt/$FDTG.xml")
                echo "Extracted XML File...continuing..."
            elif [ "$1" = "HTML" ]; then
                $(cp "$SRC/$f" "$TGT/Txt/$FDTG.html")
                echo "Extracted HTML File...continuing..."
            elif [ "$1" = "diff" ]; then
                $(cp "$SRC/$f" "$TGT/Misc/$FDTG.diff")
                echo "Extracted DIFF File...continuing..."
            elif [ "$2" = "C++" ]; then
                $(cp "$SRC/$f" "$TGT/Misc/$FDTG.c")
                echo "Extracted C++ Text File...continuing..."
            elif [ "$2" = "Multi-Rate" ]; then
                $(cp "$SRC/$f" "$TGT/Audio/$FDTG.amr")
                echo "Extracted Audio File...continuing..."
            elif [ "$1" = "SQLite" ]; then
                $(cp "$SRC/$f" "$TGT/DB/$FDTG.db")
                echo "Extracted SQLite Database File...continuing..."
            elif [ "$2" = "binary" ]; then
                $(cp "$SRC/$f" "$TGT/Misc/$FDTG.bin")
                echo "Extracted Binary File...continuing..."
            elif [ "$1" = "gzip" ]; then
                $(cp "$SRC/$f" "$TGT/Misc/$FDTG.gz")
                echo "Extracted GZip Archive File...continuing..."
            elif [ "$1" = "data" ]; then
                $(cp "$SRC/$f" "$TGT/Misc/$FDTG.data")
                echo "Extracted Data File...continuing..."
            elif [ "$1" = "ISO" ] && [ "$2" = "Media," ] && [ "$3" = "Apple" ]; then
                $(cp "$SRC/$f" "$TGT/Video/$FDTG.mov")
                echo "Extracted Quicktime Video File...continuing..."
            elif [ "$1" = "ISO" ] && [ "$2" = "Media" ] && [ "$3" = "MPEG" ]; then
                $(cp "$SRC/$f" "$TGT/MPEG/$FDTG.mpg")
                echo "Extracted MPEG Video File...continuing..."
            else
                $(cp "$SRC/$f" "$TGT/Misc/$FDTG")
                echo "Extracted Unknown File Type...continuing..."
            fi
        done

        f=""
        i=""
        ExDIR=""
        CHOICE=""
        DTG=""
        SRC=""
        TGT=""
        IFS=$OFS

        sleep 1
    else
        # User entered something other than a number
        echo ""
        echo "I have no idea what you want to do."
        sleep 1
        clear
    fi
done
