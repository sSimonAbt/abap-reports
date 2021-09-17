FUNCTION-POOL zsbt_dlg_inbound_delivery.    "MESSAGE-ID ..

* INCLUDE LZSBT_DLG_INBOUND_DELIVERYD...     " Local class definition
DATA: go_login_view           TYPE REF TO zcl_sbt_inbound_delivery_view,
      gs_login_data           TYPE zsbt_db_lager_ma,
      gv_article_number       TYPE zsbt_artikelnummer_de,
      go_putaway_article_view TYPE REF TO zcl_sbt_inbound_delivery_view,
      gv_lagernummer          TYPE zsbt_lgnum_de,
      gv_lagerbereich         TYPE zsbt_lgber_de,
      gv_lagerplatz           TYPE zsbt_lgplatz_de,
      gv_storage_place_in     TYPE zsbt_lgplatz_de,
      gv_quantity             TYPE zsbt_zsbt_menge_de,
      gv_meins                TYPE zsbt_meins_de.
