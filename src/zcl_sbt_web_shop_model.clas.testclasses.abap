*"* use this source file for your ABAP unit test classes^
CLASS ltc_web_shop_model DEFINITION FOR TESTING
RISK LEVEL HARMLESS
DURATION SHORT.

  PUBLIC SECTION.
    METHODS delete_order_from_odernumber_1 FOR TESTING.
    METHODS delete_order_exception_exist FOR TESTING.

  PRIVATE SECTION.
    CONSTANTS: lc_bestellnummer   TYPE zsbt_bestellnummer_de VALUE  '1',
               lc_positionsnummer TYPE zsbt_positionsnummer_de VALUE '1'.
    DATA m_cut TYPE REF TO zcl_sbt_web_shop_model.
    CLASS-DATA: m_enviroment TYPE REF TO if_osql_test_environment.
    CLASS-METHODS class_setup.
    METHODS setup.


ENDCLASS.

CLASS ltc_web_shop_model IMPLEMENTATION.


  METHOD setup.

    "given
    m_cut = NEW zcl_sbt_web_shop_model( ).

  ENDMETHOD.



  METHOD delete_order_from_odernumber_1.

    "given
    DATA: lt_order_data TYPE TABLE OF zsbt_bestellung.

    lt_order_data = VALUE #( ( bestellnummer = lc_bestellnummer positionsnummer = lc_positionsnummer ) ).
    m_enviroment->insert_test_data( EXPORTING i_data = lt_order_data ).

    "when
    m_cut->delete_order( iv_bestellnummer = lc_bestellnummer ).

    "then
    SELECT SINGLE bestellnummer
    FROM zsbt_bestellung
    INTO @DATA(ls_data)
    WHERE bestellnummer = @lc_bestellnummer.

    IF sy-subrc = 0.
      cl_abap_unit_assert=>fail( EXPORTING msg = 'Bestelllung wurde nicht gelöscht'  ).                            " Description
    ENDIF.


  ENDMETHOD.






  METHOD delete_order_exception_exist.

    TRY.
        "when
        m_cut->delete_order( iv_bestellnummer = lc_bestellnummer ).
        "then
        cl_abap_unit_assert=>fail( EXPORTING msg = 'Es werden keine Exceptions abgefangen'  ).

      CATCH zcx_sbt_web_shop_exception.

    ENDTRY.

  ENDMETHOD.

  METHOD class_setup.
    m_enviroment = cl_osql_test_environment=>create( i_dependency_list = VALUE #( ( 'zsbt_bestellung' ) ) ).
  ENDMETHOD.

ENDCLASS.
