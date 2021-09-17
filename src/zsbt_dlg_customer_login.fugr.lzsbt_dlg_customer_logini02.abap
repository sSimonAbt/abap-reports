*----------------------------------------------------------------------*
***INCLUDE LZSBT_DLG_CUSTOMER_LOGINI02.
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_9001  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_9001 INPUT.

  gs_register_data = VALUE #( email             = p_email
                              password          = p_password
                              password_repeat   = p_password_repeat
                              street            = p_street
                              house_number      = p_house_number
                              city              = p_city
                              zip_code          = p_zipcode
                              telephone_number  = p_telephone_number
                              firstname         = p_firstname
                              name              = p_name
                              salutation        = p_salutation ).


  go_customer_register_view->register_screen_pai( is_register_data = gs_register_data ).

ENDMODULE.
