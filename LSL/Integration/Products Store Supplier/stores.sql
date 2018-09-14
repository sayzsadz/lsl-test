CREATE OR REPLACE function check_supplier (p_data  IN  BLOB) return varchar2
AS
lv_StoreId number;
v_msg         varchar2(20);
BEGIN

SELECT STOREID
INTO lv_StoreId
FROM STORE
WHERE STOREID in (
SELECT StoreId
FROM 
     JSON_TABLE(
p_data
     , '$[*]' COLUMNS (
      StoreId NUMBER PATH '$.StoreId'

))
);
    select 'successful operation'
    into v_msg
    from dual;
EXCEPTION
  WHEN OTHERS THEN
    select 'unsuccessful operation'
    into v_msg
    from dual;
    
    return v_msg;
END;     
/

  
BEGIN
  ords.define_template(p_module_name => 'lslmodule1.v1',
                       p_pattern     => 'store/',
                       p_comments    => 'check store');

  COMMIT;
END;
/
begin
  ORDS.define_handler(
    p_module_name    => 'lslmodule1.v1',
    p_pattern        => 'store/',
    p_method         => 'POST',
    p_source_type    => ORDS.source_type_plsql,
    p_source         => 'check_supplier(p_data => :body);',
    p_items_per_page => 1);

  COMMIT;
END;
/