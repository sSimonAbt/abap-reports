FUNCTION z_sbt_web_shop_bestellubersich.
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  IMPORTING
*"     REFERENCE(IM_WEB_SHOP) TYPE REF TO  ZSBT_WEB_SHOP_VIEW
*"----------------------------------------------------------------------

  FREE go_web_shop.
  CLEAR go_web_shop.
  go_web_shop = im_web_shop.




  CALL SCREEN 9001.


ENDFUNCTION.
