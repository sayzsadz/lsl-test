create or replace function XXPBSA_GET_GL_ACCOUNT(p_acc in varchar2)
return varchar2
AS
      l_acc_desc       varchar2(500) := 'Lanka Sathosa Ltd.Ampara.Unspecified.Biscuits.Unspecified.Sales - Grocery Products.Unspecified.Unspecified';
      l_acc            varchar2(500);
begin
          
          l_acc := p_acc;
          
          SELECT distinct (gcc.segment1
                ||'.'||gcc.segment2
                ||'.'||gcc.segment3
                ||'.'||gcc.segment4
                ||'.'||gcc.segment5
                ||'.'||gcc.segment6
                ||'.'||gcc.segment7
                ||'.'||gcc.segment8
                ||'.'||gcc.segment9)
                gcc
          into l_acc
          FROM  gl_code_combinations gcc
               ,(select DECODE(gcc.segment1,NULL,'',apps.gl_flexfields_pkg.get_description_sql
                                                                 (gcc.chart_of_accounts_id,1,gcc.segment1))
             ||'.'||DECODE(gcc.segment2,NULL,'',apps.gl_flexfields_pkg.get_description_sql
                                                                ( gcc.chart_of_accounts_id,2,gcc.segment2)) 
             ||'.'||DECODE(gcc.segment3,NULL,'',apps.gl_flexfields_pkg.get_description_sql
                                                                 (gcc.chart_of_accounts_id,3,gcc.segment3))
             ||'.'||DECODE(gcc.segment4,NULL,'',apps.gl_flexfields_pkg.get_description_sql
                                                                ( gcc.chart_of_accounts_id,4,gcc.segment4))
             ||'.'||DECODE(gcc.segment5,NULL,'',apps.gl_flexfields_pkg.get_description_sql
                                                                ( gcc.chart_of_accounts_id,5,gcc.segment5))
             ||'.'||DECODE(gcc.segment6,NULL,'',apps.gl_flexfields_pkg.get_description_sql
                                                               ( gcc.chart_of_accounts_id,6,gcc.segment6))
             ||'.'||DECODE(gcc.SEGMENT7,NULL,'',apps.gl_flexfields_pkg.get_description_sql
                                                               ( gcc.chart_of_accounts_id,7,gcc.segment7))
             ||'.'||DECODE(gcc.SEGMENT8,NULL,'',apps.gl_flexfields_pkg.get_description_sql
                                                               ( gcc.chart_of_accounts_id,8,gcc.segment9))
            gcc,
            gcc.segment1,
            gcc.segment2,
            gcc.segment3,
            gcc.segment4,
            gcc.segment5,
            gcc.segment6,
            gcc.segment7,
            gcc.segment8
from gl_code_combinations gcc) glc
          where glc.gcc = l_acc_desc
                and GLC.SEGMENT1 = GCC.SEGMENT1
                and GLC.SEGMENT2 = GCC.SEGMENT2
                and GLC.SEGMENT3 = GCC.SEGMENT3
                and GLC.SEGMENT4 = GCC.SEGMENT4
                and GLC.SEGMENT5 = GCC.SEGMENT5
                and GLC.SEGMENT6 = GCC.SEGMENT6
                and GLC.SEGMENT7 = GCC.SEGMENT7
                and GLC.SEGMENT8 = GCC.SEGMENT8;
    return l_acc;
end;
/