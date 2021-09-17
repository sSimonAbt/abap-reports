CLASS zcl_sbt_web_shop_controller DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    TYPES:
      tty_bestellungen TYPE STANDARD TABLE OF zsbt_bestellung .

    METHODS on_edit_status .
    METHODS on_edit_menge .
    METHODS on_delete .
    METHODS on_bestellungsuebersicht_pbo .
    METHODS on_start .
    METHODS constructor
      IMPORTING
        !iv_kundennummer  TYPE zsbt_kd_numr_de
        !iv_bestellnummer TYPE zsbt_bestellnummer_de
        !iv_status        TYPE zsbt_status_de
        !iv_filter        TYPE i
        !ir_bestellung    TYPE zsbt_bestellung OPTIONAL
        !ir_grid          TYPE REF TO cl_gui_alv_grid OPTIONAL .

    METHODS on_back .
    METHODS on_leave .
    METHODS on_double_click
        FOR EVENT double_click OF cl_gui_alv_grid .
    METHODS on_position .
    METHODS on_positions_uebersicht_pbo .
    METHODS on_refresh .
    METHODS on_delete_position .
    METHODS on_edit
      IMPORTING
        !iv_wert TYPE any .
  PROTECTED SECTION.
private section.

  data MO_BEST_CONTAINER type ref to CL_GUI_CUSTOM_CONTAINER .
  data MO_POS_CONTAINER type ref to CL_GUI_CUSTOM_CONTAINER .
  data MV_FILTER type I value 0 ##NO_TEXT.
  data MO_WEB_SHOP_MODEL type ref to ZCL_SBT_WEB_SHOP_MODEL .
  data MV_BESTELLNUMMER type ZSBT_BESTELLNUMMER_DE .
  data MV_STATUS type ZSBT_STATUS_DE .
  data MO_WEB_SHOP_VIEW type ref to ZSBT_WEB_SHOP_VIEW .
  data MV_KUNDENNUMMER type ZSBT_KD_NUMR_DE .
  data MO_ALV_GRID_BESTELLUBERSICHT type ref to CL_GUI_ALV_GRID .
  data MS_POSITIONEN type ZSBT_S_BESTELLUNGEN .
  data MT_POSITIONEN type TTY_BESTELLUNGEN .
  data MO_ALV_GRID_POSITIONSUBERSICHT type ref to CL_GUI_ALV_GRID .

  methods DEQUEUE_ZSBT_BESTELLUNG .
  methods ENQUEUE_ZSBT_BESTELLUNG
    returning
      value(RV_ENQUEUE_OK) type I .
  methods CREATE_ALV_UEBERSICHT .
  methods SEARCH_SELECTED_BESTELLUNG
    returning
      value(RS_SELECTED_BESTELLUNG) type ZSBT_S_BESTELLUNGEN .
  methods SEARCH_SELECTED_POSITION
    returning
      value(RS_BESTELLPOSITIONEN) type ZSBT_BESTELLUNG .
  methods CREATE_ALV_POSITION .
  methods REFRESH_POSITION .
  methods ON_DOUBLE_CLICK_EDIT_MENGE
    for event DOUBLE_CLICK of CL_GUI_ALV_GRID .
  methods BUTTON_TOOLBAR_BESTELLUNG
    for event TOOLBAR of CL_GUI_ALV_GRID
    importing
      !E_INTERACTIVE
      !E_OBJECT .
  methods ON_TOOLBAR_BTN_DELETE_BEST
    for event USER_COMMAND of CL_GUI_ALV_GRID
    importing
      !E_UCOMM .
  methods BUTTON_TOOLBAR_POSITION
    for event TOOLBAR of CL_GUI_ALV_GRID
    importing
      !E_INTERACTIVE
      !E_OBJECT .
  methods ON_TOOLBAR_BTN_DELETE_POS
    for event USER_COMMAND of CL_GUI_ALV_GRID
    importing
      !E_UCOMM .
ENDCLASS.



CLASS ZCL_SBT_WEB_SHOP_CONTROLLER IMPLEMENTATION.


  METHOD button_toolbar_bestellung.

    DATA ls_button TYPE stb_button.
    CONSTANTS: lc_function_code TYPE char70 VALUE 'DELETE',
               lc_quickinfo     TYPE char30 VALUE 'Löschen einer Bestellung',
               lc_disabled      TYPE char1  VALUE ' ',
               lc_button_text   TYPE char40 VALUE 'Bestellung Löschen'.

    "Einfügen eines Seperators (Senkrechter Strich) zum Absetzen von anderen Buttons
    CLEAR ls_button.
    ls_button-butn_type = 3. "Seperator
    APPEND ls_button TO e_object->mt_toolbar.

    "Einfügen des Delete-Buttons
    CLEAR ls_button.

    ls_button = VALUE stb_button(  function = lc_function_code
                                       icon = icon_cancel
                                  quickinfo = lc_quickinfo
                                   disabled = lc_disabled
                                       text = lc_button_text ).
    "Hinzufügen des Buttons zur Toolbar
    APPEND ls_button TO e_object->mt_toolbar.

  ENDMETHOD.


  METHOD button_toolbar_position.

    DATA ls_button_position TYPE stb_button.

    CONSTANTS: lc_function_code TYPE char70 VALUE 'DELETE',
               lc_quickinfo     TYPE char30 VALUE 'Löschen einer Position',
               lc_disabled      TYPE char1  VALUE ' ',
               lc_button_text   TYPE char40 VALUE 'Position Löschen'.

    "Einfügen eines Seperators (Senkrechter Strich) zum Absetzen von anderen Buttons
    CLEAR ls_button_position.
    ls_button_position-butn_type = 3. "Seperator
    APPEND ls_button_position TO e_object->mt_toolbar.

    "Einfügen des Delete-Buttons
    CLEAR ls_button_position.

    ls_button_position = VALUE stb_button(  function = lc_function_code
                                                icon = icon_cancel
                                           quickinfo = lc_quickinfo
                                            disabled = lc_disabled
                                                text = lc_button_text ).
    "Hinzufügen des Buttons zur Toolbar
    APPEND ls_button_position TO e_object->mt_toolbar.



  ENDMETHOD.


  METHOD constructor.

    mv_kundennummer   = iv_kundennummer.
    mv_bestellnummer  = iv_bestellnummer.
    mv_status         = iv_status.
    mv_filter         = iv_filter.


    "Instanziierung des Models
    me->mo_web_shop_model = NEW zcl_sbt_web_shop_model( ).

    "Instanziierung der View
    me->mo_web_shop_view = NEW ZSBT_WEB_SHOP_VIEW( io_controller = me ).

    "Wenn Objekte nicht vorhanden sind dann Fehler
    IF me->mo_web_shop_model IS NOT BOUND OR me->mo_web_shop_view IS NOT BOUND.
      RAISE EXCEPTION TYPE zcx_sbt_web_shop_exception
        EXPORTING
          textid = zcx_sbt_web_shop_exception=>object_not_found.
    ENDIF.
  ENDMETHOD.


  METHOD create_alv_position.

    "Wenn noch kein Container exsistier=>sonst ensteht Refresh Fehler da immerwieder Objekte nachproduziert werden
    IF mo_pos_container IS INITIAL.
      me->mo_pos_container = NEW cl_gui_custom_container( container_name = 'CC_CONTAINER'
                                                               repid     = 'SAPLZSBT_WEB_SHOP'
                                                               dynnr     = '9002'        ).

      "Zeige ALV mit Positionen an / Achtung Objekt mo_pos_container darf nur einmal existieren
      me->mo_alv_grid_positionsubersicht = NEW cl_gui_alv_grid( i_parent = mo_pos_container ).

      me->mo_alv_grid_positionsubersicht->set_table_for_first_display(
        EXPORTING
          i_structure_name = 'ZSBT_BESTELLUNG'
        CHANGING
          it_outtab        = mt_positionen
        EXCEPTIONS
          OTHERS           = 1 ).

      IF sy-subrc <> 0.
        RAISE EXCEPTION TYPE zcx_sbt_web_shop_exception
          EXPORTING
            textid = zcx_sbt_web_shop_exception=>alv_not_able_to_create.
      ENDIF.
    ELSE.
      "Wenn Bereits ein Container existiert führe ein Refresh durch
      mo_alv_grid_positionsubersicht->refresh_table_display( ).
    ENDIF.

    SET HANDLER me->on_double_click_edit_menge
                me->button_toolbar_position
                me->on_toolbar_btn_delete_pos
                FOR me->mo_alv_grid_positionsubersicht.

    me->mo_alv_grid_positionsubersicht->set_toolbar_interactive( ).

  ENDMETHOD.


  METHOD create_alv_uebersicht.

    FREE: me->mo_alv_grid_bestellubersicht.
    CLEAR: me->mo_alv_grid_bestellubersicht.

    IF mo_best_container IS INITIAL.
      mo_best_container = NEW cl_gui_custom_container( container_name = 'C_CONTAINER'
                                                       repid          = 'SAPLZSBT_WEB_SHOP'
                                                       dynnr          = '9001'
                                                     ).
    ENDIF.

    IF sy-subrc <> 0.
      RAISE EXCEPTION TYPE zcx_sbt_web_shop_exception
        EXPORTING
          textid = zcx_sbt_web_shop_exception=>alv_not_able_to_create.
    ENDIF.

    IF mo_best_container IS BOUND.
      me->mo_alv_grid_bestellubersicht = NEW cl_gui_alv_grid( i_parent = mo_best_container ).
    ELSE.
      RAISE EXCEPTION TYPE zcx_sbt_web_shop_exception
        EXPORTING
          textid = zcx_sbt_web_shop_exception=>alv_not_able_to_create.
    ENDIF.

  ENDMETHOD.


  METHOD dequeue_zsbt_bestellung.

    CALL FUNCTION 'DEQUEUE_EZSBT_BESTELLUNG'
      EXPORTING
        mode_zsbt_bestellung = 'E'
        bestellnummer        = me->ms_positionen-bestellnummer.

  ENDMETHOD.


  METHOD enqueue_zsbt_bestellung.

    "Sperre setzen
    CALL FUNCTION 'ENQUEUE_EZSBT_BESTELLUNG'
      EXPORTING
        mode_zsbt_bestellung = 'E'
        bestellnummer        = me->ms_positionen-bestellnummer
      EXCEPTIONS
        foreign_lock         = 1
        system_failure       = 2
        OTHERS               = 3.
    "Rückgabe des sy-subrc Wertes an den Aufrufer für weitere Verabeitung
    rv_enqueue_ok = sy-subrc.

  ENDMETHOD.


  METHOD on_back.

    me->dequeue_zsbt_bestellung( ).

    IF me->mo_alv_grid_bestellubersicht IS BOUND.
      me->on_refresh( ).
    ENDIF.

    LEAVE TO SCREEN 0.

  ENDMETHOD.


  METHOD on_bestellungsuebersicht_pbo.

    SET PF-STATUS '9001'           OF PROGRAM 'SAPLZSBT_WEB_SHOP'.
    SET TITLEBAR 'UEBERSICHT9001'  OF PROGRAM 'SAPLZSBT_WEB_SHOP'.
*Selektierte Daten holen mit verbesserter Ansicht
    me->mo_web_shop_model->get_bestellungenansicht( ) .

    IF me->mo_web_shop_model->mt_bestellungen_ansicht IS INITIAL.
      RAISE EXCEPTION TYPE zcx_sbt_web_shop_exception
        EXPORTING
          textid = zcx_sbt_web_shop_exception=>order_not_found.


    ENDIF.

    IF me->mo_alv_grid_bestellubersicht IS NOT BOUND.
      create_alv_uebersicht( ).

      "Tabelle anzeigen
      me->mo_alv_grid_bestellubersicht->set_table_for_first_display(
        EXPORTING
          i_structure_name              = 'ZSBT_S_BESTELLUNGEN'
        CHANGING
          it_outtab                     = me->mo_web_shop_model->mt_bestellungen_ansicht
        EXCEPTIONS
          OTHERS                        = 1
      ).

      "Wenn Fehler bei der Erstellung ALV-Grid auftauch SY-SUBRC = 1.
      IF sy-subrc <> 0.
        RAISE EXCEPTION TYPE zcx_sbt_web_shop_exception
          EXPORTING
            textid = zcx_sbt_web_shop_exception=>alv_not_able_to_create.
      ENDIF.
      SET HANDLER me->button_toolbar_bestellung
                  me->on_double_click
                  me->on_toolbar_btn_delete_best
                  FOR me->mo_alv_grid_bestellubersicht.
    ENDIF.

    me->mo_alv_grid_bestellubersicht->set_toolbar_interactive( ).

  ENDMETHOD.


  METHOD on_delete.

    DATA: lv_sysubrc TYPE i.

    CONSTANTS: lc_text           TYPE char90 VALUE 'Sind Sie sicher das Sie die Bestellung löschen wollen?'    ##no_text,
               lc_kind           TYPE char4  VALUE 'QUES'                                                      ##no_text,
               lc_button1        TYPE char15 VALUE 'JA'                                                        ##no_text,
               lc_button2        TYPE char15 VALUE 'NEIN'                                                      ##no_text,
               lc_text_sperre    TYPE char90 VALUE 'Bestellung wird bereits von einem anderen User bearbeitet' ##no_text,
               lc_kind_sperre    TYPE char4  VALUE 'INFO'                                                      ##no_text,
               lc_button1_sperre TYPE char15 VALUE 'OK'                                                        ##no_text.

    "Sperre setzen
    lv_sysubrc = me->enqueue_zsbt_bestellung( ).
    "Wenn Sperre gesetzt werden konnte
    IF lv_sysubrc = 0.
      "Abfrage ob User sicher löschen will
      DATA(lv_btn) = /auk/cl_msgbox=>show_msgbox( im_text    = lc_text
                                                  im_kind    = lc_kind
                                                  im_button1 = lc_button1
                                                  im_button2 = lc_button2 ).
      "Wenn User Löschen will
      IF lv_btn = 1.
        "Ausgewählte Bestellung holen
        DATA(ls_selected_bestellung)  = me->search_selected_bestellung( ).
        "Wenn Benutzer keine Zeile Ausgewählt hat oder ein Fehler dabei auftritt
        IF ls_selected_bestellung IS INITIAL.
          MESSAGE i034(zsbt_web_shop) INTO DATA(ls_msg).
          RAISE EXCEPTION TYPE zcx_sbt_web_shop_exception USING MESSAGE.
        ENDIF.
        "Ausgewählte Bestellung löschen
        me->mo_web_shop_model->delete_order( iv_bestellnummer = ls_selected_bestellung-bestellnummer ).
        "Bestellungsübersicht aktualisieren
        me->on_refresh( ).
      ELSE.
        "Wird keine Aktion ausgeführt
      ENDIF.

    ELSEIF lv_sysubrc = 1.
      "Ein User hat bereits eine Sperre gesetzt=> Info Pop-Up anzeigen
      DATA(lv_button) = /auk/cl_msgbox=>show_msgbox( im_text    = lc_text_sperre
                                                     im_kind    = lc_kind_sperre
                                                     im_button1 = lc_button1_sperre ).

      IF lv_button = 1.

        "Kehre zur Bestellungsauswahl zurück
        me->on_bestellungsuebersicht_pbo( ).
      ELSE.
        "Do nothing
      ENDIF.
    ELSE.
      "Wenn ein Fehler beim Erstellen der Sperre auftritt
      MESSAGE i037(zsbt_web_shop).
      RAISE EXCEPTION TYPE zcx_sbt_web_shop_exception USING MESSAGE.
    ENDIF.

  ENDMETHOD.


  METHOD on_delete_position.

    CONSTANTS: lc_text    TYPE char90 VALUE 'Sind Sie sicher das Sie die Position löschen wollen?'   ##no_text,
               lc_kind    TYPE char4  VALUE 'QUES'                                                   ##no_text,
               lc_button1 TYPE char15 VALUE 'JA'                                                     ##no_text,
               lc_button2 TYPE char15 VALUE 'NEIN'                                                   ##no_text.

    DATA(lv_btn) = /auk/cl_msgbox=>show_msgbox( im_text    = lc_text
                                                im_kind    = lc_kind
                                                im_button1 = lc_button1
                                                im_button2 = lc_button2 ).

    "Wenn User löschen möchte
    IF lv_btn = 1.
      me->mo_web_shop_model->delete_position( is_position = me->search_selected_position( ) ).
      "Bestellübersicht aktualisieren
      me->on_refresh( ).
      "Zurückspringen zur Bestellübersicht
      LEAVE TO SCREEN 0.
    ELSE.
      "User möchte nicht löschen, es wird keine Aktion durchgeführt
    ENDIF.

  ENDMETHOD.


  METHOD on_double_click.

    "Hohlt Positionen zur Ausgewhälten Bestellung und zeigt diese an
    me->on_position( ).

  ENDMETHOD.


  METHOD on_double_click_edit_menge.

    me->on_edit_menge( ).

  ENDMETHOD.


  METHOD on_edit.

    "Struktur mit eingegebenen Daten ändern und in eintrag in DB verändern
    me->mo_web_shop_model->edit_postition( EXPORTING iv_wert     = iv_wert
                                                     is_position = me->search_selected_position( ) ).

    "Bestellübericht Aktualisieren
    me->refresh_position( ).

    "geöffnetes Pop-Up veralssen
    LEAVE TO SCREEN 0.

  ENDMETHOD.


  METHOD on_edit_menge.

    "Pop-Up aufrufen mit Eingabefeld
    me->mo_web_shop_view->call_popup_edit_menge( ).

  ENDMETHOD.


  METHOD on_edit_status.

    me->mo_web_shop_view->call_popup_edit_status( ).

  ENDMETHOD.


  METHOD on_leave.

    LEAVE PROGRAM.

  ENDMETHOD.


  METHOD on_position.

    DATA lv_sy_subrc TYPE i.

    CONSTANTS: lc_text    TYPE char90 VALUE 'Bestellung, wird bereits von einem anderen User bearbeitet' ##no_text,
               lc_kind    TYPE char4  VALUE 'INFO'                                                       ##no_text,
               lc_button1 TYPE char15 VALUE 'OK'                                                         ##no_text.

    CLEAR me->ms_positionen.
    me->ms_positionen = me->search_selected_bestellung( ).

    "Sperren der ausgewählten Bestellung zum Bearbeiten
*    lv_sy_subrc = me->enqueue_zsbt_bestellung( ).

    IF me->enqueue_zsbt_bestellung( ) = 0.
      "Rufe View Positionsübersicht auf
      me->mo_web_shop_view->call_positionsuebersicht( ).

    ELSEIF me->enqueue_zsbt_bestellung( ) = 1.
      "Wenn eine Sperre vorhanden ist soll der User nicht die Möglichkeit haben den Eintrag zu bearbeiten
      "Anzeige ein Pop-Ups mit Info Text, dass  ein User bereits bearbeitet
      DATA(lv_btn) = /auk/cl_msgbox=>show_msgbox( im_text    = lc_text
                                                  im_kind    = lc_kind
                                                  im_button1 = lc_button1 ).

      IF lv_btn = 1.

        "Kehre zur Bestellungsauswahl zurück
        me->on_bestellungsuebersicht_pbo( ).
      ELSE.
        "Do nothing
      ENDIF.

    ELSEIF me->enqueue_zsbt_bestellung( ) = 2 OR me->enqueue_zsbt_bestellung( ) = 3.
      "Falls ein Fehler beim Sperren auftritt
      MESSAGE i037(zsbt_web_shop).
      RAISE EXCEPTION TYPE zcx_sbt_web_shop_exception USING MESSAGE.
    ENDIF.

  ENDMETHOD.


  METHOD on_positions_uebersicht_pbo.

    SET PF-STATUS '9002'                OF PROGRAM 'SAPLZSBT_WEB_SHOP'.
    SET TITLEBAR 'POSITIONSUEBERSICHT'  OF PROGRAM 'SAPLZSBT_WEB_SHOP'.

    CLEAR me->mt_positionen.
    "Hole aktuelle Positionen zur Bestellnummer
    me->mo_web_shop_model->get_positions( iv_bestellnummer = ms_positionen-bestellnummer ).
    me->mt_positionen = me->mo_web_shop_model->get_positions_ausgabe( ).

    IF me->mt_positionen IS INITIAL.
      "Raise Exception mit USING MESSAGE
      MESSAGE i020(zsbt_web_shop) INTO DATA(ls_msg).
      RAISE EXCEPTION TYPE zcx_sbt_web_shop_exception USING MESSAGE.
    ENDIF.

    me->create_alv_position( ).

  ENDMETHOD.


  METHOD on_refresh.

    "Selekiert die aktuellen Daten
    mo_web_shop_model->get_information(
      EXPORTING
        iv_filter        =     mv_filter          " gibt an nach was selektiert werden soll
        iv_kundennummer  =     mv_kundennummer    " Kundennummer
        iv_bestellnummer =     mv_bestellnummer   " Bestellnummer
        iv_status        =     mv_status          " Bestellstatus
            ).

    "Aktuelle Daten werden zu einer Ausgabe-Tabelle verarbeitet
    me->mo_web_shop_model->get_bestellungenansicht( ).

    "Refresh Tabelle mit aktuellen Daten
    me->mo_alv_grid_bestellubersicht->refresh_table_display( ).


  ENDMETHOD.


  METHOD on_start.

    "Selekierte Daten vom Model
    mo_web_shop_model->get_information(
      EXPORTING
        iv_filter        =     mv_filter          " gibt an nach was selektiert werden soll
        iv_kundennummer  =     mv_kundennummer    " Kundennummer
        iv_bestellnummer =     mv_bestellnummer   " Bestellnummer
        iv_status        =     mv_status          " Bestellstatus
    ).

    "Aufrufen der View
    mo_web_shop_view->call_bestelluebersicht( ).

  ENDMETHOD.


  METHOD on_toolbar_btn_delete_best.

    CASE e_ucomm.
      WHEN 'DELETE'.
        me->on_delete( ).
      WHEN OTHERS.
    ENDCASE.

  ENDMETHOD.


  METHOD on_toolbar_btn_delete_pos.

    CASE e_ucomm.
      WHEN 'DELETE'.
        me->on_delete_position( ).
      WHEN OTHERS.
        "Kommt nicht vor, daher passiert hier nichts
    ENDCASE.

  ENDMETHOD.


  METHOD refresh_position.

    "Aktuelle Daten beschaffen
    CLEAR me->mt_positionen.
    "Hole aktuelle Positionen zur Bestellnummer
    me->mo_web_shop_model->get_positions( iv_bestellnummer = ms_positionen-bestellnummer ).
    me->mt_positionen = me->mo_web_shop_model->get_positions_ausgabe( ).

    IF me->mt_positionen IS INITIAL.
      "Raise Exception mit USING MESSAGE
      MESSAGE i020(zsbt_web_shop) INTO DATA(ls_msg).
      RAISE EXCEPTION TYPE zcx_sbt_web_shop_exception USING MESSAGE.
    ENDIF.

    "Positionsübersicht aktualisieren
    me->mo_alv_grid_positionsubersicht->refresh_table_display( ).

  ENDMETHOD.


  METHOD search_selected_bestellung.

    DATA:  it_sel_rows TYPE lvc_t_row.

    "Hole index Selektierte Zeile
    me->mo_alv_grid_bestellubersicht->get_selected_rows( IMPORTING et_index_rows = it_sel_rows ).

    LOOP AT it_sel_rows ASSIGNING  FIELD-SYMBOL(<lv_sel_rows>).
      "Suche Markierte Zeile anhand index und gebe Markierten Eintrag in ls_zwischen
      READ TABLE  me->mo_web_shop_model->get_ansicht( ) INTO DATA(ls_zwischen) INDEX <lv_sel_rows>-index.
      IF sy-subrc NE 0.
        MESSAGE: e024(zsbt_web_shop) INTO DATA(ls_msg).
        RAISE EXCEPTION TYPE zcx_sbt_web_shop_exception USING MESSAGE.
      ENDIF.
    ENDLOOP.

    rs_selected_bestellung = ls_zwischen.

  ENDMETHOD.


  METHOD search_selected_position.

    "Hole index Selektierte Zeile
    me->mo_alv_grid_positionsubersicht->get_selected_rows( IMPORTING et_index_rows = DATA(it_sel_rows) ).

    "Falls keine Position angeklickt wurde, wird alternativ die erste Position der Bestellung ausgewählt
    IF it_sel_rows IS INITIAL.
      rs_bestellpositionen = VALUE zsbt_bestellung( mt_positionen[ 1 ] OPTIONAL ).
    ELSE.
      "Falls User eine Position ausgewählt hat
      rs_bestellpositionen = VALUE zsbt_bestellung( mt_positionen[ it_sel_rows[ 1 ]-index ] OPTIONAL ).
    ENDIF.

    "Falls ein keine Position in der Struktur ist
    IF rs_bestellpositionen IS INITIAL.
      MESSAGE i036(zsbt_web_shop) INTO DATA(ls_msg).
      RAISE EXCEPTION TYPE zcx_sbt_web_shop_exception USING MESSAGE.
    ENDIF.

  ENDMETHOD.
ENDCLASS.
