FUNCTION zsbt_dlg_order_overview.
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  IMPORTING
*"     REFERENCE(IO_OVERVIEW_VIEW) TYPE REF TO
*"        ZCL_SBT_ORDER_OVERVIEW_VIEW
*"----------------------------------------------------------------------

  go_order_overview_view = io_overview_view.

  CALL SCREEN 9003.

ENDFUNCTION.
