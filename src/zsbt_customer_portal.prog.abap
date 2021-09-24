*&---------------------------------------------------------------------*
*& Report ZSBT_CUSTOMER_PORTAL
*&---------------------------------------------------------------------*
*& This Report starts the customer portal
*&---------------------------------------------------------------------*
REPORT zsbt_customer_portal.

CONSTANTS: lc_logobject TYPE bal_s_log-object VALUE 'ZSBT',
           lc_subobjec  TYPE bal_s_log-subobject VALUE 'ZUBT'.

TRY.
    "start the application
    NEW zcl_sbt_customer_login_cntrl( )->start( ).

  CATCH zcx_sbt_web_shop_exception INTO DATA(lo_exc).

    "logg error message and save in db
    DATA(lo_log) = NEW zcl_sbt_web_shop_log( iv_object = lc_logobject
                                              iv_suobj = lc_subobjec ).
    lo_log->add_msg( is_message = lo_exc->get_message( ) ).
    lo_log->safe_log( ).
    "output error message
    MESSAGE lo_exc.
    "If a Exception comes up in the Login oder Register Screen restart application
    SUBMIT zsbt_customer_portal.

ENDTRY.
