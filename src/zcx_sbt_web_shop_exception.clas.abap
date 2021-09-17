class ZCX_SBT_WEB_SHOP_EXCEPTION definition
  public
  inheriting from CX_NO_CHECK
  final
  create public .

public section.

  interfaces IF_T100_DYN_MSG .
  interfaces IF_T100_MESSAGE .

  constants:
    begin of OBJECT_NOT_FOUND,
      msgid type symsgid value 'ZSBT_WEB_SHOP',
      msgno type symsgno value '029',
      attr1 type scx_attrname value 'T100_MSGV1',
      attr2 type scx_attrname value 'T100_MSGV2',
      attr3 type scx_attrname value 'T100_MSGV3',
      attr4 type scx_attrname value 'T100_MSGV4',
    end of OBJECT_NOT_FOUND .
  constants:
    begin of ALV_NOT_ABLE_TO_CREATE,
      msgid type symsgid value 'ZSBT_WEB_SHOP',
      msgno type symsgno value '022',
      attr1 type scx_attrname value '',
      attr2 type scx_attrname value '',
      attr3 type scx_attrname value '',
      attr4 type scx_attrname value '',
    end of ALV_NOT_ABLE_TO_CREATE .
  constants:
    begin of ORDER_NOT_FOUND,
      msgid type symsgid value 'ZSBT_WEB_SHOP',
      msgno type symsgno value '025',
      attr1 type scx_attrname value '',
      attr2 type scx_attrname value '',
      attr3 type scx_attrname value '',
      attr4 type scx_attrname value '',
    end of ORDER_NOT_FOUND .
  constants:
    begin of POSITIONS_NOT_FOUND,
      msgid type symsgid value 'ZSBT_WEB_SHOP',
      msgno type symsgno value '030',
      attr1 type scx_attrname value '',
      attr2 type scx_attrname value '',
      attr3 type scx_attrname value '',
      attr4 type scx_attrname value '',
    end of POSITIONS_NOT_FOUND .

  methods CONSTRUCTOR
    importing
      !TEXTID like IF_T100_MESSAGE=>T100KEY optional
      !PREVIOUS like PREVIOUS optional .
  methods GET_MESSAGE
    returning
      value(RS_MSG) type BAL_S_MSG .
protected section.
private section.
ENDCLASS.



CLASS ZCX_SBT_WEB_SHOP_EXCEPTION IMPLEMENTATION.


  method CONSTRUCTOR.
CALL METHOD SUPER->CONSTRUCTOR
EXPORTING
PREVIOUS = PREVIOUS
.
clear me->textid.
if textid is initial.
  IF_T100_MESSAGE~T100KEY = IF_T100_MESSAGE=>DEFAULT_TEXTID.
else.
  IF_T100_MESSAGE~T100KEY = TEXTID.
endif.
  endmethod.


  method GET_MESSAGE.

   rs_msg = VALUE #( msgty = sy-msgty
                     msgid = sy-msgid
                     msgno = sy-msgno
                     msgv1 = sy-msgv1
                     msgv2 = sy-msgv2
                     msgv3 = sy-msgv3
                     msgv4 = sy-msgv4 ).

  endmethod.
ENDCLASS.
