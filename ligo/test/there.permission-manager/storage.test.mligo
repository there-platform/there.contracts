#include "../../there.permission-manager/permission_manager.mligo"

let get_permission_manager_contract (new_minter, reset : address option * bool) =
    let () = if reset then Test.reset_state 10n ([]: tez list) else () in

    let admin_str = {
        admin = Test.nth_bootstrap_account 0;
        pending_admin = (None: address option);
    } in
    
    match new_minter with
        Some m -> (
            let str = {
                admin_str  = admin_str;
                minters = Big_map.literal([(m, ());]) ;
                space_managers = Big_map.literal([(m, ());]) ;
                auction_house_managers = Big_map.literal([(m, ());]) ;
                metadata = ((Big_map.empty : (string, bytes) big_map));
            } in

            let addr, _, _ = Test.originate_from_file "/Users/thedude/Documents/Pro/D.art/there.contracts/ligo/there.permission-manager/views.mligo" "permission_manager_main" ([] : string list) (Test.compile_value str) 0tez in
            let taddr : (art_permission_manager, storage) typed_address = Test.cast_address addr in
            taddr, addr
        )
        | None ->  (
            let str = {
                admin_str  = admin_str;
                minters = (Big_map.empty : (address, unit) big_map);
                space_managers = (Big_map.empty : (address, unit) big_map);
                auction_house_managers = (Big_map.empty : (address, unit) big_map);
                metadata = ((Big_map.empty : (string, bytes) big_map));
            } in

            let addr, _, _ = Test.originate_from_file "/Users/thedude/Documents/Pro/D.art/there.contracts/ligo/there.permission-manager/views.mligo" "permission_manager_main" ([] : string list) (Test.compile_value str) 0tez in
            let taddr : (art_permission_manager, storage) typed_address = Test.cast_address addr in
            taddr, addr
        )