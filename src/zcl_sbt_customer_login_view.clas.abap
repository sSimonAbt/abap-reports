class ZCL_SBT_CUSTOMER_LOGIN_VIEW definition
  public
  final
  create public .

public section.

  data MO_CUSTOMER_LOGIN_CNTRL type ref to ZCL_SBT_CUSTOMER_LOGIN_CNTRL .

  methods CONSTRUCTOR
    importing
      !IO_CUSTOMER_LOGIN_CNTRL type ref to ZCL_SBT_CUSTOMER_LOGIN_CNTRL .
  methods CALL_LOGIN_SCREEN .
  methods LOGIN_SCREEN_PAI
    importing
      !IV_PASSWORD type ZSBT_PASSWORT_DE
      !IV_EMAIL type ZSBT_EMAIL_DE .
protected section.
private section.
ENDCLASS.



CLASS ZCL_SBT_CUSTOMER_LOGIN_VIEW IMPLEMENTATION.


  method CALL_LOGIN_SCREEN.

CALL FUNCTION 'ZSBT_DLG_CUSTOMER_LOGIN'
  EXPORTING
    io_customer_login_view =  me.

  endmethod.


  METHOD constructor.

    me->mo_customer_login_cntrl = io_customer_login_cntrl.

  ENDMETHOD.


  METHOD login_screen_pai.

    CASE sy-ucomm.

      WHEN 'LEAVE'.
        me->mo_customer_login_cntrl->on_leave( ).

      WHEN 'CONFIRM' OR ' '.
        me->mo_customer_login_cntrl->on_confirm_login( EXPORTING iv_email = iv_email iv_password = iv_password ).

      WHEN 'REGISTER'.
        me->mo_customer_login_cntrl->on_register( ).

    ENDCASE.

  ENDMETHOD.
ENDCLASS.
