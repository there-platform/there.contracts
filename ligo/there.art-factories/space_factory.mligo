#if !SPACE_CONTRACT
#define SPACE_CONTRACT

#include "../there.fa2-editions/interface.mligo"

#include "interface.mligo"
#include "check.mligo"

type lambda_create_contract = (key_hash option * tez * editions_storage) -> (operation * address) 

type art_factory = 
    |   Create_space of create_entrypoint
    |   Update_permission_manager of address

let create_space (param, storage : create_entrypoint * storage) : (operation list) * storage = 
    let editions_metadata_str = (Big_map.empty : (nat, edition_metadata) big_map) in
    
    let asset_str = {
        ledger = (Big_map.empty : (token_id, address) big_map);
        operators = (Big_map.empty : ((address * (address * token_id)), unit) big_map);
        token_metadata = (Big_map.empty : (token_id, token_metadata) big_map);
    } in
    
    let admin_str : admin_storage = {
        admins = Big_map.literal ([(Tezos.get_sender(), ())]) ;
        minters = (Big_map.empty : (address, unit) big_map);
        pending_minters = (Big_map.empty : (address, unit) big_map);
        pending_admins = (Big_map.empty : (address, unit) big_map);
    } in

    let initial_str = {
        next_edition_id = 0n;
        max_editions_per_run = 50n;
        mint_proposals = editions_metadata_str;
        editions_metadata = editions_metadata_str;
        assets = asset_str;
        admin = admin_str;
        metadata = Big_map.literal([("", param.metadata); ("symbol", param.symbol);]);
    } in

    let create_contract : lambda_create_contract =
      [%Michelson ( {| { 
            UNPAIR ;
            UNPAIR ;
            CREATE_CONTRACT 
#include "compile/space.tz"
               ;
            PAIR } |}
              : lambda_create_contract)]
    in

    let origination : operation * address = create_contract ((None: key_hash option), 0tez, initial_str) in
    let new_str = { storage with spaces = Big_map.add (Tezos.get_sender()) origination.1 storage.spaces; } in

    [origination.0], new_str


let space_factory_main (param, storage : art_factory * storage)  : (operation list) * storage = 
    let () : unit = assert_msg (Tezos.get_amount() = 0mutez, "AMOUNT_SHOULD_BE_0TEZ") in
    match param with
        |   Create_space create_param ->
                let () : unit = fail_if_not_space_manager storage in 
                let () : unit = fail_if_already_originated storage in
                create_space (create_param, storage)

        |   Update_permission_manager add ->
                let () = fail_if_not_admin storage in 
                (([] : operation list), { storage with permission_manager = add; })

#endif