*----------------------------------------------------------------------*
***INCLUDE LZSBT_DLG_INBOUND_DELIVERYI02.
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_9001  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_9001 INPUT.

  go_login_view->pai_putaway_article( iv_article_number = gv_article_number ).

ENDMODULE.
