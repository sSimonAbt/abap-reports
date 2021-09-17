*---------------------------------------------------------------------*
*    program for:   TABLEFRAME_ZSBT_ARTIKEL_PFL
*   generation date: 26.06.2020 at 09:23:22
*   view maintenance generator version: #001407#
*---------------------------------------------------------------------*
FUNCTION TABLEFRAME_ZSBT_ARTIKEL_PFL   .

  PERFORM TABLEFRAME TABLES X_HEADER X_NAMTAB DBA_SELLIST DPL_SELLIST
                            EXCL_CUA_FUNCT
                     USING  CORR_NUMBER VIEW_ACTION VIEW_NAME.

ENDFUNCTION.
