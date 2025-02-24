########################
## The Folder Watcher ##
########################

This is a PS script for monitoring changes in a specified folder and managing files based on those changes.

Allows interactive renaming and sorting of these files based on predefined criteria.

It utilizes Windows Forms to prompt the user for input.

###############
#### Usage ####
###############

Set up a default folder for your incoming files which need custom re-mapping.
Example: Incoming types of Screenshots/E-mails/Excels.
Run the PS script in the background. 

It requires custom user mapping - naming conventions and used folders.

Used in a specific environment like 
Accounting, 
Photography and Media Management, 
Journaling & Research, 
Education, etc.

It can save tremendous amount of User time of performing manual moving, naming, arranging between folders & directories.


########################
## Real world example ##
########################

*Photography and Media Management*

File naming convention:
N_*Name* = "C:\Users\baciu\Desktop\Neo Training\Neo's Photos Diary"
CQ_*Name* = "C:\Users\baciu\Desktop\World Of Conquer\CQ Media Diary - Starting Mar-2024"
DQ_*Name* = "C:\Users\baciu\Desktop\Media\Dhamma Quotes"
P_*Name* = "C:\Users\baciu\Desktop\Media\Photos"
M_*Name* = "C:\Users\baciu\Desktop\Media" 


*With Script Running*
A new screenshot is detected in default folder of Name 
"421082250_10224955636101479_4989675831891644786_n.jpg"

After a few seconds (waiting until file is fully loaded), it will prompt user for input.
If user inputs "M_The Secrets Of Life" - the script will automatically move the file to
"C:\Users\baciu\Desktop\Media" under the name of "The Secrets Of Life.jpg" (extension is always maintained)



*PS Console Output*

"Monitoring C:\Users\baciu\Desktop\World Of Conquer\All_Screenshots for new files. Press CTRL+C to exit...
Event triggered for file: C:\Users\baciu\Desktop\World Of Conquer\All_Screenshots\Capture_23-05-2024_08;55.png
Stable file added to Queue: C:\Users\baciu\Desktop\World Of Conquer\All_Screenshots\Capture_23-05-2024_08;55.png
File successfully renamed to C:\Users\baciu\Desktop\World Of Conquer\All_Screenshots\M_The Secrets Of Life.png
File $finalName moved to C:\Users\baciu\Desktop\Media\The Secrets Of Life.png"




##################
## Requirements ##
##################

Run in Windows PS ISE as it uses Windows Forms and PS might encounter issues with generating Windows Forms prompt.

For other OS, it can be reduced to simply PS input when file is detected - but it will come with the drawback that 
the input window will not pop up as main tab - which comes with great practical use.

Can also be turned into .exe. (I recommend ps2exe - https://github.com/MScholtes/PS2EXE)