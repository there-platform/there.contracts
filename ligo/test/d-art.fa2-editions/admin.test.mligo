#import "storage.test.mligo" "FA2_STR"
#import "storage_serie.test.mligo" "FA2_SERIE_STR"
#import "storage_gallery.test.mligo" "FA2_GALLERY_STR"
#include "../../d-art.fa2-editions/multi_nft_token_editions.mligo"

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
let test_update_minter_manager_not_admin =
    let contract_add, _, owner1, _ = FA2_STR.get_fa2_editions_contract(false) in
    let contract = Test.to_contract contract_add in

    let () = Test.set_source owner1 in

    let result = Test.transfer_to_contract contract ((Admin ((Update_minter_manager ("KT1FxpxCvERyYhhwisypGgfUSU3EkGf8XVen" : address) : FA2_STR.FA2_E.admin_entrypoints))) : editions_entrypoints) 0tez in

    match result with
        Success _gas -> failwith "Admin -> Update_minter_manager - Not admin : This test should fail"
    |   Fail (Rejected (err, _)) -> (
            let () = assert_with_error ( Test.michelson_equal err (Test.eval "NOT_AN_ADMIN") ) "Admin -> Update_minter_manager - Not admin : Should not work if sender not admin" in
            "Passed"
        )
    |   Fail _ -> failwith "Internal test failure"    

// Fail no amount
let test_update_minter_manager_not_admin =
    let contract_add, _, owner1, _ = FA2_STR.get_fa2_editions_contract(false) in
    let contract = Test.to_contract contract_add in

    let () = Test.set_source owner1 in

    let result = Test.transfer_to_contract contract ((Admin ((Update_minter_manager ("KT1FxpxCvERyYhhwisypGgfUSU3EkGf8XVen" : address) : FA2_STR.FA2_E.admin_entrypoints))) : editions_entrypoints) 1tez in

    match result with
        Success _gas -> failwith "Admin -> Pause_minting - No amount : This test should fail"
    |   Fail (Rejected (err, _)) -> (
            let () = assert_with_error ( Test.michelson_equal err (Test.eval "AMOUNT_SHOULD_BE_0TEZ") ) "Admin -> Update_minter_manager - No amount : Should not work if amount specified" in
            "Passed"
        )
    |   Fail _ -> failwith "Internal test failure"    

// Success
let test_update_minter_manager =
    let contract_add, admin, _, _ = FA2_STR.get_fa2_editions_contract(false) in
    let contract = Test.to_contract contract_add in

    let () = Test.set_source admin in

    let _gas = Test.transfer_to_contract_exn contract ((Admin ((Update_minter_manager ("KT1FxpxCvERyYhhwisypGgfUSU3EkGf8XVen" : address) : FA2_STR.FA2_E.admin_entrypoints))) : editions_entrypoints) 0tez in

    let new_str = Test.get_storage contract_add in
    let () = assert_with_error (new_str.admin.minters_manager = ("KT1FxpxCvERyYhhwisypGgfUSU3EkGf8XVen" : address)) "Admin -> Update_minter_manager - Success : This test should pass :  Wrong minters_manager" in
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
let test_serie_factory_originated_revoke_minting_not_admin =
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

// -- FA2 editions version originated from Gallery factory contract

// Add minter 

// fail no amount
let test_gallery_factory_originated_add_minter_no_amount =
    let contract_add, _, _, _, gallery = FA2_GALLERY_STR.get_fa2_editions_gallery_contract() in
    let contract = Test.to_contract contract_add in

    let new_minter = Test.nth_bootstrap_account 9 in
    let () = Test.set_source gallery in

    let result = Test.transfer_to_contract contract ((Admin (Add_minter (new_minter) : FA2_GALLERY_STR.admin_entrypoints)) : FA2_GALLERY_STR.editions_entrypoints) 1tez in

    match result with
        Success _gas -> failwith "Admin (Gallery factory originated fa2 contract) -> Add_minter - no amount : This test should fail"
    |   Fail (Rejected (err, _)) -> (
            let () = assert_with_error ( Test.michelson_equal err (Test.eval "AMOUNT_SHOULD_BE_0TEZ") ) "Admin (Gallery factory originated fa2 contract) -> Add_minter - no amount : Should not work if amount specified" in
            "Passed"
        )
    |   Fail _ -> failwith "Internal test failure"    


// fail if no admin
let test_gallery_factory_originated_add_minter_no_admin =
    let contract_add, _, _, _, _ = FA2_GALLERY_STR.get_fa2_editions_gallery_contract() in
    let contract = Test.to_contract contract_add in

    let new_minter = Test.nth_bootstrap_account 9 in
    let () = Test.set_source new_minter in

    let result = Test.transfer_to_contract contract ((Admin (Add_minter (new_minter) : FA2_GALLERY_STR.admin_entrypoints)) : FA2_GALLERY_STR.editions_entrypoints) 0tez in

    match result with
        Success _gas -> failwith "Admin (Gallery factory originated fa2 contract) -> Add_minter - not admin : This test should fail"
    |   Fail (Rejected (err, _)) -> (
            let () = assert_with_error ( Test.michelson_equal err (Test.eval "NOT_AN_ADMIN") ) "Admin (Gallery factory originated fa2 contract) -> Add_minter - not admin : Should not work if not an admin" in
            "Passed"
        )
    |   Fail _ -> failwith "Internal test failure"    

// fail if already minter
let test_gallery_factory_originated_add_minter_already_minter =
    let contract_add, _, _, minter, gallery = FA2_GALLERY_STR.get_fa2_editions_gallery_contract() in
    let contract = Test.to_contract contract_add in

    let () = Test.set_source gallery in

    let result = Test.transfer_to_contract contract ((Admin (Add_minter (minter) : FA2_GALLERY_STR.admin_entrypoints)) : FA2_GALLERY_STR.editions_entrypoints) 0tez in

    match result with
        Success _gas -> failwith "Admin (Gallery factory originated fa2 contract) -> Add_minter - already minter : This test should fail"
    |   Fail (Rejected (err, _)) -> (
            let () = assert_with_error ( Test.michelson_equal err (Test.eval "ALREADY_MINTER") ) "Admin (Gallery factory originated fa2 contract) -> Add_minter - already minter : Should not work if already minter" in
            "Passed"
        )
    |   Fail _ -> failwith "Internal test failure"

// Success
let test_gallery_factory_originated_add_minter_success =
    let contract_add, _, _, _, gallery = FA2_GALLERY_STR.get_fa2_editions_gallery_contract() in
    let contract = Test.to_contract contract_add in

    let new_minter = Test.nth_bootstrap_account 9 in
    let () = Test.set_source gallery in

    let result = Test.transfer_to_contract contract ((Admin (Add_minter (new_minter) : FA2_GALLERY_STR.admin_entrypoints)) : FA2_GALLERY_STR.editions_entrypoints) 0tez in

    match result with
        Success _gas -> (
            let strg = Test.get_storage contract_add in
            match Big_map.find_opt new_minter strg.admin.minters with
                    None -> failwith "Admin (Gallery factory originated fa2 contract) -> Add_minter - Success : This test should pass (minter not saved in big map)"
                |   Some _ -> "Passed"
        )
    |   Fail (Rejected (_err, _)) -> failwith "Admin (Gallery factory originated fa2 contract) -> Add_minter - Success : This test should pass"
    |   Fail _ -> failwith "Internal test failure"


// Remove minter

// fail no amount
let test_gallery_factory_originated_remove_minter_no_amount =
    let contract_add, _, _, old_minter, gallery = FA2_GALLERY_STR.get_fa2_editions_gallery_contract() in
    let contract = Test.to_contract contract_add in

    let () = Test.set_source gallery in

    let result = Test.transfer_to_contract contract ((Admin (Remove_minter (old_minter) : FA2_GALLERY_STR.admin_entrypoints)) : FA2_GALLERY_STR.editions_entrypoints) 1tez in

    match result with
        Success _gas -> failwith "Admin (Gallery factory originated fa2 contract) -> Remove_minter - no amount : This test should fail"
    |   Fail (Rejected (err, _)) -> (
            let () = assert_with_error ( Test.michelson_equal err (Test.eval "AMOUNT_SHOULD_BE_0TEZ") ) "Admin (Gallery factory originated fa2 contract) -> Remove_minter - no amount : Should not work if amount specified" in
            "Passed"
        )
    |   Fail _ -> failwith "Internal test failure"    

// fail if no admin
let test_gallery_factory_originated_remove_minter_no_admin =
    let contract_add, _, _, _, _ = FA2_GALLERY_STR.get_fa2_editions_gallery_contract() in
    let contract = Test.to_contract contract_add in

    let new_minter = Test.nth_bootstrap_account 9 in
    let () = Test.set_source new_minter in

    let result = Test.transfer_to_contract contract ((Admin (Remove_minter (new_minter) : FA2_GALLERY_STR.admin_entrypoints)) : FA2_GALLERY_STR.editions_entrypoints) 0tez in

    match result with
        Success _gas -> failwith "Admin (Gallery factory originated fa2 contract) -> Remove_minter - not admin : This test should fail"
    |   Fail (Rejected (err, _)) -> (
            let () = assert_with_error ( Test.michelson_equal err (Test.eval "NOT_AN_ADMIN") ) "Admin (Gallery factory originated fa2 contract) -> Remove_minter - not admin : Should not work if not an admin" in
            "Passed"
        )
    |   Fail _ -> failwith "Internal test failure"    

// fail if not minter
let test_gallery_factory_originated_remove_minter_not_minter =
    let contract_add, _, _, _, gallery = FA2_GALLERY_STR.get_fa2_editions_gallery_contract() in
    let contract = Test.to_contract contract_add in

    let not_minter = Test.nth_bootstrap_account 9 in
    let () = Test.set_source gallery in

    let result = Test.transfer_to_contract contract ((Admin (Remove_minter (not_minter) : FA2_GALLERY_STR.admin_entrypoints)) : FA2_GALLERY_STR.editions_entrypoints) 0tez in

    match result with
        Success _gas -> failwith "Admin (Gallery factory originated fa2 contract) -> Remove_minter - not minter : This test should fail"
    |   Fail (Rejected (err, _)) -> (
            let () = assert_with_error ( Test.michelson_equal err (Test.eval "MINTER_NOT_FOUND") ) "Admin (Gallery factory originated fa2 contract) -> Remove_minter - not minter : Should not work if not a minter" in
            "Passed"
        )
    |   Fail _ -> failwith "Internal test failure"    

// Success
let test_gallery_factory_originated_remove_minter_success =
    let contract_add, _, _, old_minter, gallery = FA2_GALLERY_STR.get_fa2_editions_gallery_contract() in
    let contract = Test.to_contract contract_add in

    let () = Test.set_source gallery in

    let result = Test.transfer_to_contract contract ((Admin (Remove_minter (old_minter) : FA2_GALLERY_STR.admin_entrypoints)) : FA2_GALLERY_STR.editions_entrypoints) 0tez in

    match result with
        Success _gas -> (
            let strg = Test.get_storage contract_add in
            match Big_map.find_opt old_minter strg.admin.minters with
                    Some _ -> failwith "Admin (Gallery factory originated fa2 contract) -> Remove_minter - Success : This test should pass (minter not saved in big map)"
                |   None -> "Passed"
        )
    |   Fail (Rejected (_err, _)) -> failwith "Admin (Gallery factory originated fa2 contract) -> Remove_minter - Success : This test should pass"
    |   Fail _ -> failwith "Internal test failure"

