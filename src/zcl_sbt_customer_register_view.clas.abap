class ZCL_SBT_CUSTOMER_REGISTER_VIEW definition
  public
  final
  create public .

public section.

  methods CALL_REGISTER_SCREEN .
  methods REGISTER_SCREEN_PAI
    importing
      !IS_REGISTER_DATA type ZSBT_S_REGISTER .
  methods CONSTRUCTOR
    importing
      !IO_LOGIN_CONTROLLER type ref to ZCL_SBT_CUSTOMER_LOGIN_CNTRL
    exceptions
      IO_CONTROLLER .
protected section.
private section.

  data MO_LOGIN_CONTROLLER type ref to ZCL_SBT_CUSTOMER_LOGIN_CNTRL .
ENDCLASS.



CLASS ZCL_SBT_CUSTOMER_REGISTER_VIEW IMPLEMENTATION.


  method CALL_REGISTER_SCREEN.

    CALL FUNCTION 'ZSBT_DLG_CUSTOMER_REGISTER'
      EXPORTING
        io_customer_register_view =  me.

  endmethod.


  method CONSTRUCTOR.

    mo_login_controller = io_login_controller.

  endmethod.


  METHOD register_screen_pai.

    CASE sy-ucomm.

      WHEN 'BACK'.
        me->mo_login_controller->on_back( ).

      WHEN 'LEAVE'.
        me->mo_login_controller->on_leave( ).

      WHEN 'CONFIRM'.
        me->mo_login_controller->on_confirm_registration( is_register_data = is_register_data ).

    ENDCASE.

  ENDMETHOD.
ENDCLASS.
