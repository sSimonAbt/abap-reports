FUNCTION Z_SBT_WEB_SHOP_POSITIONEN.
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  IMPORTING
*"     REFERENCE(IM_WEB_SHOP) TYPE REF TO  ZSBT_WEB_SHOP_VIEW
*"----------------------------------------------------------------------

FREE go_web_shop.
CLEAR go_web_shop.


go_web_shop = im_web_shop.

call screen 9002.



ENDFUNCTION.
