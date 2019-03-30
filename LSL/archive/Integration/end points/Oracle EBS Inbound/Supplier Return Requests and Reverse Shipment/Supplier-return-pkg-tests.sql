  CREATE TABLE "XXLSL"."XXLSL_USER_ACCOUNT" 
   (	"USER_NAME" VARCHAR2(30 BYTE) NOT NULL ENABLE, 
	"PASSWORD" VARCHAR2(30 BYTE) NOT NULL ENABLE, 
	"USER_TYPE" VARCHAR2(10 BYTE) NOT NULL ENABLE, 
	"ACTIVE" VARCHAR2(1 BYTE) NOT NULL ENABLE, 
	"EMAIL" VARCHAR2(64 BYTE) NOT NULL ENABLE, 
	"FULL_NAME" VARCHAR2(64 BYTE) NOT NULL ENABLE
    );/
alter table XXLSL.XXLSL_USER_ACCOUNT add constraint USER_ACCOUNT_PK primary key (USER_NAME) ;
alter table XXLSL.XXLSL_USER_ACCOUNT add constraint USER_ACCOUNT_UK unique (EMAIL) ;
 
-----------------------------------
 
insert into XXLSL.XXLSL_USER_ACCOUNT (USER_NAME, PASSWORD, USER_TYPE, ACTIVE, EMAIL, FULL_NAME)
values ('tom', 'tom123', 'admin', 'Y', 'tom@example.com', 'Tom');
 
insert into XXLSL.XXLSL_USER_ACCOUNT (USER_NAME, PASSWORD, USER_TYPE, ACTIVE, EMAIL, FULL_NAME)
values ('jerry', 'jerry123', 'user', 'Y', 'jerry@example.com', 'Jerry');
 
insert into XXLSL.XXLSL_USER_ACCOUNT (USER_NAME, PASSWORD, USER_TYPE, ACTIVE, EMAIL, FULL_NAME)
values ('donald', 'donald123', 'guest', 'N', 'donald@example.com', 'Donald');
 
Commit;

set define off;

Create Or Replace Package XXLSL.XXLSL_Pkg_Security
AS
Function Authenticate_User(p_User_Name Varchar2, p_Password Varchar2) return boolean;
Procedure Process_Login(p_User_Name Varchar2, p_Password Varchar2, p_App_Id Number);
End XXLSL_Pkg_Security;
/
Create Or Replace Package Body XXLSL.XXLSL_Pkg_Security Is
Function Authenticate_User(p_User_Name Varchar2,p_Password Varchar2) Return Boolean As
v_Password XXLSL.XXLSL_USER_ACCOUNT.Password%Type;
v_Active XXLSL.XXLSL_USER_ACCOUNT.Active%Type;
v_Email XXLSL.XXLSL_USER_ACCOUNT.Email%Type;
Begin
If p_User_Name Is Null Or p_Password Is Null Then
        -- Write to Session, Notification must enter a username and password
        Apex_Util.Set_Session_State('LOGIN_MESSAGE'
                                   ,'Please enter Username and password.');
        Return False;
     End If;
     ----
     Begin
        Select u.Active
              ,u.Password
              ,u.Email
        Into   v_Active
              ,v_Password
              ,v_Email
        From   XXLSL_USER_ACCOUNT u
        Where  u.User_Name = p_User_Name;
     Exception
        When No_Data_Found Then
      
           -- Write to Session, User not found.
           Apex_Util.Set_Session_State('LOGIN_MESSAGE'
                                      ,'User not found');
           Return False;
     End;
     If v_Password <> p_Password Then
    
        -- Write to Session, Password incorrect.
        Apex_Util.Set_Session_State('LOGIN_MESSAGE'
                                   ,'Password incorrect');
        Return False;
     End If;
     If v_Active <> 'Y' Then
        Apex_Util.Set_Session_State('LOGIN_MESSAGE'
                                   ,'User locked, please contact admin');
        Return False;
     End If;
     ---
     -- Write user information to Session.
     --
     Apex_Util.Set_Session_State('SESSION_USER_NAME'
                                ,p_User_Name);
     Apex_Util.Set_Session_State('SESSION_EMAIL'
                                ,v_Email);
     ---
     ---
     Return True;
  End;
 
  --------------------------------------
Procedure Process_Login(p_User_Name Varchar2
                         ,p_Password  Varchar2
                         ,p_App_Id    Number) As
     v_Result Boolean := False;
  Begin
     v_Result := Authenticate_User(p_User_Name
                                  ,p_Password);
     If v_Result = True Then
        -- Redirect to Page 1 (Home Page).
        Wwv_Flow_Custom_Auth_Std.Post_Login(p_User_Name -- p_User_Name
                                           ,p_Password -- p_Password
                                           ,v('APP_SESSION') -- p_Session_Id
                                           ,p_App_Id || ':1' -- p_Flow_page
                                            );
     Else
        -- Login Failure, redirect to page 101 (Login Page).
        Owa_Util.Redirect_Url('f?p=&APP_ID.:101:&SESSION.');
     End If;
  End;
 
End XXLSL_Pkg_Security;
/

select *
from all_objects
where UPPER(OBJECT_NAME) = UPPER('XXLSL_Pkg_Security');