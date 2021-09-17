*---------------------------------------------------------------------*
*    view related data declarations
*   generation date: 26.06.2020 at 09:23:23
*   view maintenance generator version: #001407#
*---------------------------------------------------------------------*
*...processing: ZSBT_ARTIKEL....................................*
DATA:  BEGIN OF STATUS_ZSBT_ARTIKEL                  .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZSBT_ARTIKEL                  .
CONTROLS: TCTRL_ZSBT_ARTIKEL
            TYPE TABLEVIEW USING SCREEN '0001'.
*.........table declarations:.................................*
TABLES: *ZSBT_ARTIKEL                  .
TABLES: ZSBT_ARTIKEL                   .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
