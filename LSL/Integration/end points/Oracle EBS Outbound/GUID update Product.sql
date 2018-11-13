create or replace procedure XXPBSA_UPDATE_PRODUCT_GUID(p_data varchar2)
as
    l_return_status VARCHAR2(10);
    l_msg_count NUMBER;
    l_msg_data VARCHAR2(1000);
    
    cursor cur is
    
                        SELECT PartNumber
                             , ProductId
                        FROM 
                             JSON_TABLE(
                             p_data
                             , '$' COLUMNS (
                              PartNumber varchar2(30) PATH '$.PartNumber',
                              ProductId    varchar2(100) PATH '$.ProductId'
                              )
                        ) JT;

BEGIN

    
    for cur_rec in cur
    loop   
    begin    
    
    update mtl_system_items_b
    set attribute10 = cur_rec.ProductId
    where segment1 = cur_rec.PartNumber;

    COMMIT;    

  exception
    when others then
      dbms_output.put_line(''||sqlerrm);
    
    end;
    
    end loop;
    
    dbms_output.put_line('return_status: '||l_return_status);
    dbms_output.put_line('msg_data: '||l_msg_data);
END;
/