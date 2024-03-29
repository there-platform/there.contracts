#import "../there.fa2-editions/storage.test.mligo" "FA2_STR"
#import "../there.fa2-editions/storage_space.test.mligo" "FA2_SPACE_STR"
#import "../there.permission-manager/storage.test.mligo" "PM_STR"

#include "../../there.fixed-price/fixed_price_main.mligo"

let get_fixed_price_contract_drop (will_update, isDropped, isInDrops, drop_date : bool * bool * bool * timestamp) = 
    let () = Test.reset_state 10n ([233710368547757mutez; 233710368547757mutez; 233710368547757mutez; 233710368547757mutez; 233710368547757mutez; 233710368547757mutez; 233710368547757mutez; 233710368547757mutez] : tez list) in
    
    let admin = Test.nth_bootstrap_account 0 in
    let fee_account = Test.nth_bootstrap_account 2 in
    let _, permission_m_add = PM_STR. get_permission_manager_contract((None : address option), false) in
    
    let admin_str : admin_storage = {
        permission_manager = permission_m_add;
        contract_will_update = will_update;
        referral_activated = True;
    } in

    let empty_sales = (Big_map.empty : (fa2_base * address, fixed_price_sale) big_map ) in
    let empty_drops = (Big_map.empty : (fa2_base * address, fixed_price_drop) big_map) in
    let empty_dropped = (Big_map.empty : (fa2_base, unit) big_map) in
    
    let dropped : (fa2_base, unit ) big_map = Big_map.literal ([
                (({
                    id = 0n;
                    address = ("KT1Ti9x7gXoDzZGFgLC23ZRn3SnjMZP2y5gD" : address);
                } : fa2_base), ());
            ]) in

    let fa2_b_1 : fa2_base = {
                    id = 0n;
                    address = ("KT1Ti9x7gXoDzZGFgLC23ZRn3SnjMZP2y5gD" : address);
                } in
    
    let fa2_b_2 : fa2_base = {
                    id = 1n;
                    address = ("KT1Ti9x7gXoDzZGFgLC23ZRn3SnjMZP2y5gD" : address);
                } in

    let drops_str : drops_storage = Big_map.literal ([
        ((fa2_b_1, admin),
            ({
                commodity = (Tez (1000000mutez));
                drop_date = drop_date;
            })
        );
        ((fa2_b_2, admin),
            ({
                commodity = (Tez (1000000mutez));
                drop_date = drop_date;
            })
        );
    ]) in
    let empty_offers = (Big_map.empty : (fa2_base * address, commodity) big_map) in

    let stable_coin = {
        address = ("KT1RVK54ne4gFfqyMwGD6zZk4crFkf1TD1kn" : address);
        id = 0n;
    } in

    let str = {
        admin = admin_str;
        for_sale = empty_sales ;
        drops = empty_drops;
        fa2_sold = (Big_map.empty : (fa2_base, unit) big_map);
        fa2_dropped = empty_dropped;
        offers = empty_offers;
        fee_primary = {
            address = admin;
            percent = 10n;
        };
        fee_secondary = {
            address = fee_account;
            percent = 3n;
        };
        stable_coin = Big_map.literal([((stable_coin : fa2_base), (1000000n));]);
        metadata = (Big_map.empty : (string, bytes) big_map);
    } in


    if isDropped
    then (
        if isInDrops
        then (
            let str = { str with drops = drops_str; fa2_dropped = dropped } in
            let addr, _, _ = Test.originate_from_file "/Users/thedude/Documents/Pro/D.art/there.contracts/ligo/there.fixed-price/fixed_price_main.mligo" "fixed_price_main" ([] : string list) (Test.compile_value str) 0tez in
            let taddr : (fixed_price_entrypoints, storage) typed_address = Test.cast_address addr in
    
            let fa2_add = FA2_STR.get_edition_fa2_contract_fixed_price (addr) in
            let t_fa2_add : (FA2_STR.FA2_E.editions_entrypoints, FA2_STR.FA2_E.editions_storage) typed_address = Test.cast_address fa2_add in

            addr, taddr, fa2_add, t_fa2_add, admin

        )
        else (
            let str = { str with fa2_dropped = dropped } in
            let addr, _, _ = Test.originate_from_file "/Users/thedude/Documents/Pro/D.art/there.contracts/ligo/there.fixed-price/fixed_price_main.mligo" "fixed_price_main" ([] : string list) (Test.compile_value str) 0tez in
            let taddr : (fixed_price_entrypoints, storage) typed_address = Test.cast_address addr in
    
            let fa2_add = FA2_STR.get_edition_fa2_contract_fixed_price (addr) in
            let t_fa2_add : (FA2_STR.FA2_E.editions_entrypoints, FA2_STR.FA2_E.editions_storage) typed_address = Test.cast_address fa2_add in

            addr, taddr, fa2_add, t_fa2_add, admin

        )
    )
    else (
        if isInDrops
        then (
            let str = { str with drops = drops_str } in
            let addr, _, _ = Test.originate_from_file "/Users/thedude/Documents/Pro/D.art/there.contracts/ligo/there.fixed-price/fixed_price_main.mligo" "fixed_price_main" ([] : string list) (Test.compile_value str) 0tez in
            let taddr : (fixed_price_entrypoints, storage) typed_address = Test.cast_address addr in
    
            let fa2_add = FA2_STR.get_edition_fa2_contract_fixed_price (addr) in
            let t_fa2_add : (FA2_STR.FA2_E.editions_entrypoints, FA2_STR.FA2_E.editions_storage) typed_address = Test.cast_address fa2_add in

            addr, taddr, fa2_add, t_fa2_add, admin

        )
        else (
            let addr, _, _ = Test.originate_from_file "/Users/thedude/Documents/Pro/D.art/there.contracts/ligo/there.fixed-price/fixed_price_main.mligo" "fixed_price_main" ([] : string list) (Test.compile_value str) 0tez in
            let taddr : (fixed_price_entrypoints, storage) typed_address = Test.cast_address addr in
    
            let fa2_add = FA2_STR.get_edition_fa2_contract_fixed_price (addr) in
            let t_fa2_add : (FA2_STR.FA2_E.editions_entrypoints, FA2_STR.FA2_E.editions_storage) typed_address = Test.cast_address fa2_add in

            addr, taddr, fa2_add, t_fa2_add, admin
        )
    )

let get_fixed_price_contract (signature_saved : bool) = 
    let () = Test.reset_state 10n ([233710368547757mutez; 233710368547757mutez; 233710368547757mutez; 233710368547757mutez; 233710368547757mutez; 233710368547757mutez; 233710368547757mutez; 233710368547757mutez] : tez list) in
    
    let admin = Test.nth_bootstrap_account 0 in
    let fee_account = Test.nth_bootstrap_account 2 in

    let _, permission_m_add = PM_STR. get_permission_manager_contract((None : address option), false) in
    
    let admin_str : admin_storage = {
        permission_manager = permission_m_add;
        contract_will_update = False;
        referral_activated = True;
    } in

    let stable_coin = {
        address = ("KT1RVK54ne4gFfqyMwGD6zZk4crFkf1TD1kn" : address);
        id = 0n;
    } in

    let empty_sales = (Big_map.empty : (fa2_base * address, fixed_price_sale) big_map ) in
    let drops_str = (Big_map.empty : (fa2_base * address, fixed_price_drop) big_map) in
    let empty_dropped = (Big_map.empty : (fa2_base, unit) big_map) in
    let empty_offers = (Big_map.empty : (fa2_base * address, commodity) big_map) in
    
    let str = {
        admin = admin_str;
        for_sale = empty_sales ;
        drops = drops_str;
        fa2_sold = empty_dropped;
        fa2_dropped = empty_dropped;
        offers = empty_offers;
        fee_primary = {
            address = fee_account;
            percent = 100n;
        };
        fee_secondary = {
            address = fee_account;
            percent = 35n;
        };
        stable_coin = Big_map.literal([((stable_coin : fa2_base), (1000000n));]);
        metadata = (Big_map.empty : (string, bytes) big_map);
    } in

    let addr, _, _ = Test.originate_from_file "/Users/thedude/Documents/Pro/D.art/there.contracts/ligo/there.fixed-price/fixed_price_main.mligo" "fixed_price_main" ([] : string list) (Test.compile_value str) 0tez in
    let taddr : (fixed_price_entrypoints, storage) typed_address = Test.cast_address addr in
    
    let fa2_add = FA2_STR.get_edition_fa2_contract_fixed_price (addr) in
    let t_fa2_add : (FA2_STR.FA2_E.editions_entrypoints, FA2_STR.FA2_E.editions_storage) typed_address = Test.cast_address fa2_add in

    addr, taddr, fa2_add, t_fa2_add, admin
    

let get_fixed_price_contract_space (signature_saved, referral_activated : bool * bool ) =
    let () = Test.reset_state 10n ([233710368547757mutez; 233710368547757mutez; 233710368547757mutez; 233710368547757mutez; 233710368547757mutez; 233710368547757mutez; 233710368547757mutez; 233710368547757mutez] : tez list) in
    
    let admin = Test.nth_bootstrap_account 0 in
    let fee_account = Test.nth_bootstrap_account 2 in

    let _, permission_m_add = PM_STR. get_permission_manager_contract((None : address option), false) in

    let admin_str : admin_storage = {
        permission_manager = permission_m_add;
        contract_will_update = False;
        referral_activated = referral_activated;
    } in

    let stable_coin = {
        address = ("KT1RVK54ne4gFfqyMwGD6zZk4crFkf1TD1kn" : address);
        id = 0n;
    } in

    let empty_sales = (Big_map.empty : (fa2_base * address, fixed_price_sale) big_map ) in
    let drops_str = (Big_map.empty : (fa2_base * address, fixed_price_drop) big_map) in
    let empty_dropped = (Big_map.empty : (fa2_base, unit) big_map) in
    let empty_offers = (Big_map.empty : (fa2_base * address, commodity) big_map) in
    
    let str = {
        admin = admin_str;
        for_sale = empty_sales ;
        drops = drops_str;
        fa2_sold = empty_dropped;
        fa2_dropped = empty_dropped;
        offers = empty_offers;
        fee_primary = {
            address = fee_account;
            percent = 100n;
        };
        fee_secondary = {
            address = fee_account;
            percent = 35n;
        };
        stable_coin = Big_map.literal([((stable_coin : fa2_base), (1000000n));]);
        metadata = (Big_map.empty : (string, bytes) big_map);
    } in

    let addr, _, _ = Test.originate_from_file "/Users/thedude/Documents/Pro/D.art/there.contracts/ligo/there.fixed-price/fixed_price_main.mligo" "fixed_price_main" ([] : string list) (Test.compile_value str) 0tez in
    let taddr : (fixed_price_entrypoints, storage) typed_address = Test.cast_address addr in

    let t_fa2_space_add, space, fa2_space_add, _ = FA2_SPACE_STR.get_fa2_editions_space_contract_fixed_price (addr) in
    addr, taddr, space, fa2_space_add, t_fa2_space_add, admin
    