CLASS zcl_sbt_web_shop_log DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    METHODS constructor
      IMPORTING
        !iv_object TYPE balobj_d
        !iv_suobj  TYPE balsubobj .
    METHODS add_msg
      IMPORTING
        !is_message TYPE bal_s_msg .
    METHODS safe_log .
    METHODS display_log_as_popup.
    METHODS add_msg_from_sys.
  PROTECTED SECTION.
  PRIVATE SECTION.

    DATA mv_log_handle TYPE balloghndl .
    DATA mt_log_handle TYPE bal_t_logh.


ENDCLASS.



CLASS ZCL_SBT_WEB_SHOP_LOG IMPLEMENTATION.


  METHOD add_msg.

    "Here you can add a message from an Import Structur.
    CALL FUNCTION 'BAL_LOG_MSG_ADD'
      EXPORTING
        i_log_handle     = mv_log_handle
        i_s_msg          = is_message
      EXCEPTIONS
        log_not_found    = 1
        msg_inconsistent = 2
        log_is_full      = 3
        OTHERS           = 4.

    IF sy-subrc <> 0.
* Implement suitable error handling here
    ENDIF.

  ENDMETHOD.


  METHOD add_msg_from_sys.

    "You can add message from the sy-structure
    DATA(ls_msg) = VALUE bal_s_msg( msgty   = sy-msgty
                                    msgid   = sy-msgid
                                    msgno   = sy-msgno
                                    msgv1   = sy-msgv1
                                    msgv2   = sy-msgv2
                                    msgv3   = sy-msgv3
                                    msgv4   = sy-msgv4 ).

    CALL FUNCTION 'BAL_LOG_MSG_ADD'
      EXPORTING
        i_log_handle     = mv_log_handle
        i_s_msg          = ls_msg
      EXCEPTIONS
        log_not_found    = 1
        msg_inconsistent = 2
        log_is_full      = 3
        OTHERS           = 4.

    IF sy-subrc <> 0.

    ENDIF.

  ENDMETHOD.


  METHOD constructor.

    DATA: ls_log TYPE bal_s_log.
    CONSTANTS lv_object TYPE balobj_d VALUE 'ZSBT'.

    GET TIME STAMP FIELD DATA(lv_date).

    ls_log = VALUE #( object    = iv_object
                      extnumber = lv_date
                      subobject = iv_suobj ).

    CALL FUNCTION 'BAL_LOG_CREATE'
      EXPORTING
        i_s_log                 = ls_log
      IMPORTING
        e_log_handle            = mv_log_handle
      EXCEPTIONS
        log_header_inconsistent = 1
        OTHERS                  = 2.

    IF sy-subrc <> 0.
      MESSAGE i055(zsbt_web_shop) INTO DATA(ls_msg).
      RAISE EXCEPTION TYPE zcx_sbt_web_shop_exception USING MESSAGE.
    ENDIF.

  ENDMETHOD.


  METHOD display_log_as_popup.

    DATA: ls_display_profile TYPE bal_s_prof .

    CALL FUNCTION 'BAL_DSP_PROFILE_POPUP_GET'
      IMPORTING
        e_s_display_profile = ls_display_profile.

    CALL FUNCTION 'BAL_DSP_LOG_DISPLAY'
      EXPORTING
        i_s_display_profile  = ls_display_profile
        i_t_log_handle       = me->mt_log_handle
        i_srt_by_timstmp     = abap_true
      EXCEPTIONS
        profile_inconsistent = 1
        internal_error       = 2
        no_data_available    = 3
        no_authority         = 4
        OTHERS               = 5.

    "Implement error handling!!


  ENDMETHOD.


  METHOD safe_log.

    APPEND mv_log_handle TO mt_log_handle.

    CALL FUNCTION 'BAL_DB_SAVE'
      EXPORTING
        i_client         = sy-mandt
        i_save_all       = abap_true
        i_t_log_handle   = me->mt_log_handle
      EXCEPTIONS
        log_not_found    = 1
        save_not_allowed = 2
        numbering_error  = 3
        OTHERS           = 4.
    IF sy-subrc <> 0.
* Implement suitable error handling here
    ENDIF.

  ENDMETHOD.
ENDCLASS.
