export type RoyaltySplitsFactoryViewCodeType = { __type: 'RoyaltySplitsFactoryViewCodeType'; code: string; };
export default {
  __type: 'RoyaltySplitsFactoryViewCodeType', code: `
  { UNPAIR ;
    SWAP ;
    DUP ;
    DUG 2 ;
    CAR ;
    CDR ;
    CDR ;
    SWAP ;
    EDIV ;
    IF_NONE { PUSH string "DIV by 0" ; FAILWITH } {} ;
    CAR ;
    SWAP ;
    CAR ;
    CDR ;
    CAR ;
    SWAP ;
    GET ;
    IF_NONE
      { PUSH string "FA2_TOKEN_UNDEFINED" ; FAILWITH }
      { DUP ; GET 6 ; SWAP ; GET 5 ; PAIR } }
  `
} as RoyaltySplitsFactoryViewCodeType;
;
