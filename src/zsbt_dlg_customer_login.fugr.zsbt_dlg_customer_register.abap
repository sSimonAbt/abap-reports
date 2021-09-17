FUNCTION zsbt_dlg_customer_register.
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  IMPORTING
*"     REFERENCE(IO_CUSTOMER_REGISTER_VIEW) TYPE REF TO
*"        ZCL_SBT_CUSTOMER_REGISTER_VIEW
*"----------------------------------------------------------------------

go_customer_register_view = io_customer_register_view.

  CALL SCREEN 9001.


ENDFUNCTION.
