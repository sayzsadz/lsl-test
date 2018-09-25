*********************************************************************************************
End User Computing v5.x (x86) and (x64)

Mandatory Update: v5-Oracle_JRE_7.0_Update_55

Description:
-> This Critical Patch Update contains security fixes for Oracle Java SE. 
	URL : http://www.oracle.com/technetwork/topics/security/cpuapr2014-1972952.html

-> Java 7 update 51 (January, 2014) intends to include two security changes designed to enhance authentication and authorization for Rich Internet Applications (Applets and Web Start). The default security slider is being updated in a way that will block RIAs that do not adhere to these requirements. 
	https://blogs.oracle.com/java-platform-group/entry/new_security_requirements_for_rias

-> With JRE 7u51, Oracle restricted unsigned code so that the user has to include sites with unsigned code in the site exception list before presented with a prompt. Java 7 update 51 (January, 2014) intends to include two security changes designed to enhance authentication and authorization for Rich Internet Applications (Applets and Web Start). The default security slider is being updated in a way that will block RIAs that do not adhere to these requirements. 
    https://blogs.oracle.com/java-platform-group/entry/new_security_requirements_for_rias

-> End User Computing Team have now incorporated a machanism by which member firms can add their exception site list in the package itself before deploying to End Users. Steps as below
	
 	Adding URL in Exception Site List
	1 : Edit the exception site list located under "v5-Oracle_JRE_7.0_Update_55\Windows\Sun\Java\Deployment" with notepad.
	2 : Add the URL, only one URL is allowed per line.
	3 : Save and Deploy the package. 

Below Sites are added by default:
1. https://mypdecc01stg.ams.ema.kworld.kpmg.com/
2. https://mypdecc01.ams.ema.kworld.kpmg.com/
3. http://goeapapp06.kworld.kpmg.com:8001/

Upgrade Note:  
This version will uninstall/upgrade all previous verions of JRE 6 to JRE 7 Update 55
Action: All previous releases of JRE 6 and JRE 7 needs to be updated to JRE 7 Update 55.

Date : April 28, 2014
		
**********************************************************************************************

Contents:
=========
The files included in for this update are:

JavaInstall.vbs				- Main setup vbs file for installation of v5-Oracle_JRE_7.0_Update_55
					- Extracted to: <Root_Server_Share>\

jre1.7.0_55.msi   				- Setup msi file for installation of v5-Oracle_JRE_7.0_Update_55
					- Extracted to: <Root_Server_Share>\

jre1.7.0_55.Mst	         			- Setup Transform file for installation of v5-Oracle_JRE_7.0_Update_55
					- Extracted to: <Root_Server_Share>\

Data1.cab				- Cabinet file for v5-Oracle_JRE_7.0_Update_55
					- Extracted to: <Root_Server_Share>\									

ReadMe.txt	                        		- This file
					- Extracted to: <Root_Server_Share>\

deployment.properties			- Source binary file added by End User Computing 
					- Extracted to: <Root_Server_Share>\Windows\Sun\Java\Deployment

deployment.config				- Source binary file added by End User Computing 
					- Extracted to: <Root_Server_Share>\Windows\Sun\Java\Deployment

exception.sites				- Source binary file added by End User Computing 
					- Extracted to: <Root_Server_Share>\Windows\Sun\Java\Deployment

Instructions:
=============
Engineering Process Implementation:
-----------------------------------
To implement this update as part of the Engineering Process you will have to extract the contents of the zip file to the root of your GDv5 share.

Standalone Installation:
------------------------
To install this application as a standalone installation, 
 
Run JavaInstall.vbs with administrator rights.

REBOOT:
=======
Not Required.

Application:
============
This update should be mandatory applied to all GDv5.x Desktops.

Verifying Update Installation:
==============================
v5.x (x86)
		File(Name): C:\Program Files\Java\jre7\bin\java.exe
		=========
		version:  	7.0.550.13
		========

v5.x (x64)
		File(Name): C:\Program Files (x86)\Java\jre7\bin\java.exe
		=========
		version:  	7.0.550.13
		========