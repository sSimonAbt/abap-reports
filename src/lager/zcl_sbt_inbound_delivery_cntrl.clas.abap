class ZCL_SBT_INBOUND_DELIVERY_CNTRL definition
  public
  final
  create public .

public section.

  data MO_VIEW type ref to ZCL_SBT_INBOUND_DELIVERY_VIEW .

  methods ON_SCAN_QUANTITY
    importing
      !IV_QUANTITY type ZSBT_ZSBT_MENGE_DE
      !IV_MEINS type ZSBT_MEINS_DE .
  methods ON_CONFIRM_SCAN_ARTICLE
    importing
      !IV_ARTICLE_NUMBER type ZSBT_ARTIKELNUMMER_DE .
  methods START .
  methods CONSTRUCTOR
    importing
      !IO_LOG type ref to ZCL_SBT_WEB_SHOP_LOG .
  methods CHECK_USER
    importing
      !IV_WAREHOUSENUM type ZSBT_LGNUM_DE
      !IV_USERID type ZSBT_USERID_DE
      !IV_PASSWORD type ZSBT_PASSWORT_DE .
  methods ON_PBO_STORAGE_PLACE
    exporting
      !EV_WAREHOUSE_NUM type ZSBT_LGNUM_DE
      !EV_STORAGE_PLACE type ZSBT_LGPLATZ_DE
      !EV_STORAGE_AREA type ZSBT_LGBER_DE .
  methods ON_CONFIRM_STORAGE_PLACE
    importing
      value(IV_STORAGE_PLACE) type ZSBT_LGPLATZ_DE .
  PROTECTED SECTION.
private section.

  constants MC_LOGOBJECT type BAL_S_LOG-OBJECT value 'ZSBT' ##NO_TEXT.
  constants MC_SUBOBJEC type BAL_S_LOG-SUBOBJECT value 'ZUBT' ##NO_TEXT.
  data MO_LOG type ref to ZCL_SBT_WEB_SHOP_LOG .
  data MO_MODEL type ref to ZCL_SBT_INBOUND_DELIVERY_MODEL .

  methods ENCRYPT_PASSWORD
    importing
      !IV_PASSWORD type ZSBT_PASSWORT_DE
    returning
      value(RV_PASSWORD_AS_HASH) type ZSBT_PASSWORT_DE .
ENDCLASS.



CLASS ZCL_SBT_INBOUND_DELIVERY_CNTRL IMPLEMENTATION.


  METHOD check_user.

    me->mo_model->check_user_and_password( iv_warehousenum = iv_warehousenum
                                           iv_userid       = iv_userid
                                           iv_password     = me->encrypt_password( iv_password = iv_password ) ).

  ENDMETHOD.


  METHOD constructor.

    me->mo_log = io_log.

    IF me->mo_view IS NOT BOUND.
      me->mo_view = NEW zcl_sbt_inbound_delivery_view( io_controller = me
                                                       io_log = me->mo_log ).
    ENDIF.

    IF me->mo_model IS NOT BOUND.
      me->mo_model = NEW zcl_sbt_inbound_delivery_model( io_log        = me->mo_log
                                                         io_controller = me ).
    ENDIF.

  ENDMETHOD.


  METHOD encrypt_password.

    TRY.
        cl_abap_message_digest=>calculate_hash_for_char( EXPORTING if_data       = iv_password
                                                         IMPORTING ef_hashstring = rv_password_as_hash ).

      CATCH cx_abap_message_digest. " Ausnahmeklasse für Message Digest
        MESSAGE e042(zsbt_web_shop) INTO DATA(lv_message).
        me->mo_log->add_msg_from_sys( ).
    ENDTRY.

  ENDMETHOD.


  METHOD on_confirm_scan_article.

    IF iv_article_number IS INITIAL.
      MESSAGE i069(zsbt_web_shop) INTO DATA(lv_message).
      me->mo_log->add_msg_from_sys( ).
      RAISE EXCEPTION TYPE zcx_sbt_web_shop_exception USING MESSAGE.
    ENDIF.

    IF me->mo_model->set_article_number_and_proof( iv_article_number ).
      me->mo_view->call_dynpro_storage_place( ).
    ENDIF.

  ENDMETHOD.


  METHOD on_confirm_storage_place.

    IF me->mo_model->set_and_compare_str_place_scan( iv_storage_place = iv_storage_place ) = abap_false.
      MESSAGE i075(zsbt_web_shop) INTO DATA(lv_message).
      me->mo_log->add_msg_from_sys( ).
    ENDIF.

    "Wenn alles passt rufe neues Dynpro auf
    me->mo_view->call_dynpro_quantity( ).

  ENDMETHOD.


  METHOD on_pbo_storage_place.

    "Daten im Controller zwischenspeicher und ins Model geben oder Model zum zwischenspeicher?
    me->mo_model->search_product_on_strg_place( IMPORTING ev_warehouse     = ev_warehouse_num
                                                          ev_storage_place = ev_storage_place
                                                          ev_storage_area  = ev_storage_area ).

  ENDMETHOD.


  METHOD on_scan_quantity.

    me->mo_model->set_quantity_and_meins( EXPORTING iv_quantity = iv_quantity
                                                    iv_meins    = iv_meins ).

    me->mo_model->save_and_commit( ).

    me->mo_log->safe_log( ).
    me->mo_log->display_log_as_popup( ).

    FREE: me->mo_model, me->mo_view, me->mo_log.

    me->mo_log = NEW zcl_sbt_web_shop_log( iv_object = me->mc_logobject
                                           iv_suobj  = me->mc_subobjec ).

    me->mo_model = NEW zcl_sbt_inbound_delivery_model( io_log        = me->mo_log
                                                       io_controller = me ).


    me->mo_view = NEW zcl_sbt_inbound_delivery_view( io_controller = me
                                                     io_log        = me->mo_log ).
    me->mo_view->call_dynpro_putaway_article( ).

  ENDMETHOD.


  METHOD start.

    me->mo_view->call_dynpro_login( ).

  ENDMETHOD.
ENDCLASS.
