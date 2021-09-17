class ZCL_SBT_HOME_SCREEN_VIEW definition
  public
  final
  create public .

public section.

  methods CONSTRUCTOR
    importing
      !IO_HOME_SCREEN_CONTROLLER type ref to ZCL_SBT_HOME_SCREEN_CONTROLLER .
  methods CALL_HOME_SCREEN .
  methods HOME_SCREEN_PAI
    importing
      !IV_SEARCH_STRING type STRING .
  methods HOME_SCREEN_PBO .
protected section.
private section.

  data MO_HOME_SCREEN_CONTROLLER type ref to ZCL_SBT_HOME_SCREEN_CONTROLLER .
  data MO_PICTURE_LOGO_HOME_SCREEN type ref to CL_GUI_PICTURE .
ENDCLASS.



CLASS ZCL_SBT_HOME_SCREEN_VIEW IMPLEMENTATION.


  METHOD call_home_screen.

    CALL FUNCTION 'ZSBT_DLG_ITEM_SELECTION'
      EXPORTING
        io_home_screen_view = me.

  ENDMETHOD.


  METHOD constructor.

    me->mo_home_screen_controller = io_home_screen_controller.

  ENDMETHOD.


  METHOD home_screen_pai.

    CASE sy-ucomm.

      WHEN 'LEAVE'.
        me->mo_home_screen_controller->on_leave( ).

      WHEN 'BACK'.
        me->mo_home_screen_controller->on_back_to_login( ).

      WHEN 'ADD'.
        me->mo_home_screen_controller->on_add_product_to_cart( ).

      WHEN 'SHOW'.
        me->mo_home_screen_controller->on_show_cart( ).

      WHEN 'SEARCH'.
        me->mo_home_screen_controller->on_search_entries_in_table( iv_search_string = iv_search_string ).

      WHEN 'RESET'.
        me->mo_home_screen_controller->on_reset_search( ).

      WHEN 'OVERVIEW'.
        me->mo_home_screen_controller->on_overview( ).

    ENDCASE.

  ENDMETHOD.


  method HOME_SCREEN_PBO.

    me->mo_home_screen_controller->on_pbo_home_screen( ).

  endmethod.
ENDCLASS.
