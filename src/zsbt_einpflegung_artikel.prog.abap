*&---------------------------------------------------------------------*
*& Report ZSBT_EINPFLEGUNG_ARTIKEL
*&---------------------------------------------------------------------*
*& "Report zum Anlegen von Artikeln"
*&---------------------------------------------------------------------*
REPORT zsbt_einpflegung_artikel.

PARAMETERS: p_bez   TYPE zsbt_bezeichnung_de  OBLIGATORY,
            p_besch TYPE zsbt_beschreibung_de OBLIGATORY,
            p_waehr TYPE zsbt_waehrung_de     OBLIGATORY,
            p_einh  TYPE zsbt_einheit_de      OBLIGATORY,
            p_preis TYPE zsbt_preis_de        OBLIGATORY.

DATA: lv_artnummer      TYPE                          i,
      ls_artikel        TYPE           zsbt_artikel,
      lt_artikel        TYPE TABLE OF  zsbt_artikel,
      lo_alv            TYPE REF TO    cl_salv_table.

CONSTANTS: lc_range_nr TYPE nrnr VALUE '01'.

"ZSBT_CL_WEBSHOP_CONTANTEN=>GC_range_nr.

CALL FUNCTION 'NUMBER_GET_NEXT'
  EXPORTING
    nr_range_nr = lc_range_nr
    object      = 'ZSBT_ARTIK' "todo
  IMPORTING
    number      = lv_artnummer
  EXCEPTIONS
    OTHERS      = 1.
IF sy-subrc <> 0.
  MESSAGE e001(zsbt_web_shop).
ENDIF.

ls_artikel-artikelnummer = lv_artnummer.

CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
  EXPORTING
    input  = ls_artikel-artikelnummer
  IMPORTING
    output = ls_artikel-artikelnummer.

ls_artikel-bezeichnung   = p_bez.
ls_artikel-beschreibung  = p_besch.
ls_artikel-waehrung      = p_waehr.
ls_artikel-preis         = p_preis.
ls_artikel-einheit       = p_einh.

INSERT zsbt_artikel FROM ls_artikel.
CLEAR ls_artikel.

IF sy-subrc EQ 0.
  COMMIT WORK.
  " Neuer Artikel &1 &2 mit Artikelnummer &3 angelegt
  MESSAGE i006(zsbt_web_shop) WITH p_bez p_preis lv_artnummer.
ELSE.
  ROLLBACK WORK.
  " fehler ....
  MESSAGE e005(zsbt_web_shop).
ENDIF.

SELECT *
  FROM zsbt_artikel
  INTO TABLE lt_artikel.

IF sy-subrc EQ 0.
  TRY.
      cl_salv_table=>factory(
        IMPORTING
          r_salv_table   = lo_alv
        CHANGING
          t_table        = lt_artikel
      ).

      lo_alv->display( ).
    CATCH cx_salv_msg.
  ENDTRY.

ELSEIF sy-subrc <> 0.
  " nachrichtnetext
  MESSAGE e004(zsbt_web_shop).
ENDIF.
