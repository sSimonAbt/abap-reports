*----------------------------------------------------------------------*
***INCLUDE LZSBT_WEB_SHOPI03.
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_9003  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_9003 INPUT.

"Wenn User eine kleinere Bestellmenge als 0 eingibt
  IF p_ein < 0.
    MESSAGE i037(zsbt_web_shop) INTO DATA(ls_msg).
    RAISE EXCEPTION TYPE zcx_sbt_web_shop_exception USING MESSAGE.
  ELSE.
    go_web_shop->popup_edit_menge_pai( iv_menge = p_ein ).
  ENDIF.

ENDMODULE.
