*&---------------------------------------------------------------------*
*& Report zsbt_customer
*&---------------------------------------------------------------------*
*& "Report zum Anlegen von Kundendaten"
*&---------------------------------------------------------------------*
REPORT zsbt_erfassung_kunden.

PARAMETERS:
  p_anrede TYPE zsbt_anrede_de  OBLIGATORY,
  p_name   TYPE zsbt_name_de    OBLIGATORY,
  p_vornam TYPE zsbt_vorname_de OBLIGATORY,
  p_strass TYPE zsbt_strasse_de OBLIGATORY,
  p_hnmr   TYPE zsbt_hausnummer OBLIGATORY,
  p_plz    TYPE zsbt_plz_de     OBLIGATORY,
  p_ort    TYPE zsbt_ort_de     OBLIGATORY,
  p_email  TYPE zsbt_email_de   OBLIGATORY,
  p_telnmr TYPE zsbt_telefon_de.


DATA: ls_kunden     TYPE          zsbt_customer,
      lt_kunden     TYPE TABLE OF zsbt_customer,
      lv_nummerint  TYPE          i,
      lv_nummerchar TYPE          zsbt_kd_numr_de,
      lo_alv        TYPE REF TO   cl_salv_table.

CONSTANTS: lc_range_nr TYPE inri-nrrangenr VALUE '01'.

"call FUNCTION 'ZSBT_TEST' in UPDATE TASK.

CALL FUNCTION 'NUMBER_GET_NEXT'
  EXPORTING
    nr_range_nr = lc_range_nr
    object      = 'ZSBT_KUNDE'
  IMPORTING
    number      = lv_nummerint
  EXCEPTIONS
    OTHERS      = 1.
IF sy-subrc <> 0.
  MESSAGE e001(zsbt_web_shop) .
ENDIF.

lv_nummerchar = lv_nummerint.

CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
  EXPORTING
    input  = lv_nummerchar
  IMPORTING
    output = lv_nummerchar.

ls_kunden-customer_number = lv_nummerchar.
ls_kunden-salutation = p_anrede.
ls_kunden-name = p_name.
ls_kunden-first_name = p_vornam.
ls_kunden-street = p_strass.
ls_kunden-house_number = p_hnmr.
ls_kunden-zip_code = p_plz.
ls_kunden-city = p_ort.
ls_kunden-email = p_email.
ls_kunden-telefon_number = p_telnmr.

INSERT zsbt_customer FROM ls_kunden.

IF sy-subrc EQ 0.
  COMMIT WORK.
  " Neuer Kunde &1 &2 mit Kundennummer &3 angelegt
  MESSAGE i002(zsbt_web_shop) WITH p_vornam p_name lv_nummerint.
ELSE.
  ROLLBACK WORK.
  " fehler ....
  MESSAGE e003(zsbt_web_shop).
ENDIF.

CLEAR ls_kunden.

SELECT *
  FROM zsbt_customer
  INTO TABLE lt_kunden.

IF sy-subrc EQ 0.
  TRY.
      cl_salv_table=>factory(
        IMPORTING
          r_salv_table   = lo_alv
        CHANGING
          t_table        = lt_kunden
      ).

      lo_alv->display( ).
    CATCH cx_salv_msg.
  ENDTRY.

ENDIF.
