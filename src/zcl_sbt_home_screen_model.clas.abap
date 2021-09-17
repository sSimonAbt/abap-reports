CLASS zcl_sbt_home_screen_model DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    DATA:
            mt_order TYPE zsbt_tt_bestellung.
    DATA:
      mt_articles TYPE TABLE OF zsbt_artikel .
    DATA:
      mt_articles_out TYPE TABLE OF zsbt_artikel .
    DATA:
      mt_cart TYPE TABLE OF zsbt_s_cart .

    METHODS search_entries_to_new_table
      IMPORTING
        !iv_search_string TYPE string .
    METHODS order_cart .
    METHODS remove_item_from_cart
      IMPORTING
        !iv_article_number TYPE zsbt_artikelnummer_de .
    METHODS constructor
      IMPORTING
        !io_home_screen_controller TYPE REF TO zcl_sbt_home_screen_controller
        !iv_customer_number        TYPE zsbt_customernumber_de .
    METHODS add_to_cart
      IMPORTING
        !iv_number_of_articles TYPE zsbt_bestellmenge_de
        !is_article            TYPE zsbt_artikel .
    METHODS get_address_of_customer .
    METHODS set_order_address
      IMPORTING
        !is_order_address TYPE zsbt_s_address .
    METHODS return_address
      RETURNING
        VALUE(rv_address) TYPE zsbt_s_address .
    METHODS get_email_address_of_customer
      RETURNING
        VALUE(rv_email) TYPE zsbt_email_de .
    METHODS set_customer_email
      IMPORTING
        iv_email TYPE zsbt_email_de .
    METHODS get_all_orders_from_customer.
    METHODS get_open_order_from_mt_order RETURNING VALUE(rt_openorder) TYPE zsbt_tt_bestellung.
    METHODS get_done_order_from_mt_order
      RETURNING VALUE(rt_done_order) TYPE zsbt_tt_bestellung.
    METHODS get_order
      IMPORTING
        iv_order_number TYPE tv_nodekey
      RETURNING
        VALUE(rt_order) TYPE zsbt_tt_bestellung.
    METHODS delete_position
      IMPORTING is_position TYPE zsbt_bestellung.
    METHODS edit_quantity_of_position IMPORTING is_position TYPE zsbt_bestellung
                                                iv_quantity TYPE int4.
  PROTECTED SECTION.

  PRIVATE SECTION.

    CONSTANTS mc_status_inactive TYPE zsbt_status_de VALUE 'IN' ##NO_TEXT. "Bestellung Inaktive
    CONSTANTS mc_status_completed TYPE zsbt_status_de VALUE 'AB' ##NO_TEXT. "Bestellung Abgeschlossen
    CONSTANTS mc_status_in_progress TYPE zsbt_status_de VALUE 'IB' ##NO_TEXT. "Bestellung in Bearbeitung
    CONSTANTS mc_status_ordered TYPE zsbt_status_de VALUE 'BE' ##NO_TEXT. "Bestellung Bestellt
    CONSTANTS mc_range_nr           TYPE nrnr           VALUE '01' ##NO_TEXT.
    DATA mo_home_screen_controller  TYPE REF TO zcl_sbt_home_screen_controller .
    DATA mv_customernumber          TYPE zsbt_customernumber_de .
    DATA ms_order_address           TYPE zsbt_s_address .
    DATA mv_customer_email          TYPE zsbt_email_de .

    METHODS select_articles .
    METHODS get_ordernumber
      RETURNING
        VALUE(rv_order_number) TYPE numc10 .
    METHODS insert_address_of_order
      IMPORTING
        iv_order_number TYPE numc10 .

ENDCLASS.



CLASS ZCL_SBT_HOME_SCREEN_MODEL IMPLEMENTATION.


  METHOD add_to_cart.

    DATA: lc_status_in_cart TYPE char15 VALUE 'Im Warenkorb'.

    "toDo: Abfrage ob Werte Vollständig sind bzw. ob Rechnung für den Positionspreis ausgeführt werden kann

    DATA(ls_cart) = VALUE zsbt_s_cart( article_number      = is_article-artikelnummer
                                       article_designation = is_article-bezeichnung
                                       article_description = is_article-beschreibung
                                       unit                = is_article-einheit
                                       currency            = is_article-waehrung
                                       number_of_articles  = iv_number_of_articles
                                       price_per_article   = is_article-preis
                                       price               = is_article-preis * iv_number_of_articles
                                       status              = lc_status_in_cart ).

    APPEND ls_cart TO me->mt_cart.

  ENDMETHOD.


  METHOD constructor.

    me->mo_home_screen_controller = io_home_screen_controller.
    me->mv_customernumber         = iv_customer_number.

    me->select_articles( ).

  ENDMETHOD.


  METHOD delete_position.

    TRY.
        "proof if position is not in work
        IF is_position-status = mc_status_in_progress OR is_position-status = mc_status_completed.
          MESSAGE i061(zsbt_web_shop) INTO DATA(ls_msg).
          RAISE EXCEPTION TYPE zcx_sbt_web_shop_exception USING MESSAGE.
        ELSE.
          DELETE me->mo_home_screen_controller->mt_order_to_show WHERE bestellnummer   = is_position-bestellnummer
                                                                   AND positionsnummer = is_position-positionsnummer.
          DELETE zsbt_bestellung FROM is_position.
          IF sy-subrc <> 0.
            MESSAGE i060(zsbt_web_shop) INTO ls_msg.
            RAISE EXCEPTION TYPE zcx_sbt_web_shop_exception USING MESSAGE.
          ENDIF.
        ENDIF.

      CATCH zcx_sbt_web_shop_exception INTO DATA(lo_exc).

        MESSAGE: lo_exc.

    ENDTRY.

  ENDMETHOD.


  METHOD edit_quantity_of_position.

    DATA(ls_position_to_update) = VALUE zsbt_bestellung( BASE is_position bestellmenge = iv_quantity ).

    UPDATE zsbt_bestellung FROM @ls_position_to_update.

    IF sy-subrc <> 0.
      ROLLBACK WORK.
      MESSAGE i068(zsbt_web_shop) INTO DATA(lv_msg).
      RAISE EXCEPTION TYPE zcx_sbt_web_shop_exception USING MESSAGE.
    ENDIF.

    COMMIT WORK.

  ENDMETHOD.


  METHOD get_address_of_customer.

    TRY.
        SELECT SINGLE street house_number zip_code city
          FROM zsbt_customer
          INTO ms_order_address.

        IF sy-subrc <> 0.
          MESSAGE i059(zsbt_web_shop) INTO DATA(ls_msg).
          RAISE EXCEPTION TYPE zcx_sbt_web_shop_exception USING MESSAGE.
        ENDIF.
      CATCH zcx_sbt_web_shop_exception INTO DATA(lo_exc).
        MESSAGE lo_exc.

    ENDTRY.

  ENDMETHOD.


  METHOD get_all_orders_from_customer.

    CLEAR me->mt_order.

    SELECT *
    FROM zsbt_bestellung
    INTO TABLE me->mt_order
    WHERE kunde = mv_customernumber.

  ENDMETHOD.


  METHOD get_done_order_from_mt_order.

    CONSTANTS: lc_status_ab TYPE zsbt_status_de VALUE 'AB',
               lc_status_in TYPE zsbt_status_de VALUE 'IN'.

    SORT me->mt_order BY bestellnummer.

    LOOP AT me->mt_order ASSIGNING FIELD-SYMBOL(<ls_order>) WHERE status = lc_status_ab OR status = lc_status_in.
      APPEND <ls_order> TO rt_done_order.
    ENDLOOP.

    DELETE ADJACENT DUPLICATES FROM rt_done_order.

  ENDMETHOD.


  METHOD get_email_address_of_customer.

    rv_email = me->mv_customer_email.

  ENDMETHOD.


  METHOD get_open_order_from_mt_order.

    CONSTANTS: lc_status_be TYPE zsbt_status_de VALUE 'BE',
               lc_status_ib TYPE zsbt_status_de VALUE 'IB'.

    SORT me->mt_order BY bestellnummer.

    LOOP AT me->mt_order ASSIGNING FIELD-SYMBOL(<ls_order>) WHERE status = lc_status_be OR status = lc_status_ib.
      APPEND <ls_order> TO rt_openorder.

    ENDLOOP.

    DELETE ADJACENT DUPLICATES FROM rt_openorder COMPARING bestellnummer.

  ENDMETHOD.


  METHOD get_order.

    LOOP AT me->mt_order ASSIGNING FIELD-SYMBOL(<ls_position>) WHERE bestellnummer = iv_order_number.

      APPEND <ls_position> TO rt_order.

    ENDLOOP.

  ENDMETHOD.


  METHOD get_ordernumber.

    DATA: lv_ordernumber TYPE n LENGTH 10.

    CALL FUNCTION 'NUMBER_GET_NEXT'
      EXPORTING
        nr_range_nr             = me->mc_range_nr
        object                  = 'ZSBT_BEST'
      IMPORTING
        number                  = lv_ordernumber
      EXCEPTIONS
        interval_not_found      = 1
        number_range_not_intern = 2
        object_not_found        = 3
        quantity_is_0           = 4
        quantity_is_not_1       = 5
        interval_overflow       = 6
        buffer_overflow         = 7
        OTHERS                  = 8.
    IF sy-subrc <> 0.
      MESSAGE i046(zsbt_web_shop) WITH sy-subrc.
    ENDIF.

    rv_order_number = lv_ordernumber.

  ENDMETHOD.


  METHOD insert_address_of_order.

    DATA(ls_order_adress_to_insert) = VALUE zsbt_order_ad(  order_number = iv_order_number
                                                       street       = me->ms_order_address-street
                                                       house_number = me->ms_order_address-houese_number
                                                       zip_code     = me->ms_order_address-zip_code
                                                       city         = me->ms_order_address-city ).

    INSERT zsbt_order_ad FROM ls_order_adress_to_insert.

  ENDMETHOD.


  METHOD order_cart.

    DATA: lt_order TYPE TABLE OF zsbt_bestellung,
          ls_order TYPE zsbt_bestellung.

    DATA(lv_order_number) = me->get_ordernumber( ).

    LOOP AT me->mt_cart ASSIGNING FIELD-SYMBOL(<ls_cart>).

      ls_order = VALUE #( artikel         = <ls_cart>-article_number
                          bestellmenge    = <ls_cart>-number_of_articles
                          bestellnummer   = lv_order_number
                          mengeneinheit   = <ls_cart>-unit
                          positionsnummer = sy-tabix
                          status          = me->mc_status_ordered
                          kunde           = me->mv_customernumber ).

      APPEND ls_order TO lt_order.
    ENDLOOP.

    me->insert_address_of_order( iv_order_number = lv_order_number ).
    INSERT zsbt_bestellung FROM TABLE lt_order.

    IF sy-subrc <> 0.
      MESSAGE i045(zsbt_web_shop) INTO DATA(ls_msg).
      RAISE EXCEPTION TYPE zcx_sbt_web_shop_exception USING MESSAGE.
    ENDIF.

    me->mo_home_screen_controller->send_order_confirmation( iv_email = me->get_email_address_of_customer( )
                                                            iv_order_number = lv_order_number ).

    CLEAR me->mt_cart.

  ENDMETHOD.


  METHOD remove_item_from_cart.

    DELETE mt_cart WHERE article_number = iv_article_number.

  ENDMETHOD.


  METHOD return_address.

    rv_address = me->ms_order_address.

  ENDMETHOD.


  METHOD search_entries_to_new_table.

    TRY.
        IF iv_search_string IS NOT INITIAL.
          CLEAR me->mt_articles_out.
          "Select from itab for a table with only char fields
          SELECT bezeichnung
             FROM @me->mt_articles AS articles
            INTO TABLE @DATA(lt_char_articles).
          IF sy-subrc <> 0.
            MESSAGE i058(zsbt_web_shop) INTO DATA(ls_msg).
            RAISE EXCEPTION TYPE zcx_sbt_web_shop_exception USING MESSAGE.
          ENDIF.
          "search entries
          FIND ALL OCCURRENCES OF REGEX iv_search_string
          IN TABLE lt_char_articles
          IGNORING CASE
          RESULTS DATA(lt_searched_articles).
          "build new output table of searched entries
          LOOP AT lt_searched_articles ASSIGNING FIELD-SYMBOL(<ls_searched_entries>).

            APPEND me->mt_articles[ <ls_searched_entries>-line ] TO me->mt_articles_out.

          ENDLOOP.
        ELSE.
          me->mt_articles_out = me->mt_articles.
        ENDIF.

      CATCH zcx_sbt_web_shop_exception INTO DATA(lo_exc).
        MESSAGE lo_exc.
        me->mt_articles_out = me->mt_articles.
    ENDTRY.

  ENDMETHOD.


  METHOD select_articles.

    SELECT *
      FROM zsbt_artikel
      INTO TABLE @mt_articles.

  ENDMETHOD.


  METHOD set_customer_email.

    me->mv_customer_email = iv_email.

  ENDMETHOD.


  METHOD set_order_address.

    CLEAR me->ms_order_address.

    me->ms_order_address = is_order_address.

  ENDMETHOD.
ENDCLASS.
