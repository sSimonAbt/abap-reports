*&---------------------------------------------------------------------*
*& Report ZSBT_TEST_DELETE
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT zsbt_test_delete.

DATA ls_egal TYPE zsbt_customer.

*ls_egal
SELECT *
  FROM zsbt_customer
  INTO  @DATA(ls_table).

  WRITE: ls_table-customer_number, ls_table-email, ls_table-first_name, ls_table-house_number, ls_table-name, ls_table-password, ls_table-city.

ENDSELECT.

*delete zsbt_customer from TABLE lt_table.

SELECT *
  FROM zsbt_db_lager_ma
  INTO TABLE @DATA(lt_table).

DELETE zsbt_db_lager_ma FROM TABLE lt_table.
