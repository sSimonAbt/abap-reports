*---------------------------------------------------------------------*
*    program for:   TABLEFRAME_ZSBT_BESTTELUNG
*   generation date: 30.09.2019 at 13:19:18
*   view maintenance generator version: #001407#
*---------------------------------------------------------------------*
FUNCTION TABLEFRAME_ZSBT_BESTTELUNG    .

  PERFORM TABLEFRAME TABLES X_HEADER X_NAMTAB DBA_SELLIST DPL_SELLIST
                            EXCL_CUA_FUNCT
                     USING  CORR_NUMBER VIEW_ACTION VIEW_NAME.

ENDFUNCTION.
