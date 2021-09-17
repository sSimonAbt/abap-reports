*&---------------------------------------------------------------------*
*& Report ZSBT_ERFASSUNG_BESTELLUNGEN
*&---------------------------------------------------------------------*
*& Report zur Erfassung von Bestellungen
*&---------------------------------------------------------------------*
REPORT zsbt_erfassung_bestellungen.


PARAMETERS: p_artnum TYPE zsbt_artikelnummer_de MATCHCODE OBJECT zsbt_sh_artikel OBLIGATORY.
PARAMETERS: p_kundid TYPE zsbt_kd_numr_de MATCHCODE OBJECT zsbt_sh_kunde OBLIGATORY.

SELECTION-SCREEN BEGIN OF LINE.
SELECTION-SCREEN COMMENT (33) FOR FIELD p_bmenge.
PARAMETERS p_bmenge TYPE zsbt_bestellmenge_de  OBLIGATORY.
PARAMETERS p_bmeins TYPE zsbt_einheit_de  OBLIGATORY.
SELECTION-SCREEN END OF LINE.


DATA: lo_alv          TYPE REF TO   cl_salv_table
      ,ls_bestellung  TYPE          zsbt_besttelung
      ,lv_bnummer_int TYPE          i
      ,lv_bnummer_chr TYPE          zsbt_bestellnummer_de
      ,lt_warenkorb   TYPE TABLE OF zsbt_besttelung
      ,lo_columns     TYPE REF TO cl_salv_columns_table
      ,lo_column      TYPE REF TO cl_salv_column.

FIELD-SYMBOLS <fs_warenkorb> TYPE zsbt_besttelung.

SELECTION-SCREEN:
PUSHBUTTON /2(20) button1 USER-COMMAND but1 , "Zum Warenkorb hinzufügen"
PUSHBUTTON /2(20) button2 USER-COMMAND but2, "Bestellung aufgeben"
PUSHBUTTON /2(20) button3 USER-COMMAND but3. "Bestellung aufgeben"


CONSTANTS: lc_range_nr         TYPE  nrnr VALUE '01',
           lc_status_bestellt  TYPE string VALUE 'BESTELLT',
           lc_status_warenkorb TYPE string VALUE 'Im Warenkorb'.

INITIALIZATION.
  button1 = TEXT-b01.
  button2 = TEXT-b02.
  button3 = TEXT-b03.

AT SELECTION-SCREEN.

  CASE sy-ucomm.
    WHEN 'BUT1'.
      CLEAR ls_bestellung.

*      lv_zwischen = lv_zwischen + 1.

      ls_bestellung-mengeneinheit = p_bmeins.
      ls_bestellung-status = lc_status_warenkorb.
*      ls_bestellung-bestellnummer = lv_bnummer.
*      ls_bestellung-positionsnummer = lv_zwischen.
      ls_bestellung-artikel = p_artnum.
      ls_bestellung-bestellmenge = p_bmenge.
      ls_bestellung-kunde = p_kundid.


      INSERT ls_bestellung INTO TABLE lt_warenkorb.
      IF sy-subrc EQ 0.

        MESSAGE i014(zsbt_web_shop) WITH p_artnum.

      ELSE.

        MESSAGE e012(zsbt_web_shop).
      ENDIF.

    WHEN 'BUT2'.
      IF lt_warenkorb IS INITIAL.
        MESSAGE e011(zsbt_web_shop).
      ELSE.
        CALL FUNCTION 'NUMBER_GET_NEXT'
          EXPORTING
            nr_range_nr = lc_range_nr
            object      = 'ZSBT_BEST'
          IMPORTING
            number      = lv_bnummer_int
          EXCEPTIONS
            OTHERS      = 1.

        IF sy-subrc <> 0.
          MESSAGE e013(zsbt_web_shop).
        ENDIF.
        lv_bnummer_chr = lv_bnummer_int.
        CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
          EXPORTING
            input  = lv_bnummer_chr
          IMPORTING
            output = lv_bnummer_chr.


        LOOP AT lt_warenkorb ASSIGNING <fs_warenkorb>.
          <fs_warenkorb>-positionsnummer = sy-tabix.

          <fs_warenkorb>-bestellnummer = lv_bnummer_chr.
          <fs_warenkorb>-status = lc_status_bestellt.
        ENDLOOP.

        INSERT zsbt_besttelung FROM TABLE lt_warenkorb.
        IF sy-subrc <> 0.
          MESSAGE e009(zsbt_web_shop).
        ELSE.
          MESSAGE i010(zsbt_web_shop).
        ENDIF.

        COMMIT WORK.

        CLEAR:  lt_warenkorb.
      ENDIF.
    WHEN 'BUT3'.
      cl_salv_table=>factory(
      IMPORTING
        r_salv_table   = lo_alv
      CHANGING
        t_table        = lt_warenkorb ).


      DATA(lo_functions) = lo_alv->get_functions( ).
      lo_functions->set_all( abap_false ).
      lo_columns = lo_alv->get_columns( ).
      lo_columns->set_optimize( abap_true ).


      TRY.
          lo_column  = lo_columns->get_column( columnname = 'MANDT'  ).
          lo_column->set_visible( abap_false ).
          lo_column  = lo_columns->get_column( columnname = 'BESTELLNUMMER'  ).
          lo_column->set_visible( abap_false ).
          lo_column  = lo_columns->get_column( columnname = 'POSITIONSNUMMER'  ).
          lo_column->set_visible( abap_false ).


        CATCH cx_salv_not_found.
      ENDTRY.
      lo_alv->display( ).

  ENDCASE.
