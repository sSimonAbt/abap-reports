*----------------------------------------------------------------------*
***INCLUDE LZSBT_DLG_INBOUND_DELIVERYO02.
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Module STATUS_9002 OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE status_9002 OUTPUT.
* SET PF-STATUS 'xxxxxxxx'.
* SET TITLEBAR 'xxx'.

  go_login_view->pbo_storage_place( IMPORTING ev_warehouse_num =  gv_lagernummer
                                              ev_storage_place =  gv_lagerplatz
                                              ev_storage_area  =  gv_lagerbereich ).

ENDMODULE.
