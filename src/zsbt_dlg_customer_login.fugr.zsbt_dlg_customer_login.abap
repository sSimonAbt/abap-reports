FUNCTION ZSBT_DLG_CUSTOMER_LOGIN.
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  IMPORTING
*"     REFERENCE(IO_CUSTOMER_LOGIN_VIEW) TYPE REF TO
*"        ZCL_SBT_CUSTOMER_LOGIN_VIEW
*"----------------------------------------------------------------------

go_login_view = io_customer_login_view.

call screen 9000.


ENDFUNCTION.
