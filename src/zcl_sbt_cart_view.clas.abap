class ZCL_SBT_CART_VIEW definition
  public
  final
  create public .

public section.

  methods CALL_SCREEN_CART .
  methods SCREEN_FOR_CART_PAI .
  methods SCREEN_FOR_CART_PBO .
  methods CONSTRUCTOR
    importing
      !IO_CONTROLLER type ref to ZCL_SBT_HOME_SCREEN_CONTROLLER .
protected section.
private section.

  data MO_HOME_SCREEN_CONTROLLER type ref to ZCL_SBT_HOME_SCREEN_CONTROLLER .
ENDCLASS.



CLASS ZCL_SBT_CART_VIEW IMPLEMENTATION.


  method CALL_SCREEN_CART.

    CALL FUNCTION 'ZSBT_DLG_CART'
      EXPORTING
        io_cart_view       = me.

  endmethod.


  METHOD constructor.

    me->mo_home_screen_controller = io_controller.

  ENDMETHOD.


  METHOD screen_for_cart_pai.

    CASE sy-ucomm.

      WHEN 'BACK'.
        me->mo_home_screen_controller->on_back( ).

      WHEN 'LEAVE'.
        me->mo_home_screen_controller->on_leave( ).

      WHEN 'ORDER'.
        me->mo_home_screen_controller->on_order( ).

      WHEN 'EDIT'.
        me->mo_home_screen_controller->on_edit_quantity( ).

      WHEN 'REMOVE'.
        me->mo_home_screen_controller->on_remove_item_from_cart( ).


    ENDCASE.

  ENDMETHOD.


  method SCREEN_FOR_CART_PBO.

    me->mo_home_screen_controller->on_pbo_cart( ).

  endmethod.
ENDCLASS.
