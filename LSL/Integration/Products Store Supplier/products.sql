CREATE OR REPLACE function check_product (p_data  IN  BLOB) return varchar2
AS
lv_PRODUCTID number;
v_msg         varchar2(20);
BEGIN

SELECT PRODUCTID
INTO lv_PRODUCTID
FROM PRODUCT
WHERE PRODUCTID in (
SELECT PRODUCTID
FROM 
     JSON_TABLE(
p_data
     , '$[*]' COLUMNS (
      ProductId NUMBER PATH '$.ProductId'

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
  ords.define_template(p_module_name => 'lslmodule2.v1',
                       p_pattern     => 'product/',
                       p_comments    => 'check product');

  COMMIT;
END;
/
begin
  ORDS.define_handler(
    p_module_name    => 'lslmodule2.v1',
    p_pattern        => 'product/',
    p_method         => 'POST',
    p_source_type    => ORDS.source_type_plsql,
    p_source         => 'check_product(p_data => :body);',
    p_items_per_page => 1);

  COMMIT;
END;
/