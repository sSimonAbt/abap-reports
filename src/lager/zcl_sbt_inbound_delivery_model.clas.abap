class ZCL_SBT_INBOUND_DELIVERY_MODEL definition
  public
  final
  create public .

public section.

  data MO_LOG type ref to ZCL_SBT_WEB_SHOP_LOG .

  methods CONSTRUCTOR
    importing
      !IO_LOG type ref to ZCL_SBT_WEB_SHOP_LOG
      !IO_CONTROLLER type ref to ZCL_SBT_INBOUND_DELIVERY_CNTRL .
  methods SET_ARTICLE_NUMBER_AND_PROOF
    importing
      !IV_ARTICLE_NUMBER type ZSBT_ARTIKELNUMMER_DE
    returning
      value(RV_EXISTS) type ABAP_BOOL .
  methods SEARCH_PRODUCT_ON_STRG_PLACE
    exporting
      !EV_WAREHOUSE type ZSBT_LGNUM_DE
      !EV_STORAGE_PLACE type ZSBT_LGPLATZ_DE
      !EV_STORAGE_AREA type ZSBT_LGBER_DE .
  methods SET_AND_COMPARE_STR_PLACE_SCAN
    importing
      !IV_STORAGE_PLACE type ZSBT_LGPLATZ_DE
    returning
      value(RV_PLACES_ARE_EQ) type ABAP_BOOL .
  methods SET_QUANTITY_AND_MEINS
    importing
      !IV_QUANTITY type ZSBT_ZSBT_MENGE_DE
      !IV_MEINS type ZSBT_MEINS_DE .
  methods SAVE_AND_COMMIT .
  methods SET_WAREHOUSENUMBER
    importing
      !IV_WAREHOUSE type ZSBT_LGNUM_DE .
  methods CHECK_USER_AND_PASSWORD
    importing
      !IV_WAREHOUSENUM type ZSBT_LGNUM_DE
      !IV_USERID type ZSBT_USERID_DE
      !IV_PASSWORD type ZSBT_PASSWORT_DE .
  PROTECTED SECTION.
  PRIVATE SECTION.

    DATA mv_article_number TYPE zsbt_artikelnummer_de .
    DATA mo_controller TYPE REF TO zcl_sbt_inbound_delivery_cntrl .
    DATA mv_warehousenumber TYPE zsbt_lgnum_de .
    DATA mv_storage_place_scan TYPE zsbt_lgplatz_de.
    DATA mv_storage_place TYPE zsbt_lgplatz_de.
    DATA mv_quantity TYPE zsbt_zsbt_menge_de.
    DATA mv_meins TYPE zsbt_meins_de.
    DATA mv_article_in_wh TYPE abap_bool.
    DATA: mv_storage_area TYPE zsbt_db_lager-lagerbereich.

    METHODS search_product_in_wh.
    METHODS save_product_on_storage_place .
ENDCLASS.



CLASS ZCL_SBT_INBOUND_DELIVERY_MODEL IMPLEMENTATION.


  METHOD check_user_and_password.

    SELECT SINGLE passwort
     FROM zsbt_db_lager_ma
     WHERE lagernummer = @iv_warehousenum
          AND   userid = @iv_userid
    INTO @DATA(lv_password).

    IF sy-subrc <> 0.
      MESSAGE i070(zsbt_web_shop) INTO DATA(lv_message).
      me->mo_log->add_msg_from_sys(  ).
      RETURN.
    ENDIF.

    IF iv_password <> lv_password.
      MESSAGE i071(zsbt_web_shop) INTO lv_message.
      RAISE EXCEPTION TYPE zcx_sbt_web_shop_exception USING MESSAGE.
    ENDIF.

    me->set_warehousenumber( iv_warehouse = iv_warehousenum ).
    me->mo_controller->mo_view->call_dynpro_putaway_article( ).

  ENDMETHOD.


  METHOD constructor.

    me->mo_log = io_log.
    me->mo_controller = io_controller.

  ENDMETHOD.


  METHOD save_and_commit.

    "Falls schon das Produkt vorhanden ist muss die Menge natürlich addiert werden
    SELECT SINGLE FROM zsbt_db_lager
      FIELDS bestand, mengeneinheit
      WHERE lagerbereich  = @me->mv_storage_area
        AND lagerplatz    = @me->mv_storage_place
        AND lagernummer   = @me->mv_warehousenumber
        AND produkt       = @me->mv_article_number
       INTO @DATA(ls_quantity_meins).

    IF sy-subrc = 0 AND me->mv_meins = ls_quantity_meins-mengeneinheit.
      mv_quantity = mv_quantity + ls_quantity_meins-bestand.
    ELSEIF sy-subrc = 0 AND me->mv_meins <> ls_quantity_meins-mengeneinheit.
      "Fehler Mengeneinheit stimmt nicht überein
      MESSAGE e083(zsbt_web_shop) INTO DATA(lv_message).
      RAISE EXCEPTION TYPE zcx_sbt_web_shop_exception USING MESSAGE.
    ENDIF.

    "Produkt auf Lagerplatz updaten
    DATA(ls_lager) = VALUE zsbt_db_lager( lagerbereich  = me->mv_storage_area
                                          lagerplatz    = me->mv_storage_place
                                          lagernummer   = me->mv_warehousenumber
                                          produkt       = me->mv_article_number
                                          bestand       = me->mv_quantity
                                          mengeneinheit = me->mv_meins ).

    UPDATE zsbt_db_lager FROM ls_lager.

    IF sy-subrc <> 0.
      ROLLBACK WORK.
      MESSAGE e077(zsbt_web_shop) INTO lv_message.
      me->mo_log->add_msg_from_sys( ).
      RAISE EXCEPTION TYPE zcx_sbt_web_shop_exception USING MESSAGE.
    ENDIF.

    COMMIT WORK AND WAIT.

  ENDMETHOD.


  METHOD save_product_on_storage_place.

    "User scannt den Lagerplatz auf den der Artikel final gelagert wird
    "Überprüfen ob der Lagerplatz auch der ist der ihme Vorgeschlagen wurde
    "falls nicht -> Pop-UP
    "Überprüfen ob das möglich ist  wenn nicht Fehlermeldung
    "Ansonsten Speicher der Ware auf dem Lagerplatz oder Menge erhöhen falls das Produkt schon vorhanden ist
    "Meldung an den User

  ENDMETHOD.


  METHOD search_product_in_wh.

    "sucht ob das Produkt auf einen Lagerplatz vorhanden ist
    SELECT SINGLE FROM zsbt_db_lager
      FIELDS lagerbereich, lagerplatz
          WHERE produkt     = @me->mv_article_number
            AND lagernummer = @me->mv_warehousenumber
      INTO @DATA(ls_storage_place).

    mv_storage_area  = ls_storage_place-lagerbereich.
    mv_storage_place = ls_storage_place-lagerplatz.

    IF sy-subrc <> 0.
      CLEAR ls_storage_place.
      "es wurde kein Platz gefunden es muss ein neuer vorgeschlagen werden
      MESSAGE e072(zsbt_web_shop) INTO DATA(lv_message).
      me->mo_log->add_msg_from_sys( ).
      me->mv_article_in_wh = abap_false.
    ELSE.
      "es wurden ein Artikel mit Lagerplatz gefunden.
      MESSAGE s073(zsbt_web_shop) INTO lv_message.
      me->mo_log->add_msg_from_sys( ).
      me->mv_article_in_wh = abap_true.
    ENDIF.

  ENDMETHOD.


  METHOD search_product_on_strg_place.

    "Programmablauf
    me->search_product_in_wh( ).

    IF  me->mv_article_in_wh = abap_true.
      ev_storage_area        = me->mv_storage_area.
      ev_storage_place       = me->mv_storage_place.
      ev_warehouse           = me->mv_warehousenumber.
      RETURN.
    ENDIF.

    "Ansonsten suchen wir hier einen neuen freien Lageplatz
    SELECT SINGLE FROM zsbt_db_lager
      FIELDS lagerbereich, lagerplatz
        WHERE lagernummer = @me->mv_warehousenumber
        AND produkt = ''
        OR  bestand = ''
      INTO (@me->mv_storage_area, @me->mv_storage_place).

    IF sy-subrc <> 0.
      MESSAGE e080(zsbt_web_shop) INTO DATA(lv_message).
      RAISE EXCEPTION TYPE zcx_sbt_web_shop_exception USING MESSAGE.
    ENDIF.

    ev_warehouse     = mv_warehousenumber.
    ev_storage_place = me->mv_storage_place.
    ev_storage_area  = me->mv_storage_area.

  ENDMETHOD.


  METHOD set_and_compare_str_place_scan.

    me->mv_storage_place_scan = iv_storage_place.

    "Compare SCAN with our searched storage place
    IF me->mv_storage_place <> me->mv_storage_place.
      "if there are not the same
      MESSAGE e074(zsbt_web_shop) INTO DATA(lv_message).
      me->mo_log->add_msg_from_sys( ).
      rv_places_are_eq = abap_true.
    ELSE.
      MESSAGE s075(zsbt_web_shop) INTO lv_message.
      rv_places_are_eq = abap_false.
    ENDIF.

  ENDMETHOD.


  METHOD set_article_number_and_proof.

    "Proof if Article exists
    SELECT SINGLE @abap_true
    FROM zsbt_artikel
    INTO @rv_exists
    WHERE artikelnummer = @iv_article_number.

    IF rv_exists = abap_true.
      me->mv_article_number = iv_article_number.
      MESSAGE s076(zsbt_web_shop) INTO DATA(lv_message).
      me->mo_log->add_msg_from_sys( ).
    ELSE.
      MESSAGE s077(zsbt_web_shop) INTO lv_message.
      me->mo_log->add_msg_from_sys( ).
    ENDIF.

  ENDMETHOD.


  METHOD set_quantity_and_meins.

    me->mv_quantity = iv_quantity.
    me->mv_meins = iv_meins.

  ENDMETHOD.


  METHOD set_warehousenumber.

    me->mv_warehousenumber = iv_warehouse.

  ENDMETHOD.
ENDCLASS.
