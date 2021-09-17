class ZCL_SBT_ORDER_OVERVIEW_VIEW definition
  public
  final
  create public .

public section.

  methods ORDER_OVERVIEW_PAI .
  methods ORDER_OVERVIEW_PBO .
  methods CONSTRUCTOR
    importing
      !IO_HOME_SCREEN_CONTROLLER type ref to ZCL_SBT_HOME_SCREEN_CONTROLLER .
  methods CALL_ORDER_OVERVIEW .
protected section.
private section.

  data MO_HOME_SCREEN_CONTROLLER type ref to ZCL_SBT_HOME_SCREEN_CONTROLLER .
ENDCLASS.



CLASS ZCL_SBT_ORDER_OVERVIEW_VIEW IMPLEMENTATION.


  METHOD call_order_overview.

    CALL FUNCTION 'ZSBT_DLG_ORDER_OVERVIEW'
      EXPORTING
        io_overview_view = me.

  ENDMETHOD.


  METHOD constructor.

    mo_home_screen_controller = io_home_screen_controller.

  ENDMETHOD.


  METHOD order_overview_pai.

    CASE sy-ucomm.

      WHEN 'BACK'.
        LEAVE TO SCREEN 0.
      WHEN 'LEAVE'.
        LEAVE PROGRAM.
    ENDCASE.


  ENDMETHOD.


  method ORDER_OVERVIEW_PBO.

    me->mo_home_screen_controller->on_pbo_order_overview( ).

  endmethod.
ENDCLASS.
