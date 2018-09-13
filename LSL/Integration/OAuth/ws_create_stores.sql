

CREATE OR REPLACE PROCEDURE create_store (p_data  IN  BLOB)
AS
BEGIN

  INSERT INTO STORE (STOREID, COMPANYNAME, ACTIVE, CREATIONDATE, MODIFIEDDATE)
    SELECT j.*, SYSDATE AS CREATIONDATE, SYSDATE AS MODIFIEDDATE
    FROM   json_table(p_data FORMAT JSON, '$'
           COLUMNS (
             StoreId  NUMBER   PATH '$.StoreId',
             CompanyName   VARCHAR2 PATH '$.CompanyName',
             Active   VARCHAR2 PATH '$.Active')) j;

  COMMIT;

EXCEPTION
  WHEN OTHERS THEN
    HTP.print(SQLERRM);
END;




BEGIN
       
  ords.define_module(p_module_name    => 'lslmodule1.v1',
                     p_base_path      => 'lslmodule1/v1/',
                     p_items_per_page => 5,
                     p_status         => 'PUBLISHED',
                     p_comments       => 'lslmodule1 create store Module');             
  COMMIT;
END;
  

BEGIN
  ords.define_template(p_module_name => 'lslmodule1.v1',
                       p_pattern     => 'stores/',
                       p_comments    => 'lslmodule1 create store Module ');

  COMMIT;
END;

begin
  ORDS.define_handler(
    p_module_name    => 'lslmodule1.v1',
    p_pattern        => 'stores/',
    p_method         => 'POST',
    p_source_type    => ORDS.source_type_plsql,
    p_source         => 'BEGIN
                           create_store(p_data => :body);
                         END;',
    p_items_per_page => 0);

  COMMIT;
END;


https://13.67.34.43:8443/ords/api/lslmodule1/v1/stores/

select * from store

{
  "StoreId": 123,
  "CompanyName": "Kohuwala",
  "Active": "ACT"
}
