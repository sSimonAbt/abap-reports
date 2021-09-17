*&---------------------------------------------------------------------*
*& Report ZSBT_TEST_WEB_SHOP
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT zsbt_test_web_shop.

DATA: lv_password TYPE string VALUE 'PASSWORT'.

cl_abap_message_digest=>calculate_hash_for_char( EXPORTING if_data       = lv_password
                                                         IMPORTING ef_hashstring = DATA(rv_password_as_hash) ).


DATA(ls_user) = VALUE zsbt_db_lager_ma( lagernummer = 'WU01' passwort = rv_password_as_hash userid = '03' ).

INSERT zsbt_db_lager_ma FROM ls_user.

IF sy-subrc <> 0.
  ROLLBACK WORK.
ELSE.
  COMMIT WORK.
ENDIF.

WRITE sy-subrc.
