*----------------------------------------------------------------------*
***INCLUDE LZSBT_DLG_HOME_SCREENO03.
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Module STATUS_9003 OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE status_9003 OUTPUT.
 SET PF-STATUS 'STATUS9003'.
 SET TITLEBAR 'BESTELLÜBERSICHT'.

go_order_overview_view->order_overview_pbo( ).

ENDMODULE.
