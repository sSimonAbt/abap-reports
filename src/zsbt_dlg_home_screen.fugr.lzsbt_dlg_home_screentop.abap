FUNCTION-POOL zsbt_dlg_home_screen.         "MESSAGE-ID ..

DATA go_home_screen_view TYPE REF TO zcl_sbt_home_screen_view.
* INCLUDE LZSBT_DLG_HOME_SCREEND...          " Local class definition
DATA go_cart_view TYPE REF TO zcl_sbt_cart_view.
DATA p_quantity TYPE zsbt_bestellmenge_de.
DATA p_search TYPE string.
DATA go_address_view TYPE REF TO zcl_sbt_alternativ_address.
DATA p_street TYPE zsbt_strasse_de.
DATA p_house_number TYPE zsbt_hausnummer.
DATA p_zip_code TYPE zsbt_plz_de.
DATA p_address_city TYPE zsbt_ort_de.
DATA go_order_overview_view TYPE REF TO zcl_sbt_order_overview_view.
