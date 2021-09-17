*&---------------------------------------------------------------------*
*& Report ZSBT_BEST_UEBERSICHT_CL
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT zsbt_best_uebersicht_cl.

DATA: lv_filter    TYPE         i.

PARAMETERS: p_rkunde  RADIOBUTTON GROUP rad1      USER-COMMAND TEST
            ,p_kundid TYPE zsbt_kd_numr_de        MODIF ID kid  MATCHCODE OBJECT zsbt_sh_kunde.

PARAMETERS: p_rbest   RADIOBUTTON GROUP rad1
            ,p_best   TYPE zsbt_bestellnummer_de  MODIF ID bes  MATCHCODE OBJECT zsbt_sh_besttelnumr. "=>Mit Suchhilfen Exit löscht doppelte Einträge

PARAMETERS: p_rstat   RADIOBUTTON GROUP rad1
            ,p_status TYPE zsbt_status_de         MODIF ID sta.  "Alte Lösung wird nicht benötigt aufgrund Wertebereich->MATCHCODE OBJECT zsbt_sh_status. "= Mit Suchhilfen Exit lösch doppelte Einträge

PARAMETERS: p_rall    RADIOBUTTON GROUP rad1      DEFAULT 'X'.

SELECTION-SCREEN PUSHBUTTON /1(15) search         USER-COMMAND search.


AT SELECTION-SCREEN OUTPUT.
  search   = TEXT-b01.

  PERFORM remove_parameters_from_screen.
  "Remove execute button and save button from selction-screen
  PERFORM insert_into_excl(rsdbrunt) USING 'ONLI'.
  PERFORM insert_into_excl(rsdbrunt) USING 'SPOS'.



FORM remove_parameters_from_screen.
  "Nicht bennötigte Eingabfelder inaktiv setzen
  LOOP AT SCREEN.
    CASE screen-group1.

      WHEN 'KID'.
        IF p_rkunde = 'X'.
          screen-input = '1'.
        ELSE.
          screen-input = '0'.
        ENDIF.

      WHEN 'STA'.
        IF p_rstat = 'X'.
          screen-active = '1'.
        ELSE.
          screen-input = '0'.
        ENDIF.

      WHEN 'BES'.
        IF p_rbest = 'X'.
          screen-input = '1'.
        ELSE.
          screen-input = '0'.
        ENDIF.

    ENDCASE.

    MODIFY SCREEN.

  ENDLOOP.

ENDFORM.



START-OF-SELECTION.

AT SELECTION-SCREEN.

  CASE sy-ucomm.
    WHEN 'SEARCH'.
      "Nach ausgewälter Selektionsart Filter setzten
      IF p_rbest       EQ 'X'.
        lv_filter = 2.
      ELSEIF p_rkunde  EQ 'X'.
        lv_filter = 1.
      ELSEIF p_rstat   EQ 'X'.
        lv_filter = 3.
      ELSEIF p_rall    EQ 'X'.
        lv_filter = 0.
      ELSE.
        lv_filter = 0.
      ENDIF.

      TRY.
          DATA(lo_start) = NEW zcl_sbt_web_shop_controller( iv_filter        = lv_filter
                                                            iv_bestellnummer = p_best
                                                            iv_kundennummer  = p_kundid
                                                            iv_status        = p_status ).

          lo_start->on_start( ).

        CATCH cx_no_check INTO DATA(e_txt).


          MESSAGE: e_txt TYPE 'E'.
      ENDTRY.

  ENDCASE.

END-OF-SELECTION.
