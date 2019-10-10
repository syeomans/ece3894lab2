#!/bin/csh -f

echo ""
echo "---** Electronic Submission for ECE3894: Lab1 **---"
echo "---** Stop if you are submitting a different lab. **---"
echo "---** continue? <y|n> **--- "
set reply = $<
if ($reply == "y") then

	if ( -d "$1") then
		echo "Using directory $1"
		echo ""
		echo "Enter your favorite number (0-whatever): "
		set rand = $<
		set filename="$USER-Lab1-$rand.zip"
		zip -r $filename $1
		echo "---** Attempting to submit **---"
		cp $filename /nethome/ychen414/ECE3894/lab/lab1/submissions/.
		if (-e /nethome/ychen414/ECE3894/lab/lab1/submissions/$filename) then
			chmod 666 /nethome/ychen414/ECE3894/lab/lab1/submissions/$filename
			echo "---** Copy succeeded **---"
			echo ""
			echo "Keep the checksum below: "
			cksum $filename
		else
			echo "---** Uh-oh! Failed! **---"
			echo ""
			echo "Provide me the checksum below: "
			cksum $filename
		endif
		rm $filename
		echo ""
	else
		echo ""
		echo "---** The directory (folder) $1 does not exist! **---"
		echo "Fatal error: please call with correct directory (folder) name"
		echo ""
	endif
else
	echo "Exiting."
endif
