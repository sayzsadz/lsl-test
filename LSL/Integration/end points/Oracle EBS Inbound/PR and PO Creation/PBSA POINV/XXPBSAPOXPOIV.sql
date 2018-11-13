REM +======================================================================+ 
REM |    Copyright (c) 2005, 2013 Oracle and/or its affiliates.           | 
REM |                         All rights reserved.                         | 
REM |                           Version 12.0.0                             | 
REM +======================================================================+ 
REM $Header: POXPOIV.sql 120.0.12020000.3 2013/12/19 01:15:44 honwei ship $
set doc off
/*******************************************************************/
/* FILENAME: POXPOIV.sql					   */
/*								   */
/* DESCRIPTION:							   */
/* 	This SQL script is used to run the Pay On Receipt program  */
/* through the Standard Report Submissions.			   */
/*								   */
/* PARAMETERS:							   */
/*	   1     -- transaction_source (either ASBN or ERS)	   */
/*	   2	 -- commit interval				   */
/*	   3     -- receipt_num					   */
/* CHANGE HISTORY:						   */
/*	5/6/96		KKCHAN		Created			   */
/*	9/25/96		GTUMMALA	Source controlling under8.0*/
/*******************************************************************/
REM dbdrv:none
-- SET serveroutput ON
SET feedback OFF
SET VERIFY OFF
WHENEVER SQLERROR EXIT FAILURE ROLLBACK;

DECLARE
     X_progress 		VARCHAR2(3);
     X_shipment_header_id	NUMBER;
BEGIN
    
    -- bug 994335 , the concurrent program passes the shipment_header_id 

    asn_debug.put_line('Shipment Header ID from runtime parameter = ' || TO_CHAR(X_shipment_header_id));

    /*** begin processing ***/
    xxpbsapo_invoices_sv1.create_ap_invoices('&&1', '&&2', '&&3', '&&4', '&&5');--Bug 17972946

EXCEPTION
WHEN others THEN 
     po_message_s.sql_error('XXPBSAPOXPOIV.sql', X_progress, sqlcode);
     po_message_s.sql_show_error;
     --dbms_output.put_line(substr(fnd_message.get,1,255));
     fnd_file.put_line(fnd_file.log,fnd_message.get);
     RAISE;
END;
/
/*** We can call the interface errors report here ***/
COMMIT;
EXIT;

