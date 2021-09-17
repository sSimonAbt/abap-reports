FUNCTION-POOL zsbt_dlg_customer_login.      "MESSAGE-ID ..

DATA go_login_view TYPE REF TO zcl_sbt_customer_login_view.
* INCLUDE LZSBT_DLG_CUSTOMER_LOGIND...       " Local class definition
DATA go_customer_register_view TYPE REF TO zcl_sbt_customer_register_view.
DATA p_email    TYPE zsbt_email_de.
DATA p_password TYPE zsbt_passwort_de.
DATA p_password_repeat TYPE zsbt_passwort_de.
DATA p_street TYPE zsbt_strasse_de.
DATA p_house_number TYPE zsbt_hausnummer.
DATA p_zipcode TYPE zsbt_plz_de.
DATA p_city TYPE zsbt_ort_de.
DATA p_telephone_number TYPE zsbt_telefon_de.
DATA gs_register_data TYPE zsbt_s_register.
DATA p_salutation type zsbt_anrede_de.
DATA p_firstname type zsbt_vorname_de.
DATA p_name type zsbt_name_de.
