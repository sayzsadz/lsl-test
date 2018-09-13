create or replace trigger sales_summary_id_trg
   before insert on sales_summary
   for each row
   begin
     if :new.saleSummaryID is null then
        select saleSummaryID_seq.nextval into :new.saleSummaryID from sys.dual;
     end if;
   end;