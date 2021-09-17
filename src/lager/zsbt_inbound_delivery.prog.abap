*&---------------------------------------------------------------------*
*& Report ZSBT_INBOUND_DELIVERY
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT zsbt_inbound_delivery.

CONSTANTS: lc_logobject TYPE bal_s_log-object    VALUE 'ZSBT',
           lc_subobjec  TYPE bal_s_log-subobject VALUE 'ZUBT'.

"start the application
TRY.

    DATA(lo_log) = NEW zcl_sbt_web_shop_log( iv_object = lc_logobject
                                              iv_suobj = lc_subobjec ).

    NEW zcl_sbt_inbound_delivery_cntrl( io_log = lo_log )->start( ).

  CATCH zcx_sbt_web_shop_exception INTO DATA(lo_exc).

    "logg messages and display in a popup
    lo_log->add_msg( is_message = lo_exc->get_message( ) ).
    lo_log->safe_log( ).
    lo_log->display_log_as_popup( ).

    "start the application new
    SUBMIT zsbt_inbound_delivery.

ENDTRY.
