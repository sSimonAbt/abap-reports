class ZCL_SBT_ALTERNATIV_ADDRESS definition
  public
  final
  create public .

public section.

  methods CALL_DYNPRO_FOR_ADDRESS .
  methods CONSTRUCTOR
    importing
      !IO_HOME_SCREEN_CONTROLLER type ref to ZCL_SBT_HOME_SCREEN_CONTROLLER .
  methods ALTERNATIVE_ADDRESS_PAI
    importing
      !IS_ORDER_ADDRESS type ZSBT_S_ADDRESS .
protected section.
private section.

  data MO_HOME_SCREEN_CONTROLLER type ref to ZCL_SBT_HOME_SCREEN_CONTROLLER .
ENDCLASS.



CLASS ZCL_SBT_ALTERNATIV_ADDRESS IMPLEMENTATION.


  METHOD alternative_address_pai.

    CASE sy-ucomm.

      WHEN 'BACK'.
        LEAVE TO SCREEN 0.
      WHEN 'LEAVE'.
        LEAVE PROGRAM.
      WHEN 'CONFIRM'.
        me->mo_home_screen_controller->on_confirm_address( is_order_address = is_order_address ).
    ENDCASE.

  ENDMETHOD.


  method CALL_DYNPRO_FOR_ADDRESS.

    CALL FUNCTION 'Z_SHIPING_ADDRESS'
      EXPORTING
        io_address_view       = me
              .

  endmethod.


  METHOD constructor.

    me->mo_home_screen_controller = io_home_screen_controller.

  ENDMETHOD.
ENDCLASS.
