On Error Resume Next
Set ws = CreateObject("WScript.Shell")
Set fso = CreateObject("Scripting.FileSystemObject")
sGetfolder = fso.GetParentFolderName(Wscript.ScriptFullName)
Dim iReturn, bFlagA, bFlagB, bFlagC, bFlagD
strComputer = "."

'======================================================================================
' Checking if Internet Explorer and Amdocs application are Opened in the machine, if yes giving a pop up to close the same.
'======================================================================================
'Wscript.Sleep 5000
Do

bFlagA=0 
bFlagB=0
bFlagC=0
bFlagD=0

Set objWMIService = GetObject("winmgmts:" _
    & "{impersonationLevel=impersonate}!\\" & strComputer & "\root\cimv2")
Set colProcessList = objWMIService.ExecQuery _
    ("Select * from Win32_Process Where Name = 'IEXPLORE.EXE'")

	For Each objProcess In colProcessList
   		bFlagA=1
	Next

Set objWMIService = GetObject("winmgmts:" _
    & "{impersonationLevel=impersonate}!\\" & strComputer & "\root\cimv2")
Set colProcessList = objWMIService.ExecQuery _
    ("Select * from Win32_Process Where Name = 'javaw.exe'")
	
	For Each objProcess in colProcessList
   		bFlagB=1
	Next

Set objWMIService = GetObject("winmgmts:" _
    & "{impersonationLevel=impersonate}!\\" & strComputer & "\root\cimv2")
Set colProcessList = objWMIService.ExecQuery _
    ("Select * from Win32_Process Where Name = 'mshta.exe'")
	
	For Each objProcess in colProcessList
   		bFlagC=1
	Next

Set objWMIService = GetObject("winmgmts:" _
    & "{impersonationLevel=impersonate}!\\" & strComputer & "\root\cimv2")
Set colProcessList = objWMIService.ExecQuery _
    ("Select * from Win32_Process Where Name = 'java.exe'")
	
	For Each objProcess in colProcessList
   		bFlagD=1
	Next


If bFlagA=1 Or bFlagB=1 or bFlagC=1 or bFlagD=1 Then 
	iReturn= MsgBox ("The Internet Explorer and Amdocs application must be closed before this update can be installed. Please close the applications and click OK to continue.", 1, "Oracle JRE Update")
		
	If iReturn = 2 Then
		WScript.Quit(-5)
	End If
Else	
			
	cmdLine = "msiexec.exe /i " & Chr(34) & sGetfolder & "\jre1.7.0_55.msi" & Chr(34) & " Transforms=" & Chr(34) & sGetfolder & "\jre1.7.0_55.Mst" & Chr(34) & " /qb! " & "/l*v " & "" & chr(34) & sGetfolder & "\Install.Log" & chr(34) & ""
	ws.Run cmdLine, 1, True
		
End If

Loop Until (bFlagA=0 And bFlagB=0 And bFlagC=0 And bFlagD=0)