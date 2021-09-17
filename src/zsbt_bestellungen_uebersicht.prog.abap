*&---------------------------------------------------------------------*
*& Report ZSBT_BESTELLUNGEN_UEBERSICHT
*&---------------------------------------------------------------------*
*& Übersicht bisheriger Bestellungen
*&---------------------------------------------------------------------*
REPORT zsbt_bestellungen_uebersicht.

PARAMETERS: p_kundid TYPE zsbt_kd_numr_de       MATCHCODE OBJECT zsbt_sh_kunde,
            p_best   TYPE zsbt_bestellnummer_de MATCHCODE OBJECT zsbt_sh_besttelnumr,
            p_status TYPE zsbt_status_de.    "    MATCHCODE OBJECT zsbt_sh_status.

PARAMETERS: p_rkunde RADIOBUTTON GROUP rad1,
            p_rbest  RADIOBUTTON GROUP rad1,
            p_rstat  RADIOBUTTON GROUP rad1,
            p_alles  RADIOBUTTON GROUP rad1.

TYPES: tty_bestellungen     TYPE TABLE OF zsbt_besttelung.

DATA:  lt_bestellungen      TYPE TABLE OF zsbt_besttelung
      ,lt_zwischen          TYPE TABLE OF zsbt_besttelung
      ,ls_zwischen          TYPE          zsbt_besttelung
      ,it_sel_rows          TYPE          lvc_t_row
      ,lo_grid              TYPE REF TO   cl_gui_alv_grid
      ,lo_grid2             TYPE REF TO   cl_gui_alv_grid
      ,g_custom_container   TYPE REF TO   cl_gui_custom_container
      ,g_custom_container2  TYPE REF TO   cl_gui_custom_container
      ,ok_code              TYPE          sy-ucomm
                          .
FIELD-SYMBOLS: <sel_rows>   TYPE lvc_s_row.

"Zu Aufgabe 5 Double Click
CLASS lcl_event_class DEFINITION.
  PUBLIC SECTION.
    METHODS
      on_double_click
                  FOR EVENT double_click OF cl_gui_alv_grid
        IMPORTING e_row.
    METHODS constructor IMPORTING ir_bestellung TYPE REF TO data
                                  ir_grid       TYPE REF TO cl_gui_alv_grid.
  PRIVATE SECTION.
    DATA gr_bestellung TYPE REF TO data.
    DATA gr_grid TYPE REF TO cl_gui_alv_grid.
ENDCLASS.


CLASS lcl_event_class IMPLEMENTATION.
  METHOD on_double_click.
    "Selektierte Zeilen auswählen
    CLEAR: ls_zwischen, it_sel_rows.
    FIELD-SYMBOLS <fs_bestellung> TYPE tty_bestellungen.
    ASSIGN gr_bestellung->* TO <fs_bestellung>.

    gr_grid->get_selected_rows(  IMPORTING et_index_rows = it_sel_rows ).

    LOOP AT it_sel_rows ASSIGNING <sel_rows>.
      READ TABLE <fs_bestellung> INTO ls_zwischen
      INDEX <sel_rows>-index.
      CALL SCREEN 1002.
    ENDLOOP.
    IF sy-subrc NE 0.
      MESSAGE: e024(zsbt_web_shop).
    ENDIF.


  ENDMETHOD.
  METHOD constructor.
    gr_bestellung = ir_bestellung.
    gr_grid       = ir_grid.
  ENDMETHOD.
ENDCLASS.

START-OF-SELECTION.
  CALL SCREEN 1001.


*&---------------------------------------------------------------------*
*& Module STATUS_1001 OUTPUT
*&---------------------------------------------------------------------*
*& Übersicht der Bestellungen
*&---------------------------------------------------------------------*
MODULE status_1001 OUTPUT.
  SET PF-STATUS 'STATUS1001'.
  SET TITLEBAR 'UEBERSICHT1001'.

  "Nach Kundennummer...
  IF p_rkunde EQ  'X' AND p_kundid IS NOT INITIAL.
    CLEAR lt_bestellungen.
    SELECT *
      FROM zsbt_besttelung
      INTO TABLE lt_bestellungen

    WHERE kunde  = p_kundid.
    IF sy-subrc = 4.
      MESSAGE i018(zsbt_web_shop).
    ELSEIF sy-subrc <> 0.
      MESSAGE e015(zsbt_web_shop).
    ELSEIF lt_bestellungen IS INITIAL.
      MESSAGE:    e025(zsbt_web_shop).

    ENDIF.

    "Nach Bestellnummer...
  ELSEIF p_rbest EQ 'X' AND p_best IS NOT INITIAL.
    CLEAR lt_bestellungen.
    SELECT *
      FROM zsbt_besttelung
      INTO TABLE lt_bestellungen
    WHERE bestellnummer = p_best.
    IF sy-subrc <> 0.
      MESSAGE e016(zsbt_web_shop).
    ENDIF.

    "Nach Status...
  ELSEIF p_rstat EQ 'X'.
    CLEAR lt_bestellungen.
    SELECT *
      FROM zsbt_besttelung
      INTO TABLE lt_bestellungen
    WHERE status EQ p_status.
    IF sy-subrc <>  0.
      MESSAGE e017(zsbt_web_shop).
    ENDIF.

    "alles...
  ELSEIF p_alles EQ 'X'.
    CLEAR lt_bestellungen.
    SELECT *
      FROM zsbt_besttelung
    INTO TABLE lt_bestellungen.
    IF sy-subrc <> 0.
      MESSAGE: e026(zsbt_web_shop).
    ENDIF.

  ELSE.

    MESSAGE e019(zsbt_web_shop).

  ENDIF.

  IF g_custom_container IS INITIAL.
    CREATE OBJECT g_custom_container
      EXPORTING
        container_name = 'CCCONTAINER'
      EXCEPTIONS
        OTHERS         = 1.
    IF sy-subrc <> 0.
      MESSAGE e020(zsbt_web_shop).
    ENDIF.
  ENDIF.
  IF lo_grid IS NOT BOUND.
    CREATE OBJECT lo_grid
      EXPORTING
        i_parent = g_custom_container.

    CALL METHOD lo_grid->set_table_for_first_display
      EXPORTING
        i_structure_name = 'ZSBT_BESTTELUNG'
      CHANGING
        it_outtab        = lt_bestellungen
      EXCEPTIONS
        OTHERS           = 1.
  ELSE.
    lo_grid->refresh_table_display(   ).

  ENDIF.


  IF sy-subrc <> 0.
    MESSAGE: e022(zsbt_web_shop).
  ENDIF.
  DATA lo_event TYPE REF TO lcl_event_class.
  DATA lr_ref TYPE REF TO data.

  GET REFERENCE OF lt_bestellungen INTO lr_ref.

  CREATE OBJECT lo_event EXPORTING  ir_bestellung = lr_ref ir_grid = lo_grid.

  "Auslösen des Doppelclick events
  SET HANDLER lo_event->on_double_click FOR lo_grid.
ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_1001  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_1001 INPUT.


  CASE sy-ucomm.
    WHEN 'BACK'.
      LEAVE TO SCREEN 0.
    WHEN 'LEAVE'.
      LEAVE PROGRAM.
    WHEN '1000'.
      " Markierte Zeile lesen mit Button
      CLEAR: ls_zwischen, it_sel_rows.

      CALL METHOD lo_grid->get_selected_rows
        IMPORTING
          et_index_rows = it_sel_rows.

      IF NOT it_sel_rows IS INITIAL.
        LOOP AT it_sel_rows ASSIGNING <sel_rows>.
          READ TABLE lt_bestellungen INTO ls_zwischen
          INDEX <sel_rows>-index.
          CALL SCREEN 1002.
        ENDLOOP.
        MESSAGE: e024(zsbt_web_shop).
      ENDIF.
    WHEN OTHERS.
      MESSAGE  e023(zsbt_web_shop).
  ENDCASE.


ENDMODULE.



*&---------------------------------------------------------------------*
*& Module STATUS_1002 OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE status_1002 OUTPUT.
  SET PF-STATUS '1002'.
  SET TITLEBAR 'POSITIONSANSICHT1002'.

  SELECT *
    FROM zsbt_besttelung
    INTO TABLE lt_zwischen
    WHERE bestellnummer = ls_zwischen-bestellnummer.

  CLEAR g_custom_container2.

  IF g_custom_container2 IS INITIAL.
    CREATE OBJECT g_custom_container2
      EXPORTING
        container_name = 'CCCONTAINER2'
      EXCEPTIONS
        OTHERS         = 1.
    IF sy-subrc <> 0.
      MESSAGE e020(zsbt_web_shop).
    ENDIF.

    CREATE OBJECT lo_grid2
      EXPORTING
        i_parent = g_custom_container2.
  ENDIF.
  CALL METHOD lo_grid2->set_table_for_first_display
    EXPORTING
      i_structure_name = 'ZSBT_BESTTELUNG'
    CHANGING
      it_outtab        = lt_zwischen
    EXCEPTIONS
      OTHERS           = 1.
  IF sy-subrc <> 0.
    MESSAGE e021(zsbt_web_shop).
  ENDIF.
ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_1002  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_1002 INPUT.

  CASE ok_code.
    WHEN 'BACK'.
      LEAVE TO SCREEN 0.
    WHEN 'LEAVE'.
      LEAVE PROGRAM.

  ENDCASE.

ENDMODULE.
