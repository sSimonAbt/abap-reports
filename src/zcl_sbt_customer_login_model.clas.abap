class ZCL_SBT_CUSTOMER_LOGIN_MODEL definition
  public
  final
  create public .

public section.

  methods CHECK_IF_PASSWORD_IS_CORRECT
    importing
      !IV_PASSWORD type ZSBT_PASSWORT_DE
      !IV_EMAIL type ZSBT_EMAIL_DE .
  methods SAVE_REGISTRATION_CUSTOMER
    importing
      !IS_REGISTER_DATA type ZSBT_S_REGISTER .
  methods CHECK_IF_EMAIL_IS_AVAIBLE
    importing
      !IV_EMAIL type ZSBT_EMAIL_DE .
  methods CONSTRUCTOR
    importing
      !IO_CONTROLLER type ref to ZCL_SBT_CUSTOMER_LOGIN_CNTRL .
  methods GET_CUSTOMER_NUMBER
    importing
      !IV_EMAIL type ZSBT_EMAIL_DE
    returning
      value(RV_CUSTOMERNUMBER) type ZSBT_CUSTOMERNUMBER_DE .
protected section.
private section.

  constants MC_RANGE_NR type NRNR value '01' ##NO_TEXT.
  data MO_CONTROLLER type ref to ZCL_SBT_CUSTOMER_LOGIN_CNTRL .

  methods GET_NEW_CUSTOMER_NUMBER
    returning
      value(RV_CUSTOMER_NUMBER) type NUMC10 .
ENDCLASS.



CLASS ZCL_SBT_CUSTOMER_LOGIN_MODEL IMPLEMENTATION.


  METHOD check_if_email_is_avaible.

    SELECT SINGLE *
      FROM zsbt_customer
      INTO @DATA(ls_customer)
      WHERE email = @iv_email.

    IF sy-subrc <> 4 OR ls_customer IS NOT INITIAL.
      MESSAGE i038(zsbt_web_shop) INTO DATA(ls_msg).
      RAISE EXCEPTION TYPE zcx_sbt_web_shop_exception USING MESSAGE.
    ENDIF.

  ENDMETHOD.


  METHOD check_if_password_is_correct.

    SELECT SINGLE password
      FROM zsbt_customer
    INTO @DATA(lv_password)
      WHERE email = @iv_email.

    IF sy-subrc <> 0.
      "no account could be found => Error Message
      MESSAGE i039(zsbt_web_shop) INTO DATA(ls_msg).
      RAISE EXCEPTION TYPE zcx_sbt_web_shop_exception USING MESSAGE.
    ENDIF.

    "Password is not correct => Error Message
    IF lv_password NE iv_password.
      MESSAGE i038(zsbt_web_shop) INTO ls_msg.
      RAISE EXCEPTION TYPE zcx_sbt_web_shop_exception USING MESSAGE.
    ENDIF.

  ENDMETHOD.


  method CONSTRUCTOR.

    me->mo_controller = io_controller.

  endmethod.


  METHOD get_customer_number.

    SELECT SINGLE customer_number
      FROM zsbt_customer
      INTO @DATA(lv_customernumber)
      WHERE email = @iv_email.

    IF sy-subrc <> 0.
      MESSAGE i044(zsbt_web_shop) INTO DATA(ls_msg).
      RAISE EXCEPTION TYPE zcx_sbt_web_shop_exception USING MESSAGE.
    ENDIF.

    rv_customernumber = lv_customernumber.

  ENDMETHOD.


  METHOD get_new_customer_number.

    CALL FUNCTION 'NUMBER_GET_NEXT'
      EXPORTING
        nr_range_nr = mc_range_nr
        object      = 'ZSBT_KUNDE'
      IMPORTING
        number      = rv_customer_number
      EXCEPTIONS
        OTHERS      = 1.

    IF sy-subrc <> 0.
      MESSAGE i041(zsbt_web_shop) into DATA(ls_msg).
      RAISE EXCEPTION TYPE zcx_sbt_web_shop_exception USING MESSAGE.
    ENDIF.

  ENDMETHOD.


  METHOD save_registration_customer.

    DATA: ls_register_data_for_insert TYPE zsbt_customer.

    ls_register_data_for_insert = VALUE #( customer_number = me->get_new_customer_number( )
                                           city            = is_register_data-city
                                           email           = is_register_data-email
                                           first_name      = is_register_data-firstname
                                           name            = is_register_data-name
                                           house_number    = is_register_data-house_number
                                           salutation      = is_register_data-salutation
                                           street          = is_register_data-street
                                           zip_code        = is_register_data-zip_code
                                           telefon_number  = is_register_data-telephone_number
                                           password        = me->mo_controller->encrypt_password( iv_password = is_register_data-password ) ).

    INSERT zsbt_customer FROM ls_register_data_for_insert.

    IF sy-subrc <> 0.
      MESSAGE i042(zsbt_web_shop) INTO DATA(ls_msg).
      RAISE EXCEPTION TYPE zcx_sbt_web_shop_exception USING MESSAGE.
    ENDIF.

  ENDMETHOD.
ENDCLASS.
