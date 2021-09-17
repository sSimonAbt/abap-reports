FUNCTION ZSBT_DLG_INBOUND_DE_LOGIN.
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  IMPORTING
*"     REFERENCE(IO_VIEW) TYPE REF TO  ZCL_SBT_INBOUND_DELIVERY_VIEW
*"----------------------------------------------------------------------
  go_login_view = io_view.

  CALL SCREEN 9000.

ENDFUNCTION.
