#!/bin/bash

###########################
#  Variable Declarations  #
###########################
INTERVAL=$1
TEMP=`vcgencmd measure_temp`
DATE=`date`
TEMPLOG="/var/log/tempmonreading.log"
EVENTLOG="/var/log/tempmonevents.log"
TEMPHISTORYLAST="/var/log/tempmonhistorylast.log"
LASTAVGTEMP="/var/log/tempmonavgtemp.log"

if [ -z $1 ]
then
	clear
	echo "No parameter Detected"
	echo "**********************"
	echo "USAGE:"
	echo "tempmon.sh [mm]"
	echo "Where 'mm' is equal to the sampling interval in minutes"
	echo
	echo "Please re-run with a parameter value"
	exit
else



function WriteCurrentTemp
{
#################################
#   WRITE CURRENT TEMP TO LOG
#################################
   
echo $(date) - "--" $TEMP>>$TEMPLOG
}




function CountSamples
{

#################################
#   COUNT THE NUMBER OF SAMPLES
#   IN THE $TEMPLOG FILE
#################################

NUMSAMPLES=`cat $TEMPLOG |wc -l`

}





function SampleTemps
{

#################################
#  SAMPLE LAST n TEMPS TAKEN
#  BASED ON INTERVAL DEFINED
#  AT RUNTIME
#################################

echo $(date) - "--" "Number of samples in the log: "$NUMSAMPLES >> $EVENTLOG
echo $(date) - "--" "Interval selected: $INTERVAL minutes" >> $EVENTLOG
SAMPLETEST=`echo $((NUMSAMPLES < INTERVAL))`


if [ "$SAMPLETEST" = "1" ]
then
	echo $(date) - "--" "Temperature has not yet been sampled for $INTERVAL minutes." >>$EVENTLOG
	echo $(date) - "--" "There are only $NUMSAMPLES samples in the log file.  Enter a smaller sample size." >>$EVENTLOG
	exit

else
	tail -n $INTERVAL $TEMPLOG>$TEMPHISTORYLAST
fi
}



function CalculateAvgTemp
{

#################################
#  CALCULATE AVERAGE TEMP FROM
#  INTERVAL DEFINED AT RUNTIME
#################################

for i in `cat $TEMPHISTORYLAST|cut -d= -f2|cut -d. -f1`
	do
 		SUM=`echo $((SUM + i))`
	done


AVGTEMP=`echo $((SUM / INTERVAL))`
echo $(date) - "--" "Average Temperature over the last "$INTERVAL" minutes is "$AVGTEMP" Degrees Celcius" >>$EVENTLOG
echo $AVGTEMP "C">$LASTAVGTEMP

}

fi

#################
#	EXECUTION
#################
WriteCurrentTemp
CountSamples
SampleTemps
CalculateAvgTemp
