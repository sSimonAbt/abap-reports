FUNCTION zsbt_dlg_item_selection.
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  IMPORTING
*"     REFERENCE(IO_HOME_SCREEN_VIEW) TYPE REF TO
*"        ZCL_SBT_HOME_SCREEN_VIEW
*"----------------------------------------------------------------------

go_home_screen_view = IO_HOME_SCREEN_VIEW.

  CALL SCREEN 9000.


ENDFUNCTION.
