*---------------------------------------------------------------------*
*    view related data declarations
*   generation date: 23.03.2021 at 08:01:44
*   view maintenance generator version: #001407#
*---------------------------------------------------------------------*
*...processing: ZSBT_DB_LAGER...................................*
DATA:  BEGIN OF STATUS_ZSBT_DB_LAGER                 .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZSBT_DB_LAGER                 .
CONTROLS: TCTRL_ZSBT_DB_LAGER
            TYPE TABLEVIEW USING SCREEN '0001'.
*.........table declarations:.................................*
TABLES: *ZSBT_DB_LAGER                 .
TABLES: ZSBT_DB_LAGER                  .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
