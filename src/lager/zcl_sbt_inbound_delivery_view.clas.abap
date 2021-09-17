CLASS zcl_sbt_inbound_delivery_view DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    DATA: mo_log TYPE REF TO zcl_sbt_web_shop_log.

    METHODS constructor
      IMPORTING
        !io_controller TYPE REF TO zcl_sbt_inbound_delivery_cntrl
        !io_log        TYPE REF TO zcl_sbt_web_shop_log.
    METHODS login_pai
      IMPORTING
        !iv_warehousenum TYPE zsbt_lgnum_de
        !iv_userid       TYPE zsbt_userid_de
        !iv_password     TYPE zsbt_passwort_de .
    METHODS call_dynpro_login .
    METHODS call_dynpro_putaway_article .
    METHODS pai_putaway_article
      IMPORTING
        !iv_article_number TYPE zsbt_artikelnummer_de .
    METHODS call_dynpro_storage_place .
    METHODS pai_storage_place
      IMPORTING iv_storage_place TYPE zsbt_lgplatz_de.
    METHODS pbo_storage_place EXPORTING ev_warehouse_num TYPE zsbt_lgnum_de
                                        ev_storage_place TYPE zsbt_lgplatz_de
                                        ev_storage_area  TYPE zsbt_lgber_de.

    METHODS pai_scan_quantity IMPORTING iv_quantity TYPE zsbt_zsbt_menge_de
                                        iv_meins    TYPE zsbt_meins_de.

    METHODS call_dynpro_quantity.

  PROTECTED SECTION.
  PRIVATE SECTION.

    DATA mo_controller TYPE REF TO zcl_sbt_inbound_delivery_cntrl .
ENDCLASS.



CLASS ZCL_SBT_INBOUND_DELIVERY_VIEW IMPLEMENTATION.


  METHOD call_dynpro_login.

    CALL FUNCTION 'ZSBT_DLG_INBOUND_DE_LOGIN'
      EXPORTING
        io_view = me.

  ENDMETHOD.


  METHOD call_dynpro_putaway_article.

    CALL FUNCTION 'ZSBT_DLG_PUTAWAY_ARTICLE'
      EXPORTING
        io_view = me.

  ENDMETHOD.


  METHOD call_dynpro_quantity.

    CALL FUNCTION 'ZSBT_DLG_PUTAWAY_QUANTITY'.

  ENDMETHOD.


  METHOD call_dynpro_storage_place.

    CALL FUNCTION 'ZSBT_DLG_PUTAWAY_STORAGE_PLACE'.

  ENDMETHOD.


  METHOD constructor.

    me->mo_log = io_log.
    me->mo_controller = io_controller.

  ENDMETHOD.


  METHOD login_pai.

    CASE sy-ucomm.

      WHEN 'BACK'.
        LEAVE TO SCREEN 0.
      WHEN 'LEAVE'.
        LEAVE PROGRAM.
      WHEN 'LOGIN'.
        me->mo_controller->check_user( EXPORTING iv_warehousenum   = iv_warehousenum
                                                 iv_userid         = iv_userid
                                                 iv_password       = iv_password ).
    ENDCASE.

  ENDMETHOD.


  METHOD pai_putaway_article.

    CASE sy-ucomm.

      WHEN 'BACK'.
        "normaly implement Methods from the controller class
        LEAVE TO SCREEN 0.
      WHEN 'LEAVE'.
        LEAVE PROGRAM.

      WHEN 'CONFIRM'.
        "weiter im Programmanblauf
        me->mo_controller->on_confirm_scan_article( iv_article_number = iv_article_number ).
    ENDCASE.

  ENDMETHOD.


  METHOD pai_scan_quantity.

    CASE sy-ucomm.

      WHEN 'CONFIRM'.
        me->mo_controller->on_scan_quantity( iv_quantity = iv_quantity
                                             iv_meins = iv_meins ).

      WHEN 'BACK'.
        LEAVE TO SCREEN 0.

      WHEN 'LEAVE'.
        LEAVE PROGRAM.
    ENDCASE.

  ENDMETHOD.


  METHOD pai_storage_place.

    CASE sy-ucomm.

      WHEN 'BACK'.
        LEAVE TO SCREEN 0.

      WHEN 'LEAVE'.
        LEAVE PROGRAM.

      WHEN 'CONFIRM'.
        me->mo_controller->on_confirm_storage_place( iv_storage_place = iv_storage_place ).

    ENDCASE.


  ENDMETHOD.


  METHOD pbo_storage_place.

    me->mo_controller->on_pbo_storage_place( IMPORTING  ev_warehouse_num =  ev_warehouse_num
                                                        ev_storage_place =  ev_storage_place
                                                        ev_storage_area  =  ev_storage_area ).

  ENDMETHOD.
ENDCLASS.
