*---------------------------------------------------------------------*
*    view related data declarations
*   generation date: 07.04.2020 at 15:06:16
*   view maintenance generator version: #001407#
*---------------------------------------------------------------------*
*...processing: ZSBT_BESTELLUNG.................................*
DATA:  BEGIN OF STATUS_ZSBT_BESTELLUNG               .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZSBT_BESTELLUNG               .
CONTROLS: TCTRL_ZSBT_BESTELLUNG
            TYPE TABLEVIEW USING SCREEN '0003'.
*...processing: ZSBT_BESTTELUNG.................................*
DATA:  BEGIN OF STATUS_ZSBT_BESTTELUNG               .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZSBT_BESTTELUNG               .
CONTROLS: TCTRL_ZSBT_BESTTELUNG
            TYPE TABLEVIEW USING SCREEN '0001'.
*.........table declarations:.................................*
TABLES: *ZSBT_BESTELLUNG               .
TABLES: *ZSBT_BESTTELUNG               .
TABLES: ZSBT_BESTELLUNG                .
TABLES: ZSBT_BESTTELUNG                .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
