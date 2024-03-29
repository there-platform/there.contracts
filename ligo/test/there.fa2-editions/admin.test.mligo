#import "storage.test.mligo" "FA2_STR"
#import "storage_serie.test.mligo" "FA2_SERIE_STR"
#import "storage_space.test.mligo" "FA2_SPACE_STR"
#include "../../there.fa2-editions/multi_nft_token_editions.mligo"

// TEST FILE FOR ADMIN ENTRYPOINTS

// -- Pause minting --

// Fail not admin
let test_pause_minting_not_admin =
    let contract_add, _, owner1, _ = FA2_STR.get_fa2_editions_contract(false) in
    let contract = Test.to_contract contract_add in

    let () = Test.set_source owner1 in

    let result = Test.transfer_to_contract contract ((Admin ((Pause_minting (true)) : FA2_STR.FA2_E.admin_entrypoints)) : editions_entrypoints) 0tez in

    match result with
        Success _gas -> failwith "Admin -> Pause_minting - Not admin : This test should fail"
    |   Fail (Rejected (err, _)) -> (
            let () = assert_with_error ( Test.michelson_equal err (Test.eval "NOT_AN_ADMIN") ) "Admin -> Pause_minting - Not admin : Should not work if sender not admin" in
            "Passed"
        )
    |   Fail _ -> failwith "Internal test failure"    

// Fail no amount
let test_pause_minting_no_amount =
    let contract_add, _, owner1, _ = FA2_STR.get_fa2_editions_contract(false) in
    let contract = Test.to_contract contract_add in

    let () = Test.set_source owner1 in

    let result = Test.transfer_to_contract contract ((Admin ((Pause_minting (true)) : FA2_STR.FA2_E.admin_entrypoints)) : editions_entrypoints) 1tez in

    match result with
        Success _gas -> failwith "Admin -> Pause_minting - No amount : This test should fail"
    |   Fail (Rejected (err, _)) -> (
            let () = assert_with_error ( Test.michelson_equal err (Test.eval "AMOUNT_SHOULD_BE_0TEZ") ) "Admin -> Pause_minting - No amount : Should not work if amount specified" in
            "Passed"
        )
    |   Fail _ -> failwith "Internal test failure"    

// Success
let test_pause_minting =
    let contract_add, admin, _, _ = FA2_STR.get_fa2_editions_contract(false) in
    let contract = Test.to_contract contract_add in

    let () = Test.set_source admin in

    let _gas = Test.transfer_to_contract_exn contract ((Admin ((Pause_minting (true)) : FA2_STR.FA2_E.admin_entrypoints)) : editions_entrypoints) 0tez in

    let new_str = Test.get_storage contract_add in
    let () = assert_with_error (new_str.admin.paused_minting = true) "Admin -> Pause_minting - Success : This test should pass :  Wrong paused_minting" in
    "Passed"

// -- Update minter manager -

// Fail not admin
let test_update_permission_manager_not_admin =
    let contract_add, _, owner1, _ = FA2_STR.get_fa2_editions_contract(false) in
    let contract = Test.to_contract contract_add in

    let () = Test.set_source owner1 in

    let result = Test.transfer_to_contract contract ((Admin ((Update_permission_manager ("KT1FxpxCvERyYhhwisypGgfUSU3EkGf8XVen" : address) : FA2_STR.FA2_E.admin_entrypoints))) : editions_entrypoints) 0tez in

    match result with
        Success _gas -> failwith "Admin -> Update_permission_manager - Not admin : This test should fail"
    |   Fail (Rejected (err, _)) -> (
            let () = assert_with_error ( Test.michelson_equal err (Test.eval "NOT_AN_ADMIN") ) "Admin -> Update_permission_manager - Not admin : Should not work if sender not admin" in
            "Passed"
        )
    |   Fail _ -> failwith "Internal test failure"    

// Fail no amount
let test_update_permission_manager_no_amount =
    let contract_add, _, owner1, _ = FA2_STR.get_fa2_editions_contract(false) in
    let contract = Test.to_contract contract_add in

    let () = Test.set_source owner1 in

    let result = Test.transfer_to_contract contract ((Admin ((Update_permission_manager ("KT1FxpxCvERyYhhwisypGgfUSU3EkGf8XVen" : address) : FA2_STR.FA2_E.admin_entrypoints))) : editions_entrypoints) 1tez in

    match result with
        Success _gas -> failwith "Admin -> Pause_minting - No amount : This test should fail"
    |   Fail (Rejected (err, _)) -> (
            let () = assert_with_error ( Test.michelson_equal err (Test.eval "AMOUNT_SHOULD_BE_0TEZ") ) "Admin -> Update_permission_manager - No amount : Should not work if amount specified" in
            "Passed"
        )
    |   Fail _ -> failwith "Internal test failure"    

// Success
let test_update_permission_manager =
    let contract_add, admin, _, _ = FA2_STR.get_fa2_editions_contract(false) in
    let contract = Test.to_contract contract_add in

    let () = Test.set_source admin in

    let _gas = Test.transfer_to_contract_exn contract ((Admin ((Update_permission_manager ("KT1FxpxCvERyYhhwisypGgfUSU3EkGf8XVen" : address) : FA2_STR.FA2_E.admin_entrypoints))) : editions_entrypoints) 0tez in

    let new_str = Test.get_storage contract_add in
    let () = assert_with_error (new_str.admin.permission_manager = ("KT1FxpxCvERyYhhwisypGgfUSU3EkGf8XVen" : address)) "Admin -> Update_permission_manager - Success : This test should pass :  Wrong permission_manager" in
    "Passed"

// -- FA2 editions version originated from Serie factory contract

// Revoke minting

// Fail not admin
let test_serie_factory_originated_revoke_minting_not_admin =
    let contract_add, _, owner1, _ = FA2_SERIE_STR.get_fa2_editions_serie_contract(false) in
    let contract = Test.to_contract contract_add in

    let () = Test.set_source owner1 in

    let result = Test.transfer_to_contract contract ((Revoke_minting ({ revoke = true } : FA2_SERIE_STR.revoke_minting_param)) : FA2_SERIE_STR.editions_entrypoints) 0tez in

    match result with
        Success _gas -> failwith "Admin (Serie originated fa2 contract) -> Revoke_minting - Not admin : This test should fail"
    |   Fail (Rejected (err, _)) -> (
            let () = assert_with_error ( Test.michelson_equal err (Test.eval "NOT_AN_ADMIN") ) "Admin (Serie originated fa2 contract) -> Revoke_minting - Not admin : Should not work if sender not admin" in
            "Passed"
        )
    |   Fail _ -> failwith "Internal test failure"    

// Fail no amount
let test_serie_factory_originated_revoke_minting_no_amount =
    let contract_add, _, owner1, _ = FA2_SERIE_STR.get_fa2_editions_serie_contract(false) in
    let contract = Test.to_contract contract_add in

    let () = Test.set_source owner1 in

    let result = Test.transfer_to_contract contract  ((Revoke_minting ({ revoke = true } : FA2_SERIE_STR.revoke_minting_param)) : FA2_SERIE_STR.editions_entrypoints) 1tez in

    match result with
        Success _gas -> failwith "Admin (Serie originated fa2 contract) -> Revoke_minting - No amount : This test should fail"
    |   Fail (Rejected (err, _)) -> (
            let () = assert_with_error ( Test.michelson_equal err (Test.eval "AMOUNT_SHOULD_BE_0TEZ") ) "Admin (Serie originated fa2 contract) -> Revoke_minting - No amount : Should not work if amount specified" in
            "Passed"
        )
    |   Fail _ -> failwith "Internal test failure"    

// Fail undo revoke minting
let test_serie_factory_originated_undo_revoke_minting =
    let contract_add, admin, _, _ = FA2_SERIE_STR.get_fa2_editions_serie_contract(false) in
    let contract = Test.to_contract contract_add in

    let () = Test.set_source admin in

    let _gas = Test.transfer_to_contract_exn contract ((Revoke_minting ({ revoke = true } : FA2_SERIE_STR.revoke_minting_param)) : FA2_SERIE_STR.editions_entrypoints) 0tez in

    let result = Test.transfer_to_contract contract ((Revoke_minting ({ revoke = false } : FA2_SERIE_STR.revoke_minting_param)) : FA2_SERIE_STR.editions_entrypoints) 0tez in

    match result with
        Success _gas -> failwith "Admin (Serie originated fa2 contract) -> Revoke_minting - undo revoke : This test should fail"
    |   Fail (Rejected (err, _)) -> (
            let () = assert_with_error ( Test.michelson_equal err (Test.eval "MINTING_IS_REVOKED") ) "Admin (Serie originated fa2 contract) -> Revoke_minting - undo revoke : Should not work if minting has been revoked" in
            "Passed"
        )
    |   Fail _ -> failwith "Internal test failure"    


// Success
let test_serie_factory_originated_revoke_minting =
    let contract_add, admin, _, _ = FA2_SERIE_STR.get_fa2_editions_serie_contract(false) in
    let contract = Test.to_contract contract_add in

    let () = Test.set_source admin in

    let _gas = Test.transfer_to_contract_exn contract ((Revoke_minting ({ revoke = true } : FA2_SERIE_STR.revoke_minting_param)) : FA2_SERIE_STR.editions_entrypoints) 0tez in

    let new_str = Test.get_storage contract_add in
    let () = assert_with_error (new_str.admin.minting_revoked = true) "Admin (Serie originated fa2 contract) -> Revoke_minting - Success : This test should pass :  Wrong Revoke_minting" in
    "Passed"

// -- FA2 editions version originated from Space factory contract

// Send minter invitation 

// fail no amount
let test_space_factory_originated_send_minter_invitation_no_amount =
    let contract_add, _, _, _, space = FA2_SPACE_STR.get_fa2_editions_space_contract() in
    let contract = Test.to_contract contract_add in

    let new_minter = Test.nth_bootstrap_account 9 in
    let () = Test.set_source space in

    let result = Test.transfer_to_contract contract ((Admin (Send_minter_invitation (new_minter) : FA2_SPACE_STR.admin_entrypoints)) : FA2_SPACE_STR.editions_entrypoints) 1tez in

    match result with
        Success _gas -> failwith "Admin (Space factory originated fa2 contract) -> Send_minter_invitation - no amount : This test should fail"
    |   Fail (Rejected (err, _)) -> (
            let () = assert_with_error ( Test.michelson_equal err (Test.eval "AMOUNT_SHOULD_BE_0TEZ") ) "Admin (Space factory originated fa2 contract) -> Send_minter_invitation - no amount : Should not work if amount specified" in
            "Passed"
        )
    |   Fail _ -> failwith "Internal test failure"    


// fail if no admin
let test_space_factory_originated_send_minter_invitation_no_admin =
    let contract_add, _, _, _, _ = FA2_SPACE_STR.get_fa2_editions_space_contract() in
    let contract = Test.to_contract contract_add in

    let new_minter = Test.nth_bootstrap_account 9 in
    let () = Test.set_source new_minter in

    let result = Test.transfer_to_contract contract ((Admin (Send_minter_invitation (new_minter) : FA2_SPACE_STR.admin_entrypoints)) : FA2_SPACE_STR.editions_entrypoints) 0tez in

    match result with
        Success _gas -> failwith "Admin (Space factory originated fa2 contract) -> Send_minter_invitation - not admin : This test should fail"
    |   Fail (Rejected (err, _)) -> (
            let () = assert_with_error ( Test.michelson_equal err (Test.eval "NOT_AN_ADMIN") ) "Admin (Space factory originated fa2 contract) -> Send_minter_invitation - not admin : Should not work if not an admin" in
            "Passed"
        )
    |   Fail _ -> failwith "Internal test failure"    

// fail if already minter
let test_space_factory_originated_send_minter_invitation_already_minter =
    let contract_add, _, _, minter, space = FA2_SPACE_STR.get_fa2_editions_space_contract() in
    let contract = Test.to_contract contract_add in

    let () = Test.set_source space in

    let result = Test.transfer_to_contract contract ((Admin (Send_minter_invitation (minter) : FA2_SPACE_STR.admin_entrypoints)) : FA2_SPACE_STR.editions_entrypoints) 0tez in

    match result with
        Success _gas -> failwith "Admin (Space factory originated fa2 contract) -> Send_minter_invitation - already minter : This test should fail"
    |   Fail (Rejected (err, _)) -> (
            let () = assert_with_error ( Test.michelson_equal err (Test.eval "ALREADY_MINTER") ) "Admin (Space factory originated fa2 contract) -> Send_minter_invitation - already minter : Should not work if already minter" in
            "Passed"
        )
    |   Fail _ -> failwith "Internal test failure"

// fail if already sent minter
let test_space_factory_originated_send_minter_invitation_already_sent =
    let contract_add, _, _, _, space = FA2_SPACE_STR.get_fa2_editions_space_contract() in
    let contract = Test.to_contract contract_add in

    let new_minter = Test.nth_bootstrap_account 9 in
    let () = Test.set_source space in

    let _gaz = Test.transfer_to_contract contract ((Admin (Send_minter_invitation (new_minter) : FA2_SPACE_STR.admin_entrypoints)) : FA2_SPACE_STR.editions_entrypoints) 0tez in

    let result = Test.transfer_to_contract contract ((Admin (Send_minter_invitation (new_minter) : FA2_SPACE_STR.admin_entrypoints)) : FA2_SPACE_STR.editions_entrypoints) 0tez in

    match result with
        Success _gas -> failwith "Admin (Space factory originated fa2 contract) -> Send_minter_invitation - already minter : This test should fail"
    |   Fail (Rejected (err, _)) -> (
            let () = assert_with_error ( Test.michelson_equal err (Test.eval "INVITATION_ALREADY_SENT") ) "Admin (Space factory originated fa2 contract) -> Send_minter_invitation - already minter : Should not work if invitation already sent" in
            "Passed"
        )
    |   Fail _ -> failwith "Internal test failure"


// Success
let test_space_factory_originated_send_minter_invitation_success =
    let contract_add, _, _, _, space = FA2_SPACE_STR.get_fa2_editions_space_contract() in
    let contract = Test.to_contract contract_add in

    let new_minter = Test.nth_bootstrap_account 9 in
    let () = Test.set_source space in

    let result = Test.transfer_to_contract contract ((Admin (Send_minter_invitation (new_minter) : FA2_SPACE_STR.admin_entrypoints)) : FA2_SPACE_STR.editions_entrypoints) 0tez in

    match result with
        Success _gas -> (
            let strg = Test.get_storage contract_add in
            match Big_map.find_opt new_minter strg.admin.pending_minters with
                    None -> failwith "Admin (Space factory originated fa2 contract) -> Send_minter_invitation - Success : This test should pass (minter not saved in big map)"
                |   Some _ -> "Passed"
        )
    |   Fail (Rejected (_err, _)) -> failwith "Admin (Space factory originated fa2 contract) -> Send_minter_invitation - Success : This test should pass"
    |   Fail _ -> failwith "Internal test failure"

// Accept_minter_invitation

// fail no amount
let test_space_factory_originated_accept_minter_invitation_no_amount =
    let contract_add, _, _, _, space = FA2_SPACE_STR.get_fa2_editions_space_contract() in
    let contract = Test.to_contract contract_add in

    let () = Test.set_source space in

    let result = Test.transfer_to_contract contract (Accept_minter_invitation ({ accept = true }) : FA2_SPACE_STR.editions_entrypoints) 1tez in

    match result with
        Success _gas -> failwith "Admin (Space factory originated fa2 contract) -> Accept_minter_invitation - no amount : This test should fail"
    |   Fail (Rejected (err, _)) -> (
            let () = assert_with_error ( Test.michelson_equal err (Test.eval "AMOUNT_SHOULD_BE_0TEZ") ) "Admin (Space factory originated fa2 contract) -> Accept_minter_invitation - no amount : Should not work if amount specified" in
            "Passed"
        )
    |   Fail _ -> failwith "Internal test failure"

// fail not pending minter
let test_space_factory_originated_accept_minter_invitation_not_pending_minter =
    let contract_add, _, _, _, _ = FA2_SPACE_STR.get_fa2_editions_space_contract() in
    let contract = Test.to_contract contract_add in

    let new_minter = Test.nth_bootstrap_account 9 in
    let () = Test.set_source new_minter in

    let result = Test.transfer_to_contract contract (Accept_minter_invitation ({ accept = true }) : FA2_SPACE_STR.editions_entrypoints) 0tez in

    match result with
        Success _gas -> failwith "Admin (Space factory originated fa2 contract) -> Accept_minter_invitation - not pending minter : This test should fail"
    |   Fail (Rejected (err, _)) -> (
            let () = assert_with_error ( Test.michelson_equal err (Test.eval "NOT_PENDING_MINTER") ) "Admin (Space factory originated fa2 contract) -> Accept_minter_invitation - not pending minter : Should not work if not pending minter" in
            "Passed"
        )
    |   Fail _ -> failwith "Internal test failure"

// Success accept
let test_space_factory_originated_accept_minter_invitation_success_accept =
    let contract_add, _, _, _, space = FA2_SPACE_STR.get_fa2_editions_space_contract() in
    let contract = Test.to_contract contract_add in

    let new_minter = Test.nth_bootstrap_account 9 in
    
    let () = Test.set_source space in
    let _gaz = Test.transfer_to_contract contract ((Admin (Send_minter_invitation (new_minter) : FA2_SPACE_STR.admin_entrypoints)) : FA2_SPACE_STR.editions_entrypoints) 0tez in
    
    let () = Test.set_source new_minter in
    let result = Test.transfer_to_contract contract (Accept_minter_invitation ({ accept = true }) : FA2_SPACE_STR.editions_entrypoints) 0tez in

    match result with
        Success _gas -> (
            let strg = Test.get_storage contract_add in
            match Big_map.find_opt new_minter strg.admin.minters with
                    None -> failwith "Admin (Space factory originated fa2 contract) -> Accept_minter_invitation - Success : This test should pass (minter not saved in big map)"
                |   Some _ -> (
                        match Big_map.find_opt new_minter strg.admin.pending_minters with
                                Some _ -> failwith "Admin (Space factory originated fa2 contract) -> Accept_minter_invitation - Success : This test should pass (minter not removed from pending big map)"
                            |   None -> "Passed"
                )
        )
    |   Fail (Rejected (_err, _)) -> failwith "Admin (Space factory originated fa2 contract) -> Send_minter_invitation - Success : This test should pass"
    |   Fail _ -> failwith "Internal test failure"

// Success refuse
let test_space_factory_originated_accept_minter_invitation_success_refuse =
    let contract_add, _, _, _, space = FA2_SPACE_STR.get_fa2_editions_space_contract() in
    let contract = Test.to_contract contract_add in

    let new_minter = Test.nth_bootstrap_account 9 in
    
    let () = Test.set_source space in
    let _gaz = Test.transfer_to_contract contract ((Admin (Send_minter_invitation (new_minter) : FA2_SPACE_STR.admin_entrypoints)) : FA2_SPACE_STR.editions_entrypoints) 0tez in
    
    let () = Test.set_source new_minter in
    let result = Test.transfer_to_contract contract (Accept_minter_invitation ({ accept = false }) : FA2_SPACE_STR.editions_entrypoints) 0tez in

    match result with
        Success _gas -> (
            let strg = Test.get_storage contract_add in
            let () = match Big_map.find_opt new_minter strg.admin.minters with
                   Some _ -> failwith "Admin (Space factory originated fa2 contract) -> Accept_minter_invitation - Success : This test should pass (minter should not be saved in big map)"
                |    None -> unit
            in
            
            match Big_map.find_opt new_minter strg.admin.pending_minters with
                    Some _ -> failwith "Admin (Space factory originated fa2 contract) -> Accept_minter_invitation - Success : This test should pass (minter not removed from pending big map)"
                |   None -> "Passed"
    
        )
    |   Fail (Rejected (_err, _)) -> failwith "Admin (Space factory originated fa2 contract) -> Send_minter_invitation - Success : This test should pass"
    |   Fail _ -> failwith "Internal test failure"

// -- Remove minter --

// fail no amount
let test_space_factory_originated_remove_minter_no_amount =
    let contract_add, _, _, old_minter, space = FA2_SPACE_STR.get_fa2_editions_space_contract() in
    let contract = Test.to_contract contract_add in

    let () = Test.set_source space in

    let result = Test.transfer_to_contract contract ((Admin (Remove_minter (old_minter) : FA2_SPACE_STR.admin_entrypoints)) : FA2_SPACE_STR.editions_entrypoints) 1tez in

    match result with
        Success _gas -> failwith "Admin (Space factory originated fa2 contract) -> Remove_minter - no amount : This test should fail"
    |   Fail (Rejected (err, _)) -> (
            let () = assert_with_error ( Test.michelson_equal err (Test.eval "AMOUNT_SHOULD_BE_0TEZ") ) "Admin (Space factory originated fa2 contract) -> Remove_minter - no amount : Should not work if amount specified" in
            "Passed"
        )
    |   Fail _ -> failwith "Internal test failure"    

// fail if no admin
let test_space_factory_originated_remove_minter_no_admin =
    let contract_add, _, _, _, _ = FA2_SPACE_STR.get_fa2_editions_space_contract() in
    let contract = Test.to_contract contract_add in

    let new_minter = Test.nth_bootstrap_account 9 in
    let () = Test.set_source new_minter in

    let result = Test.transfer_to_contract contract ((Admin (Remove_minter (new_minter) : FA2_SPACE_STR.admin_entrypoints)) : FA2_SPACE_STR.editions_entrypoints) 0tez in

    match result with
        Success _gas -> failwith "Admin (Space factory originated fa2 contract) -> Remove_minter - not admin : This test should fail"
    |   Fail (Rejected (err, _)) -> (
            let () = assert_with_error ( Test.michelson_equal err (Test.eval "NOT_AN_ADMIN") ) "Admin (Space factory originated fa2 contract) -> Remove_minter - not admin : Should not work if not an admin" in
            "Passed"
        )
    |   Fail _ -> failwith "Internal test failure"    


// Success is minter
let test_space_factory_originated_remove_minter_success_is_minter =
    let contract_add, _, _, old_minter, space = FA2_SPACE_STR.get_fa2_editions_space_contract() in
    let contract = Test.to_contract contract_add in

    let () = Test.set_source space in

    let result = Test.transfer_to_contract contract ((Admin (Remove_minter (old_minter) : FA2_SPACE_STR.admin_entrypoints)) : FA2_SPACE_STR.editions_entrypoints) 0tez in

    match result with
        Success _gas -> (
            let strg = Test.get_storage contract_add in
            match Big_map.find_opt old_minter strg.admin.minters with
                    Some _ -> failwith "Admin (Space factory originated fa2 contract) -> Remove_minter - Success : This test should pass (minter not removed from minters big map)"
                |   None -> "Passed"
        )
    |   Fail (Rejected (_err, _)) -> failwith "Admin (Space factory originated fa2 contract) -> Remove_minter - Success : This test should pass"
    |   Fail _ -> failwith "Internal test failure"

// Success is pending minter
let test_space_factory_originated_remove_minter_success_is_pending_minter =
    let contract_add, _, _, _, space = FA2_SPACE_STR.get_fa2_editions_space_contract() in
    let contract = Test.to_contract contract_add in

    let new_minter = Test.nth_bootstrap_account 9 in
    let () = Test.set_source space in
    let _gaz = Test.transfer_to_contract contract ((Admin (Send_minter_invitation (new_minter) : FA2_SPACE_STR.admin_entrypoints)) : FA2_SPACE_STR.editions_entrypoints) 0tez in
    
    let result = Test.transfer_to_contract contract ((Admin (Remove_minter (new_minter) : FA2_SPACE_STR.admin_entrypoints)) : FA2_SPACE_STR.editions_entrypoints) 0tez in

    match result with
        Success _gas -> (
            let strg = Test.get_storage contract_add in
            match Big_map.find_opt new_minter strg.admin.minters with
                    Some _ -> failwith "Admin (Space factory originated fa2 contract) -> Remove_minter - Success : This test should pass (minter not removed from pending big map)"
                |   None -> "Passed"
        )
    |   Fail (Rejected (_err, _)) -> failwith "Admin (Space factory originated fa2 contract) -> Remove_minter - Success : This test should pass"
    |   Fail _ -> failwith "Internal test failure"

// -- Remove_minter_self --

// no amount
let test_space_factory_originated_remove_minter_self_no_amount =
    let contract_add, _, _, minter, _ = FA2_SPACE_STR.get_fa2_editions_space_contract() in
    let contract = Test.to_contract contract_add in

    let () = Test.set_source minter in
    let result = Test.transfer_to_contract contract (Remove_minter_self () : FA2_SPACE_STR.editions_entrypoints) 1tez in

    match result with
        Success _gas -> failwith "Admin (Space factory originated fa2 contract) -> Remove_minter_self - no amount : This test should fail"
    |   Fail (Rejected (err, _)) -> (
            let () = assert_with_error ( Test.michelson_equal err (Test.eval "AMOUNT_SHOULD_BE_0TEZ") ) "Admin (Space factory originated fa2 contract) -> Remove_minter_self - no amount : Should not work if amount specified" in
            "Passed"
        )
    |   Fail _ -> failwith "Internal test failure"

// not a minter 
let test_space_factory_originated_remove_minter_self_not_minter =
    let contract_add, _, _, _, space = FA2_SPACE_STR.get_fa2_editions_space_contract() in
    let contract = Test.to_contract contract_add in

    let () = Test.set_source space in
    let result = Test.transfer_to_contract contract (Remove_minter_self () : FA2_SPACE_STR.editions_entrypoints) 0tez in

    match result with
        Success _gas -> failwith "Admin (Space factory originated fa2 contract) -> Remove_minter_self - not minter : This test should fail"
    |   Fail (Rejected (err, _)) -> (
            let () = assert_with_error ( Test.michelson_equal err (Test.eval "NOT_A_MINTER") ) "Admin (Space factory originated fa2 contract) -> Remove_minter_self - not minter : Should not work if not a minter" in
            "Passed"
        )
    |   Fail _ -> failwith "Internal test failure"

// success
let test_space_factory_originated_remove_minter_self_success =
    let contract_add, _, _, minter, _ = FA2_SPACE_STR.get_fa2_editions_space_contract() in
    let contract = Test.to_contract contract_add in

    let () = Test.set_source minter in
    let result = Test.transfer_to_contract contract (Remove_minter_self () : FA2_SPACE_STR.editions_entrypoints) 0tez in

    match result with
        Success _gas -> (
            let strg = Test.get_storage contract_add in
            match Big_map.find_opt minter strg.admin.minters with
                    Some _ -> failwith "Admin (Space factory originated fa2 contract) -> Remove_minter_self - Success : This test should pass (minter should  be removed from big map)"
                |   None -> "Passed"
               
        )
    |   Fail (Rejected (_err, _)) -> failwith "Admin (Space factory originated fa2 contract) -> Remove_minter_self - Success : This test should pass"
    |   Fail _ -> failwith "Internal test failure"
    
// -- Send_admin_invitation --

// fail no amount
let test_space_factory_originated_send_admin_invitation_no_amount =
    let contract_add, _, _, _, space = FA2_SPACE_STR.get_fa2_editions_space_contract() in
    let contract = Test.to_contract contract_add in

    let new_admin = Test.nth_bootstrap_account 9 in
    let () = Test.set_source space in

    let result = Test.transfer_to_contract contract ((Admin (Send_admin_invitation (new_admin) : FA2_SPACE_STR.admin_entrypoints)) : FA2_SPACE_STR.editions_entrypoints) 1tez in

    match result with
        Success _gas -> failwith "Admin (Space factory originated fa2 contract) -> Send_admin_invitation - no amount : This test should fail"
    |   Fail (Rejected (err, _)) -> (
            let () = assert_with_error ( Test.michelson_equal err (Test.eval "AMOUNT_SHOULD_BE_0TEZ") ) "Admin (Space factory originated fa2 contract) -> Send_admin_invitation - no amount : Should not work if amount specified" in
            "Passed"
        )
    |   Fail _ -> failwith "Internal test failure"    


// fail if no admin
let test_space_factory_originated_send_admin_invitation_no_admin =
    let contract_add, _, _, _, _ = FA2_SPACE_STR.get_fa2_editions_space_contract() in
    let contract = Test.to_contract contract_add in

    let new_admin = Test.nth_bootstrap_account 9 in
    let () = Test.set_source new_admin in

    let result = Test.transfer_to_contract contract ((Admin (Send_admin_invitation (new_admin) : FA2_SPACE_STR.admin_entrypoints)) : FA2_SPACE_STR.editions_entrypoints) 0tez in

    match result with
        Success _gas -> failwith "Admin (Space factory originated fa2 contract) -> Send_admin_invitation - not admin : This test should fail"
    |   Fail (Rejected (err, _)) -> (
            let () = assert_with_error ( Test.michelson_equal err (Test.eval "NOT_AN_ADMIN") ) "Admin (Space factory originated fa2 contract) -> Send_admin_invitation - not admin : Should not work if not an admin" in
            "Passed"
        )
    |   Fail _ -> failwith "Internal test failure"    

// fail if already admin
let test_space_factory_originated_send_admin_invitation_already_admin =
    let contract_add, admin, _, _, space = FA2_SPACE_STR.get_fa2_editions_space_contract() in
    let contract = Test.to_contract contract_add in

    let () = Test.set_source space in

    let result = Test.transfer_to_contract contract ((Admin (Send_admin_invitation (admin) : FA2_SPACE_STR.admin_entrypoints)) : FA2_SPACE_STR.editions_entrypoints) 0tez in

    match result with
        Success _gas -> failwith "Admin (Space factory originated fa2 contract) -> Send_admin_invitation - already admin : This test should fail"
    |   Fail (Rejected (err, _)) -> (
            let () = assert_with_error ( Test.michelson_equal err (Test.eval "ALREADY_ADMIN") ) "Admin (Space factory originated fa2 contract) -> Send_admin_invitation - already admin : Should not work if already admin" in
            "Passed"
        )
    |   Fail _ -> failwith "Internal test failure"

// fail if already sent admin
let test_space_factory_originated_send_admin_invitation_already_sent =
    let contract_add, _, _, _, space = FA2_SPACE_STR.get_fa2_editions_space_contract() in
    let contract = Test.to_contract contract_add in

    let new_admin = Test.nth_bootstrap_account 9 in
    let () = Test.set_source space in

    let _gaz = Test.transfer_to_contract contract ((Admin (Send_admin_invitation (new_admin) : FA2_SPACE_STR.admin_entrypoints)) : FA2_SPACE_STR.editions_entrypoints) 0tez in

    let result = Test.transfer_to_contract contract ((Admin (Send_admin_invitation (new_admin) : FA2_SPACE_STR.admin_entrypoints)) : FA2_SPACE_STR.editions_entrypoints) 0tez in

    match result with
        Success _gas -> failwith "Admin (Space factory originated fa2 contract) -> Send_admin_invitation - already sent : This test should fail"
    |   Fail (Rejected (err, _)) -> (
            let () = assert_with_error ( Test.michelson_equal err (Test.eval "INVITATION_ALREADY_SENT") ) "Admin (Space factory originated fa2 contract) -> Send_admin_invitation - already sent : Should not work if invitation already sent" in
            "Passed"
        )
    |   Fail _ -> failwith "Internal test failure"


// Success
let test_space_factory_originated_send_admin_invitation_success =
    let contract_add, _, _, _, space = FA2_SPACE_STR.get_fa2_editions_space_contract() in
    let contract = Test.to_contract contract_add in

    let new_admin = Test.nth_bootstrap_account 9 in
    let () = Test.set_source space in

    let result = Test.transfer_to_contract contract ((Admin (Send_admin_invitation (new_admin) : FA2_SPACE_STR.admin_entrypoints)) : FA2_SPACE_STR.editions_entrypoints) 0tez in

    match result with
        Success _gas -> (
            let strg = Test.get_storage contract_add in
            match Big_map.find_opt new_admin strg.admin.pending_admins with
                    None -> failwith "Admin (Space factory originated fa2 contract) -> Send_admin_invitation - Success : This test should pass (admin not saved in big map)"
                |   Some _ -> "Passed"
        )
    |   Fail (Rejected (_err, _)) -> failwith "Admin (Space factory originated fa2 contract) -> Send_admin_invitation - Success : This test should pass"
    |   Fail _ -> failwith "Internal test failure"


// -- Remove_admin_invitation --

// no amount
let test_space_factory_originated_remove_admin_invitation =
    let contract_add, _, _, _, space = FA2_SPACE_STR.get_fa2_editions_space_contract() in
    let contract = Test.to_contract contract_add in

    let new_admin = Test.nth_bootstrap_account 9 in
    let () = Test.set_source space in

    let result = Test.transfer_to_contract contract ((Admin (Remove_admin_invitation (new_admin) : FA2_SPACE_STR.admin_entrypoints)) : FA2_SPACE_STR.editions_entrypoints) 1tez in

    match result with
        Success _gas -> failwith "Admin (Space factory originated fa2 contract) -> Remove_admin_invitation - no amount : This test should fail"
    |   Fail (Rejected (err, _)) -> (
            let () = assert_with_error ( Test.michelson_equal err (Test.eval "AMOUNT_SHOULD_BE_0TEZ") ) "Admin (Space factory originated fa2 contract) -> Remove_admin_invitation - no amount : Should not work if amount specified" in
            "Passed"
        )
    |   Fail _ -> failwith "Internal test failure"    

// not admin
let test_space_factory_originated_remove_admin_invitation_no_admin =
    let contract_add, _, _, _, _ = FA2_SPACE_STR.get_fa2_editions_space_contract() in
    let contract = Test.to_contract contract_add in

    let new_admin = Test.nth_bootstrap_account 9 in
    let () = Test.set_source new_admin in

    let result = Test.transfer_to_contract contract ((Admin (Remove_admin_invitation (new_admin) : FA2_SPACE_STR.admin_entrypoints)) : FA2_SPACE_STR.editions_entrypoints) 0tez in

    match result with
        Success _gas -> failwith "Admin (Space factory originated fa2 contract) -> Remove_admin_invitation - not admin : This test should fail"
    |   Fail (Rejected (err, _)) -> (
            let () = assert_with_error ( Test.michelson_equal err (Test.eval "NOT_AN_ADMIN") ) "Admin (Space factory originated fa2 contract) -> Remove_admin_invitation - not admin : Should not work if not an admin" in
            "Passed"
        )
    |   Fail _ -> failwith "Internal test failure"    

// success
let test_space_factory_originated_remove_admin_invitation =
    let contract_add, admin, _, _, _ = FA2_SPACE_STR.get_fa2_editions_space_contract() in
    let contract = Test.to_contract contract_add in

    let new_admin = Test.nth_bootstrap_account 9 in
    let () = Test.set_source admin in

    let _gas = Test.transfer_to_contract_exn contract ((Admin (Send_admin_invitation (new_admin) : FA2_SPACE_STR.admin_entrypoints)) : FA2_SPACE_STR.editions_entrypoints) 0tez in
    let result = Test.transfer_to_contract contract ((Admin (Remove_admin_invitation (new_admin) : FA2_SPACE_STR.admin_entrypoints)) : FA2_SPACE_STR.editions_entrypoints) 0tez in

    match result with
        Success _gas -> (
            let strg = Test.get_storage contract_add in
            match Big_map.find_opt new_admin strg.admin.pending_admins with
                    None ->  "Passed"
                |   Some _ ->failwith "Admin (Space factory originated fa2 contract) -> Remove_admin_invitation - Success : This test should pass (admin should be removed from big map)"
        )
    |   Fail (Rejected (_err, _)) -> failwith "Admin (Space factory originated fa2 contract) -> Remove_admin_invitation - Success : This test should pass"
    |   Fail _ -> failwith "Internal test failure"

// -- Remove_admin -- 

// no amount
let test_space_factory_originated_remove_admin_no_amount =
    let contract_add, _, _, _, space = FA2_SPACE_STR.get_fa2_editions_space_contract() in
    let contract = Test.to_contract contract_add in

    let new_admin = Test.nth_bootstrap_account 9 in
    let () = Test.set_source space in

    let result = Test.transfer_to_contract contract ((Admin (Remove_admin (new_admin) : FA2_SPACE_STR.admin_entrypoints)) : FA2_SPACE_STR.editions_entrypoints) 1tez in

    match result with
        Success _gas -> failwith "Admin (Space factory originated fa2 contract) -> Remove_admin - no amount : This test should fail"
    |   Fail (Rejected (err, _)) -> (
            let () = assert_with_error ( Test.michelson_equal err (Test.eval "AMOUNT_SHOULD_BE_0TEZ") ) "Admin (Space factory originated fa2 contract) -> Remove_admin - no amount : Should not work if amount specified" in
            "Passed"
        )
    |   Fail _ -> failwith "Internal test failure"    

// not admin
let test_space_factory_originated_remove_admin_no_admin =
    let contract_add, _, _, _, _ = FA2_SPACE_STR.get_fa2_editions_space_contract() in
    let contract = Test.to_contract contract_add in

    let new_admin = Test.nth_bootstrap_account 9 in
    let () = Test.set_source new_admin in

    let result = Test.transfer_to_contract contract ((Admin (Remove_admin (new_admin) : FA2_SPACE_STR.admin_entrypoints)) : FA2_SPACE_STR.editions_entrypoints) 0tez in

    match result with
        Success _gas -> failwith "Admin (Space factory originated fa2 contract) -> Remove_admin - not admin : This test should fail"
    |   Fail (Rejected (err, _)) -> (
            let () = assert_with_error ( Test.michelson_equal err (Test.eval "NOT_AN_ADMIN") ) "Admin (Space factory originated fa2 contract) -> Remove_admin - not admin : Should not work if not an admin" in
            "Passed"
        )
    |   Fail _ -> failwith "Internal test failure"    

// unable to remove self
let test_space_factory_originated_remove_admin_self =
    let contract_add, admin, _, _, _ = FA2_SPACE_STR.get_fa2_editions_space_contract() in
    let contract = Test.to_contract contract_add in

    let () = Test.set_source admin in

    let result = Test.transfer_to_contract contract ((Admin (Remove_admin (admin) : FA2_SPACE_STR.admin_entrypoints)) : FA2_SPACE_STR.editions_entrypoints) 0tez in

    match result with
        Success _gas -> failwith "Admin (Space factory originated fa2 contract) -> Remove_admin - unable to remove self : This test should fail"
    |   Fail (Rejected (err, _)) -> (
            let () = assert_with_error ( Test.michelson_equal err (Test.eval "UNABLE_TO_REMOVE_YOURSELF") ) "Admin (Space factory originated fa2 contract) -> Remove_admin - unable to remove self : Should not work if trying to remove self" in
            "Passed"
        )
    |   Fail _ -> failwith "Internal test failure"    

// success
let test_space_factory_originated_remove_admin =
    let contract_add, admin, _, _, _ = FA2_SPACE_STR.get_fa2_editions_space_contract() in
    let contract = Test.to_contract contract_add in

    let new_admin = Test.nth_bootstrap_account 9 in
    
    let () = Test.set_source admin in
    let _gas = Test.transfer_to_contract_exn contract ((Admin (Send_admin_invitation (new_admin) : FA2_SPACE_STR.admin_entrypoints)) : FA2_SPACE_STR.editions_entrypoints) 0tez in
    
    let () = Test.set_source new_admin in
    let _gas = Test.transfer_to_contract_exn contract ((Accept_admin_invitation ({ accept = true }) : FA2_SPACE_STR.editions_entrypoints) : FA2_SPACE_STR.editions_entrypoints) 0tez in
    
    let () = Test.set_source admin in
    let result = Test.transfer_to_contract contract ((Admin (Remove_admin (new_admin) : FA2_SPACE_STR.admin_entrypoints)) : FA2_SPACE_STR.editions_entrypoints) 0tez in

    match result with
        Success _gas -> (
            let strg = Test.get_storage contract_add in
            match Big_map.find_opt new_admin strg.admin.admins with
                    None ->  "Passed"
                |   Some _ ->failwith "Admin (Space factory originated fa2 contract) -> Remove_admin - Success : This test should pass (admin not supposed to be in big map)"
        )
    |   Fail (Rejected (_err, _)) -> failwith "Admin (Space factory originated fa2 contract) -> Remove_admin - Success : This test should pass"
    |   Fail _ -> failwith "Internal test failure"

// -- Accept_admin_invitation -- 

// no amount
let test_space_factory_originated_accept_admin_invitation_no_amount =
    let contract_add, _, _, _, _ = FA2_SPACE_STR.get_fa2_editions_space_contract() in
    let contract = Test.to_contract contract_add in

    let new_admin = Test.nth_bootstrap_account 9 in
    let () = Test.set_source new_admin in

    let result = Test.transfer_to_contract contract (Accept_admin_invitation ({ accept = true }) : FA2_SPACE_STR.editions_entrypoints) 1tez in

    match result with
        Success _gas -> failwith "Admin (Space factory originated fa2 contract) -> Accept_admin_invitation - no amount : This test should fail"
    |   Fail (Rejected (err, _)) -> (
            let () = assert_with_error ( Test.michelson_equal err (Test.eval "AMOUNT_SHOULD_BE_0TEZ") ) "Admin (Space factory originated fa2 contract) -> Accept_admin_invitation - no amount : Should not work if amount specified" in
            "Passed"
        )
    |   Fail _ -> failwith "Internal test failure"  

// not pending admin
let test_space_factory_originated_accept_admin_invitation_no_pending_admin =
    let contract_add, _, _, _, _ = FA2_SPACE_STR.get_fa2_editions_space_contract() in
    let contract = Test.to_contract contract_add in

    let new_admin = Test.nth_bootstrap_account 9 in
    let () = Test.set_source new_admin in

    let result = Test.transfer_to_contract contract (Accept_admin_invitation ({ accept = true }) : FA2_SPACE_STR.editions_entrypoints) 0tez in

    match result with
        Success _gas -> failwith "Admin (Space factory originated fa2 contract) -> Accept_admin_invitation - no amount : This test should fail"
    |   Fail (Rejected (err, _)) -> (
            let () = assert_with_error ( Test.michelson_equal err (Test.eval "NOT_PENDING_ADMIN") ) "Admin (Space factory originated fa2 contract) -> Accept_admin_invitation - no amount : Should not work if amount specified" in
            "Passed"
        )
    |   Fail _ -> failwith "Internal test failure"

// Success - accept
let test_space_factory_originated_accept_admin_invitation_success_accept =
    let contract_add, admin, _, _, _ = FA2_SPACE_STR.get_fa2_editions_space_contract() in
    let contract = Test.to_contract contract_add in

    let new_admin = Test.nth_bootstrap_account 9 in
    let () = Test.set_source admin in
    let _gas = Test.transfer_to_contract_exn contract ((Admin (Send_admin_invitation (new_admin) : FA2_SPACE_STR.admin_entrypoints)) : FA2_SPACE_STR.editions_entrypoints) 0tez in

    let new_admin = Test.nth_bootstrap_account 9 in
    let () = Test.set_source new_admin in

    let result = Test.transfer_to_contract contract (Accept_admin_invitation ({ accept = true }) : FA2_SPACE_STR.editions_entrypoints) 0tez in

    match result with
        Success _gas -> (
            let strg = Test.get_storage contract_add in
            let () = match Big_map.find_opt new_admin strg.admin.admins with
                    None -> failwith "Admin (Space factory originated fa2 contract) -> Accept_admin_invitation - Success : This test should pass (admin should be added to admins big map)"
                |   Some _ -> unit
            in
            match Big_map.find_opt new_admin strg.admin.pending_admins with
                    None -> "Passed"
                |   Some _ -> failwith "Admin (Space factory originated fa2 contract) -> Accept_admin_invitation - Success : This test should pass (admin should be remove from pending admins)"
        )
    |   Fail (Rejected (_err, _)) -> failwith "Admin (Space factory originated fa2 contract) -> Accept_admin_invitation - Success : This test should pass"
    |   Fail _ -> failwith "Internal test failure"

// Success - refuse
let test_space_factory_originated_accept_admin_invitation_success_refuse =
    let contract_add, admin, _, _, _ = FA2_SPACE_STR.get_fa2_editions_space_contract() in
    let contract = Test.to_contract contract_add in

    let new_admin = Test.nth_bootstrap_account 9 in
    
    let () = Test.set_source admin in
    let _gas = Test.transfer_to_contract_exn contract ((Admin (Send_admin_invitation (new_admin) : FA2_SPACE_STR.admin_entrypoints)) : FA2_SPACE_STR.editions_entrypoints) 0tez in

    let () = Test.set_source new_admin in

    let result = Test.transfer_to_contract contract (Accept_admin_invitation ({ accept = false }) : FA2_SPACE_STR.editions_entrypoints) 0tez in

    match result with
        Success _gas -> (
            let strg = Test.get_storage contract_add in
            let () = match Big_map.find_opt new_admin strg.admin.admins with
                    None -> unit
                |   Some _ -> failwith "Admin (Space factory originated fa2 contract) -> Accept_admin_invitation - Success : This test should pass (admin should be removed to admins big map)"
            in
            match Big_map.find_opt new_admin strg.admin.pending_admins with
                    None -> "Passed"
                |   Some _ -> failwith "Admin (Space factory originated fa2 contract) -> Accept_admin_invitation - Success : This test should pass (admin should be remove from pending admins)"
        )
    |   Fail (Rejected (_err, _)) -> failwith "Admin (Space factory originated fa2 contract) -> Accept_admin_invitation - Success : This test should pass"
    |   Fail _ -> failwith "Internal test failure"

// -- Accept proposal --

// no amount
let test_accept_proposal_no_amount =
    let contract_add, admin, _, _ = FA2_STR.get_fa2_editions_contract(false) in
    let contract = Test.to_contract contract_add in

    let () = Test.set_source admin in
    let result = Test.transfer_to_contract contract ((Admin (Accept_proposals ([{proposal_id = 1n}]) : FA2_STR.FA2_E.admin_entrypoints)): editions_entrypoints) 1tez in

    match result with
        Success _gas -> failwith "Admin -> Accept_proposals - no amount : This test should fail"
    |   Fail (Rejected (err, _)) -> (
            let () = assert_with_error ( Test.michelson_equal err (Test.eval "AMOUNT_SHOULD_BE_0TEZ") ) "Admin -> Accept_proposals - no amount : Should not work if amount specified" in
            "Passed"
        )
    |   Fail _ -> failwith "Internal test failure"


// not admin
let test_accept_proposal_not_admin =
    let contract_add, _, _, minter = FA2_STR.get_fa2_editions_contract(false) in
    let contract = Test.to_contract contract_add in

    let () = Test.set_source minter in
    let result = Test.transfer_to_contract contract ((Admin (Accept_proposals ([{proposal_id = 1n}]) : FA2_STR.FA2_E.admin_entrypoints)): editions_entrypoints) 0tez in

    match result with
        Success _gas -> failwith "Admin -> Accept_proposals - not admin : This test should fail"
    |   Fail (Rejected (err, _)) -> (
            let () = assert_with_error ( Test.michelson_equal err (Test.eval "NOT_AN_ADMIN") ) "Admin -> Accept_proposals - not admin : Should not work if not admin" in
            "Passed"
        )
    |   Fail _ -> failwith "Internal test failure"


// proposal undefined
let test_accept_proposal_proposal_undefined =
    let contract_add, admin, _, _ = FA2_STR.get_fa2_editions_contract(false) in
    let contract = Test.to_contract contract_add in

    let () = Test.set_source admin in
    let result = Test.transfer_to_contract contract ((Admin (Accept_proposals ([{proposal_id = 1n}]) : FA2_STR.FA2_E.admin_entrypoints)): editions_entrypoints) 0tez in

    match result with
        Success _gas -> failwith "Admin -> Accept_proposals - proposal undefined : This test should fail"
    |   Fail (Rejected (err, _)) -> (
            let () = assert_with_error ( Test.michelson_equal err (Test.eval "FA2_PROPOSAL_UNDEFINED") ) "Admin -> Accept_proposals - proposal undefined : Should not work if proposal undefined" in
            "Passed"
        )
    |   Fail _ -> failwith "Internal test failure"

// success
let test_accept_proposal_success =
    let contract_add, admin, _, minter = FA2_STR.get_fa2_editions_contract(false) in
    let contract = Test.to_contract contract_add in

    let () = Test.set_source minter in

    let mint_editions_param = ({
        edition_info = ("" : bytes);
        royalty = 100n;
        license = {
            upgradeable = False;
            hash = ("" : bytes);
        };
        splits = ([{
            address = minter;
            pct = 500n;
        }; {
            address = admin;
            pct = 500n;
        }] : split list );
    } : mint_edition_param ) in

    let _gas = Test.transfer_to_contract_exn contract ((Create_proposal mint_editions_param) : editions_entrypoints) 0tez in

    let mint_editions_param_2 = ({
        edition_info = ("ff7a7aff" : bytes);
        royalty = 100n;
        license = {
            upgradeable = False;
            hash = ("" : bytes);
        };
        splits = ([{
            address = minter;
            pct = 500n;
        }; {
            address = admin;
            pct = 500n;
        }] : split list );
    } : mint_edition_param ) in

    let _gas = Test.transfer_to_contract_exn contract ((Create_proposal mint_editions_param_2) : editions_entrypoints) 0tez in


    let () = Test.set_source admin in
    let result = Test.transfer_to_contract contract ((Admin (Accept_proposals ([{proposal_id = 1n}; {proposal_id = 2n}]) : FA2_STR.FA2_E.admin_entrypoints)): editions_entrypoints) 0tez in

    match result with
        Success _gas -> (
            let new_str = Test.get_storage contract_add in
            match Big_map.find_opt 1n new_str.proposals with 
                    Some proposal -> (
                        let () = assert_with_error (proposal.accepted = True) "Accept_proposals - Success : Proposal accepted should be equal to true" in
                        "Passed"
                    ) 
                |   None -> failwith "Accept_proposals - Success : Token should exist"
            
        )
    |   Fail (Rejected (_err, _)) -> (
            failwith "Accept_proposals - Success : This test should pass"
        )
    |   Fail _ -> failwith "Internal test failure"

// -- Reject proposal -- 

// no amount
let test_reject_proposal_no_amount =
    let contract_add, admin, _, _ = FA2_STR.get_fa2_editions_contract(false) in
    let contract = Test.to_contract contract_add in

    let () = Test.set_source admin in
    let result = Test.transfer_to_contract contract ((Admin (Reject_proposals ([{proposal_id = 1n}]) : FA2_STR.FA2_E.admin_entrypoints)): editions_entrypoints) 1tez in

    match result with
        Success _gas -> failwith "Admin -> Reject_proposals - no amount : This test should fail"
    |   Fail (Rejected (err, _)) -> (
            let () = assert_with_error ( Test.michelson_equal err (Test.eval "AMOUNT_SHOULD_BE_0TEZ") ) "Admin -> Reject_proposals - no amount : Should not work if amount specified" in
            "Passed"
        )
    |   Fail _ -> failwith "Internal test failure"

// not admin
let test_reject_proposal_not_admin =
    let contract_add, _, _, minter = FA2_STR.get_fa2_editions_contract(false) in
    let contract = Test.to_contract contract_add in

    let () = Test.set_source minter in
    let result = Test.transfer_to_contract contract ((Admin (Reject_proposals ([{proposal_id = 1n}]) : FA2_STR.FA2_E.admin_entrypoints)): editions_entrypoints) 0tez in

    match result with
        Success _gas -> failwith "Admin -> Reject_proposals - not admin : This test should fail"
    |   Fail (Rejected (err, _)) -> (
            let () = assert_with_error ( Test.michelson_equal err (Test.eval "NOT_AN_ADMIN") ) "Admin -> Reject_proposals - not admin : Should not work if not admin" in
            "Passed"
        )
    |   Fail _ -> failwith "Internal test failure"

// success
let test_reject_proposal_success =
    let contract_add, admin, _, minter = FA2_STR.get_fa2_editions_contract(false) in
    let contract = Test.to_contract contract_add in

    let () = Test.set_source minter in

    let mint_editions_param = ({
        edition_info = ("" : bytes);
        royalty = 100n;
        license = {
            upgradeable = False;
            hash = ("" : bytes);
        };
        splits = ([{
            address = minter;
            pct = 500n;
        }; {
            address = admin;
            pct = 500n;
        }] : split list );
    } : mint_edition_param ) in

    let _gas = Test.transfer_to_contract_exn contract ((Create_proposal mint_editions_param) : editions_entrypoints) 0tez in

    let () = Test.set_source admin in
    let result = Test.transfer_to_contract contract ((Admin (Reject_proposals ([{proposal_id = 1n}]) : FA2_STR.FA2_E.admin_entrypoints)): editions_entrypoints) 0tez in

    match result with
        Success _gas -> (
            let new_str = Test.get_storage contract_add in
            match Big_map.find_opt 1n new_str.proposals with 
                    Some _ -> failwith "Reject_proposals - Success : Proposal should be deleted"
                |   None -> "Passed"
            
        )
    |   Fail (Rejected (_err, _)) -> (
            failwith "Reject_proposals - Success : This test should pass"
        )
    |   Fail _ -> failwith "Internal test failure"