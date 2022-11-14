#import "storage.test.mligo" "FA2_STR"
#include "../../d-art.art-factories/gallery_factory.mligo"

// TEST FILE FOR MAIN ENTRYPOINTS

// -- Update permission manager --

// Fail if amount
let test_update_permission_manager_no_amount =
    let contract_add, _ = FA2_STR.get_gallery_factory_contract() in
    let contract = Test.to_contract contract_add in

    // Obviously it should be a KT.. address using tz.. one for conveniance
    let new_manager = Test.nth_bootstrap_account 3 in
    
    let result = Test.transfer_to_contract contract ((Update_permission_manager (new_manager)) : art_factory) 1tez in

    match result with
        Success _gas -> failwith "Update_permission_manager - No amount : This test should fail"
    |   Fail (Rejected (err, _)) -> (
            let () = assert_with_error ( Test.michelson_equal err (Test.eval "AMOUNT_SHOULD_BE_0TEZ") ) "Update_permission_manager - No amount : Should not work if amount specified" in
            "Passed"
        )
    |   Fail _ -> failwith "Internal test failure"


// Fail if sender not admin
let test_update_permission_manager_not_admin =
    let contract_add, _ = FA2_STR.get_gallery_factory_contract() in
    let contract = Test.to_contract contract_add in

    // Obviously it should be a KT.. address using tz.. one for conveniance
    let new_manager = Test.nth_bootstrap_account 3 in
    let () = Test.set_source new_manager in

    let result = Test.transfer_to_contract contract ((Update_permission_manager (new_manager)) : art_factory) 0tez in

    match result with
        Success _gas -> failwith "Update_permission_manager - Not admin : This test should fail"
    |   Fail (Rejected (err, _)) -> (
            let () = assert_with_error ( Test.michelson_equal err (Test.eval "NOT_AN_ADMIN") ) "Update_permission_manager - Not admin : Should not work if not admin" in
            "Passed"
        )
    |   Fail _ -> failwith "Internal test failure"


// -- Create gallery --

// Fail if not gallery
let test_create_gallery_not_gallery =
    let contract_add, _ = FA2_STR.get_gallery_factory_contract() in
    let contract = Test.to_contract contract_add in
    
    let not_minter = Test.nth_bootstrap_account 3 in

    let () = Test.set_source not_minter in
    let result = Test.transfer_to_contract contract ((Create_gallery ({ metadata = ("5465737420636f6e7472616374206d65746164617461": bytes) })) : art_factory) 0tez in 

    match result with
        Success _gas -> failwith "Create_gallery - Not gallery : This test should fail"
        |   Fail (Rejected (err, _)) -> (
                let () = assert_with_error ( Test.michelson_equal err (Test.eval "NOT_A_GALLERY") ) "Create_gallery - Not gallery : Should not work if not a gallery" in
                "Passed"
            )
        |   Fail _ -> failwith "Internal test failure"    

// Fail if no amount
let test_create_gallery_no_amount =
    let contract_add, minter = FA2_STR.get_gallery_factory_contract() in
    let contract = Test.to_contract contract_add in

    let () = Test.set_source minter in
    let result = Test.transfer_to_contract contract ((Create_gallery ({ metadata = ("5465737420636f6e7472616374206d65746164617461": bytes) })) : art_factory) 1tez in 

    match result with
        Success _gas -> failwith "Create_gallery - No amount : This test should fail"
        |   Fail (Rejected (err, _)) -> (
                let () = assert_with_error ( Test.michelson_equal err (Test.eval "AMOUNT_SHOULD_BE_0TEZ") ) "Create_gallery - No amount : Should not work if amount specified" in
                "Passed"
            )
        |   Fail _ -> failwith "Internal test failure"       

// Success
let test_create_gallery =
    let contract_add, gallery = FA2_STR.get_gallery_factory_contract() in
    let contract = Test.to_contract contract_add in

    let () = Test.set_source gallery in

    let _gas = Test.transfer_to_contract_exn contract ((Create_gallery ({ metadata = ("5465737420636f6e7472616374206d65746164617461": bytes) })) : art_factory) 0tez in 

    let new_strg = Test.get_storage contract_add in

    // Check serie is added to series big_map
    match Big_map.find_opt gallery new_strg.galleries with
        None -> "Create_gallery - Success : This test should pass : Serie should be present in the series big_map"
        | Some _gallery -> (
            "Passed"
            // Check if serie storage is set properly (Not supported yet)
            // let contract_typed_add : (FA2.editions_entrypoints, FA2.editions_storage) typed_address = Test.cast_address serie.address in
            // let originated_contract_strg = Test.get_storage contract_typed_add in
            
            // if originated_contract_strg.admin.admin <> minter
            // then "Create_serie - Success : This test should pass : Admin of the serie should be the sender"
            // else
            // if originated_contract_strg.admin.minting_revoked = true
            // then "Create_serie - Success : This test should pass : Minting should not be revoked at origination"
            // else "Passed"
        )   
    
// Fail if gallery already originated
    
let test_create_gallery_already_created =

    let contract_add, gallery = FA2_STR.get_gallery_factory_contract() in
    let contract = Test.to_contract contract_add in

    let () = Test.set_source gallery in

    let _gas = Test.transfer_to_contract_exn contract ((Create_gallery ({ metadata = ("5465737420636f6e7472616374206d65746164617461": bytes) })) : art_factory) 0tez in 
    
    let result = Test.transfer_to_contract contract ((Create_gallery ({ metadata = ("5465737420636f6e7472616374206d65746164617461": bytes) })) : art_factory) 0tez in 

    match result with
            Success _gas -> failwith "Create_gallery - Already originated : This test should fail"
        |   Fail (Rejected (err, _)) -> (
                let () = assert_with_error ( Test.michelson_equal err (Test.eval "ALREADY_ORIGINATED") ) "Create_gallery - Already originated : Should not work if gallery already " in
                "Passed"
            )
        |   Fail _ -> failwith "Internal test failure"    