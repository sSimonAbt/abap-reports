*----------------------------------------------------------------------*
***INCLUDE LZSBT_DLG_INBOUND_DELIVERYI01.
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_9000  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_9000 INPUT.

  go_login_view->login_pai( EXPORTING iv_warehousenum = gs_login_data-lagernummer
                                      iv_userid       = gs_login_data-userid
                                      iv_password     = gs_login_data-passwort ).

ENDMODULE.
