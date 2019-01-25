set define off;
Create Or Replace Package Body XXLSL.XXLSL_Pkg_Security Is
Function Authenticate_User(p_User_Name Varchar2,p_Password Varchar2) Return Boolean As
v_Password XXLSL.XXLSL_USER_ACCOUNT.Password%Type;
v_Active XXLSL.XXLSL_USER_ACCOUNT.Active%Type;
v_Email XXLSL.XXLSL_USER_ACCOUNT.Email%Type;
Begin

If p_User_Name Is Null Or p_Password Is Null Then
Apex_Util.Set_Session_State('LOGIN_MESSAGE'
,'Please enter Username and password.');
Return False;
End If;

Begin
Select u.Active,u.Password,u.Email into v_Active
,v_Password
,v_Email
From XXLSL_USER_ACCOUNT u
Where  u.User_Name = p_User_Name;
Exception
When No_Data_Found Then
Apex_Util.Set_Session_State('LOGIN_MESSAGE'
,'User not found');
Return False;
End;
If v_Password != p_Password Then
Apex_Util.Set_Session_State('LOGIN_MESSAGE'
,'Password incorrect');
Return False;
End If;
If v_Active <> 'Y' Then
Apex_Util.Set_Session_State('LOGIN_MESSAGE'
,'User locked, please contact admin');
Return False;
End If;
Apex_Util.Set_Session_State('SESSION_USER_NAME'
,p_User_Name);
Apex_Util.Set_Session_State('SESSION_EMAIL'
,v_Email);
Return True;
End;

Procedure Process_Login(p_User_Name Varchar2
,p_Password Varchar2
,p_App_Id Number) As
v_Result Boolean := False;
Begin
v_Result := Authenticate_User(p_User_Name
,p_Password);
If v_Result = True Then
Wwv_Flow_Custom_Auth_Std.Post_Login(p_User_Name -- p_User_Name
,p_Password -- p_Password
,v('APP_SESSION') -- p_Session_Id
,p_App_Id || ':1' -- p_Flow_page
);
Else
Owa_Util.Redirect_Url('f?p=&APP_ID.:101:&SESSION.');
End If;
End;
End XXLSL_Pkg_Security;
/