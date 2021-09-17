CLASS zcl_sbt_web_shop_model DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    TYPES:
      t_table TYPE STANDARD TABLE OF zsbt_besttelung WITH DEFAULT KEY .
    TYPES:
      tty_ansicht TYPE STANDARD TABLE OF zsbt_s_bestellungen WITH DEFAULT KEY .

    DATA mt_bestellungen_ansicht TYPE tty_ansicht .

    METHODS delete_position
      IMPORTING
        !is_position TYPE zsbt_besttelung .
    METHODS edit_postition
      IMPORTING
        !iv_wert     TYPE any
        !is_position TYPE zsbt_besttelung .
    METHODS delete_order
      IMPORTING
        !iv_bestellnummer TYPE zsbt_bestellnummer_de .
*    raising
*      ZCX_SBT_WEB_SHOP_EXCEPTION
    METHODS get_bestellungen
      RETURNING
        VALUE(rt_bestellungen) TYPE t_table .
*    raising
*      ZCX_SBT_WEB_SHOP_EXCEPTION
    METHODS get_information
      IMPORTING
        VALUE(iv_filter)        TYPE i OPTIONAL
        VALUE(iv_kundennummer)  TYPE zsbt_kd_numr_de OPTIONAL
        VALUE(iv_bestellnummer) TYPE zsbt_bestellnummer_de OPTIONAL
        VALUE(iv_status)        TYPE zsbt_status_de OPTIONAL .
*    raising
*      ZCX_SBT_WEB_SHOP_EXCEPTION
    METHODS get_positions
      IMPORTING
        !iv_bestellnummer TYPE zsbt_bestellnummer_de .
*    raising
*      ZCX_SBT_WEB_SHOP_EXCEPTION
    METHODS get_positions_ausgabe
      RETURNING
        VALUE(rt_positionen) TYPE t_table .
*    raising
*      ZCX_SBT_WEB_SHOP_EXCEPTION
    METHODS get_bestellungenansicht
      RETURNING
        VALUE(rt_bestellungen) TYPE tty_ansicht .
*    raising
*      ZCX_SBT_WEB_SHOP_EXCEPTION
    METHODS get_ansicht
      RETURNING
        VALUE(rt_ansicht) TYPE tty_ansicht .
  PROTECTED SECTION.
  PRIVATE SECTION.

    DATA mt_bestellungen TYPE t_table .
    DATA mt_positionen TYPE t_table .
ENDCLASS.



CLASS ZCL_SBT_WEB_SHOP_MODEL IMPLEMENTATION.


  METHOD delete_order.

    DELETE FROM zsbt_bestellung WHERE bestellnummer = iv_bestellnummer.
    IF sy-subrc <> 0.
      MESSAGE i033(zsbt_web_shop) INTO DATA(ls_msg).
      RAISE EXCEPTION TYPE zcx_sbt_web_shop_exception USING MESSAGE.
    ENDIF.

  ENDMETHOD.


  METHOD delete_position.

    DELETE FROM zsbt_bestellung WHERE bestellnummer = is_position-bestellnummer AND positionsnummer = is_position-positionsnummer.
    IF sy-subrc <> 0.
      MESSAGE i035(zsbt_web_shop) INTO DATA(ls_msg).
      RAISE EXCEPTION TYPE zcx_sbt_web_shop_exception USING MESSAGE.
    ENDIF.

  ENDMETHOD.


  METHOD edit_postition.

    DATA(ls_position) = is_position.
    DATA(lv_column_type) = cl_abap_typedescr=>describe_by_data( iv_wert )->absolute_name.
    DATA(lv_rest_strlen) = strlen( lv_column_type ) - 6.
    DATA(lt_ddic) = CAST cl_abap_structdescr( cl_abap_typedescr=>describe_by_data( ls_position ) )->get_ddic_object( ).

    "Type richtig -> Komponente finden Typ: lv_nam+6(lv_strlen) -> Komponenten Feld-Symbol zuweisen / Komponente mithilfe des Feld-Symbols möglich zu bearbeiten
    ASSIGN COMPONENT lt_ddic[ rollname = lv_column_type+6(lv_rest_strlen) ]-fieldname OF STRUCTURE ls_position TO FIELD-SYMBOL(<ls_position>).
    IF <ls_position> IS ASSIGNED.
      <ls_position> = iv_wert.
    ELSE.
      MESSAGE i035(zsbt_web_shop) INTO DATA(ls_msg).
      RAISE EXCEPTION TYPE zcx_sbt_web_shop_exception USING MESSAGE.
    ENDIF.

    UPDATE zsbt_bestellung FROM ls_position.

    IF sy-subrc NE 0.
      ROLLBACK WORK.
      MESSAGE i035(zsbt_web_shop) INTO ls_msg.
      RAISE EXCEPTION TYPE zcx_sbt_web_shop_exception USING MESSAGE.
    ELSE.
      COMMIT WORK AND WAIT.
    ENDIF.

  ENDMETHOD.


  METHOD get_ansicht.

    rt_ansicht = me->mt_bestellungen_ansicht.

  ENDMETHOD.


  METHOD get_bestellungen.

    rt_bestellungen = me->mt_bestellungen.

  ENDMETHOD.


  METHOD get_bestellungenansicht.

    DATA:  lt_bestellungen   TYPE TABLE OF zsbt_besttelung
          ,ls_bestellungen   TYPE          zsbt_besttelung
          ,ls_zwischen       TYPE          zsbt_besttelung
          ,lv_preis_artikel  TYPE          zsbt_preis_de
          ,lv_gesamtpreis    TYPE          p
          ,lt_ansicht        TYPE TABLE OF zsbt_s_bestellungen
          ,ls_ansicht        TYPE          zsbt_s_bestellungen
          ,lv_zaehler        TYPE          i
            .

    lt_bestellungen = me->mt_bestellungen.


    LOOP AT lt_bestellungen INTO ls_zwischen.

      "Holt Preis zu Aktuellen Produkt
      SELECT SINGLE preis
        FROM zsbt_artikel
        INTO lv_preis_artikel
        WHERE artikelnummer = ls_zwischen-artikel.

      IF ls_bestellungen-bestellnummer = ls_zwischen-bestellnummer.
        lv_gesamtpreis = lv_preis_artikel * ls_zwischen-bestellmenge + lv_gesamtpreis.

        "Sobald eine neue Bestellung beginnt bisherige Bestellung in Tabelle
      ELSEIF ls_bestellungen IS  NOT INITIAL AND ls_bestellungen-bestellnummer <> ls_zwischen-bestellnummer.

        ls_ansicht-bestellnummer = ls_bestellungen-bestellnummer.
        ls_ansicht-bestellwert   = lv_gesamtpreis.
        ls_ansicht-waehrung      = '€'.
        ls_ansicht-status        = ls_bestellungen-status.
        ls_ansicht-kundennumer   = ls_bestellungen-kunde.

        APPEND ls_ansicht TO lt_ansicht.
        CLEAR ls_ansicht.


        lv_gesamtpreis = lv_preis_artikel * ls_zwischen-bestellmenge.

      ELSE.
        CLEAR lv_gesamtpreis.
        lv_gesamtpreis = lv_preis_artikel * ls_zwischen-bestellmenge.


      ENDIF.

      "Datenüberschreiben für Vergleich bei mehreren Loops über Bestellung
      ls_bestellungen = ls_zwischen.

      lv_zaehler = lv_zaehler + 1.

    ENDLOOP.

    ls_ansicht-bestellnummer = ls_bestellungen-bestellnummer.
    ls_ansicht-bestellwert   = lv_gesamtpreis.
    ls_ansicht-waehrung      = '€'.
    ls_ansicht-status        = ls_bestellungen-status.
    ls_ansicht-kundennumer   = ls_bestellungen-kunde.

    APPEND ls_ansicht TO lt_ansicht.
    CLEAR ls_ansicht.


    mt_bestellungen_ansicht = lt_ansicht.


  ENDMETHOD.


  METHOD get_information.

    CLEAR mt_bestellungen.

    IF iv_filter EQ 0.

      "Alle Daten.
      SELECT *
      FROM zsbt_bestellung
      INTO TABLE me->mt_bestellungen.

      "Nach Kundennummer...
    ELSEIF iv_filter EQ 1 AND iv_kundennummer IS NOT INITIAL.
      SELECT *
       FROM zsbt_bestellung
       INTO TABLE me->mt_bestellungen
       WHERE kunde = iv_kundennummer.

      IF sy-subrc = 4.
        MESSAGE i018(zsbt_web_shop).
      ELSEIF sy-subrc <> 0.
        MESSAGE e015(zsbt_web_shop).
      ELSEIF me->mt_bestellungen IS INITIAL.
        MESSAGE:    e025(zsbt_web_shop).
      ENDIF.

      "Nach Bestellnummer...
    ELSEIF iv_filter EQ 2 AND iv_bestellnummer IS NOT INITIAL.
      SELECT *
        FROM zsbt_bestellung
        INTO TABLE me->mt_bestellungen
        WHERE bestellnummer = iv_bestellnummer.
      IF sy-subrc <> 0.
        MESSAGE e016(zsbt_web_shop).
      ENDIF.

      "Nach Bestellstatus...
    ELSEIF iv_filter EQ 3 AND iv_status IS NOT INITIAL.
      SELECT *
        FROM zsbt_bestellung
        INTO TABLE me->mt_bestellungen
        WHERE status EQ iv_status.
      IF sy-subrc <>  0.
        MESSAGE e017(zsbt_web_shop).
      ENDIF.

    ELSE.
      MESSAGE e019(zsbt_web_shop).

    ENDIF.

  ENDMETHOD.


  METHOD get_positions.

    CLEAR me->mt_positionen.

    SELECT *
      FROM zsbt_bestellung
      INTO TABLE mt_positionen
      WHERE bestellnummer = iv_bestellnummer.

  ENDMETHOD.


  METHOD get_positions_ausgabe.

    rt_positionen = me->mt_positionen.

  ENDMETHOD.
ENDCLASS.
