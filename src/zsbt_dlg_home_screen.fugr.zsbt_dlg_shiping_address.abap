FUNCTION zsbt_dlg_shiping_address.
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  IMPORTING
*"     REFERENCE(IO_ADDRESS_VIEW) TYPE REF TO
*"        ZCL_SBT_ALTERNATIV_ADDRESS
*"----------------------------------------------------------------------

go_address_view = io_address_view.

  CALL SCREEN 9002.


ENDFUNCTION.
