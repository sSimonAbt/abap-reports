*----------------------------------------------------------------------*
***INCLUDE LZSBT_DLG_CUSTOMER_LOGINO01.
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Module STATUS_9000 OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE status_9000 OUTPUT.

  SET PF-STATUS '9000'.
  SET TITLEBAR 'Login Screen'.

  go_login_view->mo_customer_login_cntrl->on_pbo_login_screen( ).

ENDMODULE.