class ZSBT_WEB_SHOP_VIEW definition
  public
  final
  create public .

public section.

  data MO_CONTROLLER type ref to ZCL_SBT_WEB_SHOP_CONTROLLER .
  data MO_GRID_BESTELLUBERSICHT type ref to CL_GUI_ALV_GRID .

  methods CALL_POPUP_EDIT_STATUS .
  methods CALL_POPUP_EDIT_MENGE .
  methods BESTELLUNGSUEBERSICHT_PBO .
*    raising
*      ZCX_SBT_WEB_SHOP_EXCEPTION
  methods CONSTRUCTOR
    importing
      !IO_CONTROLLER type ref to ZCL_SBT_WEB_SHOP_CONTROLLER optional .
  methods CALL_BESTELLUEBERSICHT .
*    raising
*      ZCX_SBT_WEB_SHOP_EXCEPTION
  methods BESTELLUNGSUEBERSICHT_PAI .
*    raising
*      ZCX_SBT_WEB_SHOP_EXCEPTION
  methods POSITIONSUEBERSICHT_PBO .
*    raising
*      ZCX_SBT_WEB_SHOP_EXCEPTION
  methods POSITIONSUEBERSICHT_PAI .
  methods CALL_POSITIONSUEBERSICHT .
  methods POPUP_EDIT_MENGE_PAI
    importing
      !IV_MENGE type ANY .
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS ZSBT_WEB_SHOP_VIEW IMPLEMENTATION.


  METHOD bestellungsuebersicht_pai.

    TRY.

        CASE sy-ucomm.
          WHEN 'BACK'.
            "passende Methode des Controllers"
            me->mo_controller->on_back( ).
          WHEN 'LEAVE'.
            "passende Methode des Controllers
            me->mo_controller->on_leave( ).
          WHEN 'SUCHEN'. "Button Suchen des Dynpros (Funktionscode 1000 in Elementliste)
            " Markierte Zeile lesen mit Button
            me->mo_controller->on_position( ).
          WHEN 'REFRESH'. "Button Refresh
            me->mo_controller->on_refresh( ).
          WHEN 'DELETE'. "Button Bestellung Löschen
            me->mo_controller->on_delete( ).
          WHEN OTHERS.
            MESSAGE  i023(zsbt_web_shop) INTO DATA(ls_msg).
            RAISE EXCEPTION TYPE zcx_sbt_web_shop_exception USING MESSAGE.
        ENDCASE.
    ENDTRY.
  ENDMETHOD.


  METHOD bestellungsuebersicht_pbo.

    me->mo_controller->on_bestellungsuebersicht_pbo( ).

  ENDMETHOD.


  METHOD call_bestelluebersicht.

    CALL FUNCTION 'Z_SBT_WEB_SHOP_BESTELLUBERSICH'
      EXPORTING
        im_web_shop = me.

  ENDMETHOD.


  METHOD call_popup_edit_menge.

    CALL FUNCTION 'Z_SBT_WEB_SHOP_POPUP_EDIT_MENG'
      EXPORTING
        im_web_shop = me.

  ENDMETHOD.


  METHOD call_popup_edit_status.

    CALL FUNCTION 'Z_SBT_WEB_SHOP_POPUP_STATUS'
      EXPORTING
        im_web_shop = me.

  ENDMETHOD.


  METHOD call_positionsuebersicht.

    CALL FUNCTION 'Z_SBT_WEB_SHOP_POSITIONEN'
      EXPORTING
        im_web_shop = me.

  ENDMETHOD.


  METHOD constructor.
    me->mo_controller = io_controller.

  ENDMETHOD.


  METHOD popup_edit_menge_pai.

    CASE sy-ucomm.

      WHEN 'CONFIRM'.
        "Übergabe Daten an an Controller
        me->mo_controller->on_edit( iv_wert = iv_menge ).
      WHEN 'BACK'.
        LEAVE TO SCREEN 0.

      WHEN OTHERS.
         "Übergabe Daten an an Controller
*        me->mo_controller->on_edit( iv_wert = iv_menge ).
    ENDCASE.

  ENDMETHOD.


  METHOD positionsuebersicht_pai.

    TRY.
        CASE sy-ucomm.
          WHEN 'BACK'.
            me->mo_controller->on_back( ).
          WHEN 'LEAVE'.
            me->mo_controller->on_leave( ).
          WHEN 'DELETE_POSITION'.
            "Löschen einer Position
            me->mo_controller->on_delete_position( ).
          WHEN 'EDIT_MENGE'.
            "Ändern einer Bestellmenge
            me->mo_controller->on_edit_menge( ).
          WHEN 'EDIT_STATUS'.
            "Ändern des Bestellstatus
            me->mo_controller->on_edit_status( ).
          WHEN OTHERS.
            MESSAGE  e023(zsbt_web_shop) INTO DATA(ls_msg).
            RAISE EXCEPTION TYPE zcx_sbt_web_shop_exception USING MESSAGE.
        ENDCASE.

    ENDTRY.

  ENDMETHOD.


  METHOD positionsuebersicht_pbo.
    me->mo_controller->on_positions_uebersicht_pbo( ).
  ENDMETHOD.
ENDCLASS.
