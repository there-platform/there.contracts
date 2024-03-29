#include "storage.test.mligo" 

// -- CREATE SALES --

// Success
let test_create_sales =
    let _, t_add, _, _, admin  = get_fixed_price_contract (false) in

    let () = Test.set_source admin in
    let contract = Test.to_contract t_add in

    let result = Test.transfer_to_contract contract
        (Create_sales ({
            sale_infos = [({
                commodity = (Tez (150000mutez));
                buyer = None;
                fa2_token = {
                    address = ("KT1Ti9x7gXoDzZGFgLC23ZRn3SnjMZP2y5gD" : address);
                    id = 0n 
                };
            } : sale_info ); ({
                buyer = Some ("tz1LWtbjgecb1SZ6AjHtyGCXPMiR6QZqtm6i" : address);
                commodity = (Tez (100000mutez));
                fa2_token = {
                    address = ("KT1Ti9x7gXoDzZGFgLC23ZRn3SnjMZP2y5gD" : address);
                    id = 1n
                };
            } : sale_info)]
        } : sale_configuration)) 0tez
    in

    let new_str = Test.get_storage t_add in
    match result with
          Success _gas -> (
                // Check first sale if well saved
                let first_sale_key : fa2_base * address = (
                    {
                        address = ( "KT1Ti9x7gXoDzZGFgLC23ZRn3SnjMZP2y5gD" : address);
                        id = 0n
                    },
                    admin
                 ) in
                let () = match Big_map.find_opt first_sale_key new_str.for_sale with
                        Some fixed_price_saved -> (
                            let () = assert_with_error (fixed_price_saved.commodity = (Tez (150000mutez))) "CreateSale - Success : This test should pass (err: First sale wrong price saved)" in
                            match fixed_price_saved.buyer with 
                                    Some _ -> (failwith "CreateSale - Success : This test should pass (err: First sale no buyer should be saved)" : unit)
                                |   None -> unit
                        )
                    |   None -> (failwith "CreateSale - Success : This test should pass (err: First sale not saved)" : unit)
                in
                // Check second sale if well saved
                let second_sale_key : fa2_base * address = (
                    {
                        address = ( "KT1Ti9x7gXoDzZGFgLC23ZRn3SnjMZP2y5gD" : address);
                        id = 1n
                    },
                    admin
                 ) in
                let () = match Big_map.find_opt second_sale_key new_str.for_sale with
                        Some fixed_price_saved -> (
                            let () = assert_with_error (fixed_price_saved.commodity = (Tez (100000mutez))) "CreateSale - Success : This test should pass (err: Second sale wrong price saved)" in
                            match fixed_price_saved.buyer with 
                                    Some buyer -> assert_with_error (buyer = ("tz1LWtbjgecb1SZ6AjHtyGCXPMiR6QZqtm6i" : address)) "CreateSale - Success : This test should pass (err: Second sale wrong buyer saved)"
                                |   None -> (failwith "CreateSale - Success : This test should pass (err: Second sale buyer should be saved)" : unit)
                        )
                    |   None -> (failwith "CreateSale - Success : This test should pass (err: Second sale not saved)" : unit)
                in
                "Passed"
          )
        |   Fail (Rejected (_err, _)) -> "CreateSale - Success : This test should pass"
        |   Fail _ -> failwith "Internal test failure"    
    

// Should fail if amount specified
let test_create_sales_with_amount =
    let _, t_add, _, _, admin  = get_fixed_price_contract (false) in


    let () = Test.set_source admin in
    let contract = Test.to_contract t_add in

    let result = Test.transfer_to_contract contract
        (Create_sales ({
            sale_infos = [({
                commodity = (Tez (150000mutez));
                buyer = None;
                fa2_token = {
                    address = ("KT1Ti9x7gXoDzZGFgLC23ZRn3SnjMZP2y5gD" : address);
                    id = 0n 
                };
            } : sale_info ); ({
                buyer = Some ("tz1LWtbjgecb1SZ6AjHtyGCXPMiR6QZqtm6i" : address);
                commodity = (Tez (100000mutez));
                fa2_token = {
                    address = ("KT1Ti9x7gXoDzZGFgLC23ZRn3SnjMZP2y5gD" : address);
                    id = 1n
                };
            } : sale_info)]
        } : sale_configuration)) 1tez
    in

    match result with
        Success _gas -> failwith "CreateSale - No amount : This test should fail (err: Amount specified for create_sales entrypoint)"
    |   Fail (Rejected (err, _)) -> (
            let () = assert_with_error ( Test.michelson_equal err (Test.eval "AMOUNT_SHOULD_BE_0TEZ") ) "CreateSale - No amount : Should not work if amount specified" in
            "Passed"
        )
    |   Fail _ -> failwith "Internal test failure"    

// Should fail if contract will be deprecated
let test_create_sales_deprecated = 
    let _, t_add, _, _, admin  = get_fixed_price_contract (false) in


    let () = Test.set_source admin in
    let contract = Test.to_contract t_add in
    
    let _gas = Test.transfer_to_contract_exn contract (Admin  (Contract_will_update (true))) 0tez in    

    let result = Test.transfer_to_contract contract
        (Create_sales ({
            sale_infos = [({
                commodity = (Tez (150000mutez));
                buyer = None;
                fa2_token = {
                    address = ("KT1Ti9x7gXoDzZGFgLC23ZRn3SnjMZP2y5gD" : address);
                    id = 0n 
                };
            } : sale_info ); ({
                buyer = Some ("tz1LWtbjgecb1SZ6AjHtyGCXPMiR6QZqtm6i" : address);
                commodity = (Tez (100000mutez));
                fa2_token = {
                    address = ("KT1Ti9x7gXoDzZGFgLC23ZRn3SnjMZP2y5gD" : address);
                    id = 1n
                };
            } : sale_info)]
        } : sale_configuration)) 0tez
    in

    match result with
        Success _gas -> failwith "CreateSale - Will deprecate : This test should fail"
    |   Fail (Rejected (err, _)) -> (
            let () = assert_with_error ( Test.michelson_equal err (Test.eval "WILL_BE_DEPRECATED") ) "CreateSale - Will deprecate : Should not work if contract will deprecate" in
            "Passed"
        )
    |   Fail _ -> failwith "Internal test failure"    

// Should fail if price not met minimum price
let test_create_sales_price_to_small_first_el =
    let _, t_add, _, _, admin  = get_fixed_price_contract (false) in


    let () = Test.set_source admin in
    let contract = Test.to_contract t_add in

    let result = Test.transfer_to_contract contract
        (Create_sales ({
            sale_infos = [({
                commodity = (Tez (10mutez));
                buyer = None;
                fa2_token = {
                    address = ("KT1Ti9x7gXoDzZGFgLC23ZRn3SnjMZP2y5gD" : address);
                    id = 0n 
                };
            } : sale_info ); ({
                buyer = Some ("tz1LWtbjgecb1SZ6AjHtyGCXPMiR6QZqtm6i" : address);
                commodity = (Tez (100000mutez));
                fa2_token = {
                    address = ("KT1Ti9x7gXoDzZGFgLC23ZRn3SnjMZP2y5gD" : address);
                    id = 1n
                };
            } : sale_info)]
        } : sale_configuration)) 0tez
    in

    match result with
        Success _gas -> failwith "CreateSale - Wrong price : This test should fail"
    |   Fail (Rejected (err, _)) -> (
            let () = assert_with_error ( Test.michelson_equal err (Test.eval "PRICE_SHOULD_BE_MINIMUM_0.1tez") ) "CreateSale - Wrong price : Should not work if wrong price" in
            "Passed"
        )
    |   Fail _ -> failwith "Internal test failure"    

// Should fail if price not met minimum price
let test_create_sales_price_to_small_third_el =
    let _, t_add, _, _, admin  = get_fixed_price_contract (false) in


    let () = Test.set_source admin in
    let contract = Test.to_contract t_add in

    let result = Test.transfer_to_contract contract
        (Create_sales ({
            sale_infos = [({
                commodity = (Tez (100000mutez));
                buyer = None;
                fa2_token = {
                    address = ("KT1Ti9x7gXoDzZGFgLC23ZRn3SnjMZP2y5gD" : address);
                    id = 0n 
                };
            } : sale_info ); ({
                buyer = Some ("tz1LWtbjgecb1SZ6AjHtyGCXPMiR6QZqtm6i" : address);
                commodity = (Tez (100000mutez));
                fa2_token = {
                    address = ("KT1Ti9x7gXoDzZGFgLC23ZRn3SnjMZP2y5gD" : address);
                    id = 1n
                };
            } : sale_info); ({
                buyer = Some ("tz1LWtbjgecb1SZ6AjHtyGCXPMiR6QZqtm6i" : address);
                commodity = (Tez (10mutez));
                fa2_token = {
                    address = ("KT1Ti9x7gXoDzZGFgLC23ZRn3SnjMZP2y5gD" : address);
                    id = 2n
                };
            } : sale_info)]
        } : sale_configuration)) 0tez
    in

    match result with
        Success _gas -> failwith "CreateSale - Wrong price : This test should fail"
    |   Fail (Rejected (err, _)) -> (
            let () = assert_with_error ( Test.michelson_equal err (Test.eval "PRICE_SHOULD_BE_MINIMUM_0.1tez") ) "CreateSale - Wrong price : Should not work if wrong price" in
            "Passed"
        )
    |   Fail _ -> failwith "Internal test failure"    

// Should fail if already on sale
let test_create_sales_already_on_sale_one_call =
    let _, t_add, _, _, admin  = get_fixed_price_contract (false) in


    let () = Test.set_source admin in
    let contract = Test.to_contract t_add in

    // One call verifying that bulk operation fail
    let result = Test.transfer_to_contract contract
        (Create_sales ({
            sale_infos = [({
                commodity = (Tez (100000mutez));
                buyer = None;
                fa2_token = {
                    address = ("KT1Ti9x7gXoDzZGFgLC23ZRn3SnjMZP2y5gD" : address);
                    id = 0n 
                };
            } : sale_info ); ({
                buyer = Some ("tz1LWtbjgecb1SZ6AjHtyGCXPMiR6QZqtm6i" : address);
                commodity = (Tez (100000mutez));
                fa2_token = {
                    address = ("KT1Ti9x7gXoDzZGFgLC23ZRn3SnjMZP2y5gD" : address);
                    id = 0n
                }
            } : sale_info)]
        } : sale_configuration)) 0tez
    in

    match result with
        Success _gas -> failwith "CreateSale - Already on sale one call : This test should fail"
    |   Fail (Rejected (err, _)) -> (
            let () = assert_with_error ( Test.michelson_equal err (Test.eval "ALREADY_ON_SALE") ) "CreateSale - Already on sale one call : Should not work if already on sale" in
            "Passed"
        )
    |   Fail _ -> failwith "Internal test failure"    
    

// Should fail if already on sale
let test_create_sales_already_on_sale_second_call =
    let _, t_add, _, _, admin  = get_fixed_price_contract (false) in


    let () = Test.set_source admin in
    let contract = Test.to_contract t_add in

    let _gas = Test.transfer_to_contract_exn contract
        (Create_sales ({
            sale_infos = [({
                commodity = (Tez (100000mutez));
                buyer = None;
                fa2_token = {
                    address = ("KT1Ti9x7gXoDzZGFgLC23ZRn3SnjMZP2y5gD" : address);
                    id = 0n 
                }
            } : sale_info )]
        } : sale_configuration)) 0tez
    in

    // Second call to verify that if fails
    let result = Test.transfer_to_contract contract
        (Create_sales ({
            sale_infos = [({
                commodity = (Tez (100000mutez));
                buyer = None;
                fa2_token = {
                    address = ("KT1Ti9x7gXoDzZGFgLC23ZRn3SnjMZP2y5gD" : address);
                    id = 0n 
                }
            } : sale_info )]
        } : sale_configuration)) 0tez
    in

    match result with
        Success _gas -> failwith "CreateSale - Already on sale second call : This test should fail"
    |   Fail (Rejected (err, _)) -> (
            let () = assert_with_error ( Test.michelson_equal err (Test.eval "ALREADY_ON_SALE") ) "CreateSale - Already on sale second call : Should not work if already on sale" in
            "Passed"
        )
    |   Fail _ -> failwith "Internal test failure"    
    
// Should fail if specified buyer is seller
let test_create_sales_buyer_is_seller =
    let _, t_add, _, _, admin  = get_fixed_price_contract (false) in


    let () = Test.set_source admin in
    let contract = Test.to_contract t_add in

    let result = Test.transfer_to_contract contract
        (Create_sales ({
            sale_infos = [({
                commodity = (Tez (150000mutez));
                buyer = None;
                fa2_token = {
                    address = ("KT1Ti9x7gXoDzZGFgLC23ZRn3SnjMZP2y5gD" : address);
                    id = 0n 
                };
            } : sale_info ); ({
                buyer = Some (admin);
                commodity = (Tez (100000mutez));
                fa2_token = {
                    address = ("KT1Ti9x7gXoDzZGFgLC23ZRn3SnjMZP2y5gD" : address);
                    id = 1n
                };
            } : sale_info)]
        } : sale_configuration)) 0tez
    in

    match result with
        Success _gas -> failwith "CreateSale - Buyer is seller : This test should fail (err: Buyer cannot be seller)"
    |   Fail (Rejected (err, _)) -> (
            let () = assert_with_error ( Test.michelson_equal err (Test.eval "BUYER_CANNOT_BE_SELLER") ) "CreateSale - Buyer is seller : Should not work if buyer is seller" in
            "Passed"
        )
    |   Fail _ -> failwith "Internal test failure"    

// -- UPDATE SALES --

// Success
let test_update_sales = 
    let _, t_add, _, _, admin  = get_fixed_price_contract (false) in


    let () = Test.set_source admin in
    let contract = Test.to_contract t_add in

    let _gas = Test.transfer_to_contract_exn contract
        (Create_sales ({
            sale_infos = [({
                commodity = (Tez (150000mutez));
                buyer = None;
                fa2_token = {
                    address = ("KT1Ti9x7gXoDzZGFgLC23ZRn3SnjMZP2y5gD" : address);
                    id = 0n 
                };
            } : sale_info ); ({
                buyer = Some ("tz1LWtbjgecb1SZ6AjHtyGCXPMiR6QZqtm6i" : address);
                commodity = (Tez (100000mutez));
                fa2_token = {
                    address = ("KT1Ti9x7gXoDzZGFgLC23ZRn3SnjMZP2y5gD" : address);
                    id = 1n
                };
            } : sale_info)]
        } : sale_configuration)) 0tez
    in

    // Changing sale infos (switching buyer option and prices) - Changing two times the same sale and verify last result is taken
    let result = Test.transfer_to_contract contract
        (Update_sales ([({
                buyer = Some ("tz1LWtbjgecb1SZ6AjHtyGCXPMiR6QZqtm6i" : address);
                commodity = (Tez (250000mutez));
                fa2_token = {
                    address = ("KT1Ti9x7gXoDzZGFgLC23ZRn3SnjMZP2y5gD" : address);
                    id = 0n 
                };
            } : sale_info ); ({
                buyer = None;
                commodity = (Tez (130000mutez));
                fa2_token = {
                    address = ("KT1Ti9x7gXoDzZGFgLC23ZRn3SnjMZP2y5gD" : address);
                    id = 1n
                };
            } : sale_info);
            ({
                buyer = None;
                commodity = (Tez (170000mutez));
                fa2_token = {
                    address = ("KT1Ti9x7gXoDzZGFgLC23ZRn3SnjMZP2y5gD" : address);
                    id = 1n
                };
            } : sale_info)])
        ) 0tez
    in

    let new_str = Test.get_storage t_add in
    match result with
          Success _gas -> (
                // Check first sale if well saved
                let first_update_sale_key : fa2_base * address = (
                    {
                        address = ( "KT1Ti9x7gXoDzZGFgLC23ZRn3SnjMZP2y5gD" : address);
                        id = 0n
                    },
                    admin
                 ) in
                let () = match Big_map.find_opt first_update_sale_key new_str.for_sale with
                        Some fixed_price_saved -> (
                            let () = assert_with_error (fixed_price_saved.commodity = (Tez (250000mutez))) "UpdateSale - Success : This test should pass (err: First sale wrong updated price saved)" in
                            match fixed_price_saved.buyer with 
                                    Some buyer -> assert_with_error (buyer = ("tz1LWtbjgecb1SZ6AjHtyGCXPMiR6QZqtm6i" : address)) "UpdateSale - Success : This test should pass (err: Second sale wrong buyer saved while updating)"
                                |   None -> (failwith "UpdateSale - Success : This test should pass (err: First sale new buyer should be saved)" : unit)
                        )
                    |   None -> (failwith "UpdateSale - Success : This test should pass (err: First sale should not be deleted)" : unit)
                in
                // Check second sale if well saved
                let second_sale_update_key : fa2_base * address = (
                    {
                        address = ( "KT1Ti9x7gXoDzZGFgLC23ZRn3SnjMZP2y5gD" : address);
                        id = 1n
                    },
                    admin
                 ) in
                let () = match Big_map.find_opt second_sale_update_key new_str.for_sale with
                        Some fixed_price_saved -> (
                            let () = assert_with_error (fixed_price_saved.commodity = (Tez (170000mutez))) "UpdateSale - Success : This test should pass (err: Second sale wrong updated price saved)" in
                            match fixed_price_saved.buyer with 
                                    Some _ ->  (failwith "UpdateSale - Success : This test should pass (err: Second sale new buyer should be none)" : unit)
                                |   None -> unit
                        )
                    |   None -> (failwith "UpdateSale - Success : This test should pass (err: Second sale should not be deleted)" : unit)
                in
                "Passed"
          )
        |   Fail (Rejected (_err, _)) -> "UpdateSale - Success : This test should pass"
        |   Fail _ -> failwith "Internal test failure"    

// Should fail if amount specified
let test_update_sales_amount_specified =
    let _, t_add, _, _, admin  = get_fixed_price_contract (false) in


    let () = Test.set_source admin in
    let contract = Test.to_contract t_add in

    let result = Test.transfer_to_contract contract
        (Update_sales ([({
                buyer = Some ("tz1LWtbjgecb1SZ6AjHtyGCXPMiR6QZqtm6i" : address);
                commodity = (Tez (250000mutez));
                fa2_token = {
                    address = ("KT1Ti9x7gXoDzZGFgLC23ZRn3SnjMZP2y5gD" : address);
                    id = 0n 
                };
            } : sale_info ); ({
                buyer = None;
                commodity = (Tez (130000mutez));
                fa2_token = {
                    address = ("KT1Ti9x7gXoDzZGFgLC23ZRn3SnjMZP2y5gD" : address);
                    id = 1n
                };
            } : sale_info)])
        ) 1tez
    in

    match result with
        Success _gas -> failwith "UpdateSale - No amount : This test should fail (err: Amount specified for update_sales entrypoint)"
    |   Fail (Rejected (err, _)) -> (
            let () = assert_with_error ( Test.michelson_equal err (Test.eval "AMOUNT_SHOULD_BE_0TEZ") ) "UpdateSale - No amount : Should not work if amount specified" in
            "Passed"
        )
    |   Fail _ -> failwith "Internal test failure"    

// Should fail if price does not meet minimum price
let test_update_sales_to_small_first_el =
    let _, t_add, _, _, admin  = get_fixed_price_contract (false) in


    let () = Test.set_source admin in
    let contract = Test.to_contract t_add in

    let result = Test.transfer_to_contract contract
         (Update_sales ([({
                buyer = Some ("tz1LWtbjgecb1SZ6AjHtyGCXPMiR6QZqtm6i" : address);
                commodity = (Tez (100mutez));
                fa2_token = {
                    address = ("KT1Ti9x7gXoDzZGFgLC23ZRn3SnjMZP2y5gD" : address);
                    id = 0n 
                };
            } : sale_info ); ({
                buyer = None;
                commodity = (Tez (130000mutez));
                fa2_token = {
                    address = ("KT1Ti9x7gXoDzZGFgLC23ZRn3SnjMZP2y5gD" : address);
                    id = 1n
                };
            } : sale_info)])
        ) 0tez
    in

    match result with
        Success _gas -> failwith "UpdateSale - Wrong price : This test should fail"
    |   Fail (Rejected (err, _)) -> (
            let () = assert_with_error ( Test.michelson_equal err (Test.eval "PRICE_SHOULD_BE_MINIMUM_0.1tez") ) "UpdateSale - Wrong price : Should not work if wrong price" in
            "Passed"
        )
    |   Fail _ -> failwith "Internal test failure"    


// Should fail if price does not meet minimum price
let test_update_sales_to_small_second_el =
    let _, t_add, _, _, admin  = get_fixed_price_contract (false) in


    let () = Test.set_source admin in
    let contract = Test.to_contract t_add in

    let _gas = Test.transfer_to_contract_exn contract
        (Create_sales ({
            sale_infos = [({
                commodity = (Tez (150000mutez));
                buyer = None;
                fa2_token = {
                    address = ("KT1Ti9x7gXoDzZGFgLC23ZRn3SnjMZP2y5gD" : address);
                    id = 0n 
                };
            } : sale_info ); ({
                buyer = Some ("tz1LWtbjgecb1SZ6AjHtyGCXPMiR6QZqtm6i" : address);
                commodity = (Tez (100000mutez));
                fa2_token = {
                    address = ("KT1Ti9x7gXoDzZGFgLC23ZRn3SnjMZP2y5gD" : address);
                    id = 1n
                };
            } : sale_info)]
        } : sale_configuration)) 0tez
    in

    let result = Test.transfer_to_contract contract
         (Update_sales ([({
                buyer = Some ("tz1LWtbjgecb1SZ6AjHtyGCXPMiR6QZqtm6i" : address);
                commodity = (Tez (130000mutez));
                fa2_token = {
                    address = ("KT1Ti9x7gXoDzZGFgLC23ZRn3SnjMZP2y5gD" : address);
                    id = 0n 
                };
            } : sale_info ); ({
                buyer = None;
                commodity = (Tez (100mutez));
                fa2_token = {
                    address = ("KT1Ti9x7gXoDzZGFgLC23ZRn3SnjMZP2y5gD" : address);
                    id = 1n
                };
            } : sale_info)])
        ) 0tez
    in

    match result with
        Success _gas -> failwith "UpdateSale - Wrong price : This test should fail"
    |   Fail (Rejected (err, _)) -> (
            let () = assert_with_error ( Test.michelson_equal err (Test.eval "PRICE_SHOULD_BE_MINIMUM_0.1tez") ) "UpdateSale - Wrong price : Should not work if wrong price" in
            "Passed"
        )
    |   Fail _ -> failwith "Internal test failure"    

// Should fail if updated buyer is seller
let test_update_sales_buyer_is_sender = 
    let _, t_add, _, _, admin  = get_fixed_price_contract (false) in


    let () = Test.set_source admin in
    let contract = Test.to_contract t_add in

    let _gas = Test.transfer_to_contract_exn contract
        (Create_sales ({
            sale_infos = [({
                commodity = (Tez (150000mutez));
                buyer = None;
                fa2_token = {
                    address = ("KT1Ti9x7gXoDzZGFgLC23ZRn3SnjMZP2y5gD" : address);
                    id = 0n 
                };
            } : sale_info ); ({
                buyer = Some ("tz1LWtbjgecb1SZ6AjHtyGCXPMiR6QZqtm6i" : address);
                commodity = (Tez (100000mutez));
                fa2_token = {
                    address = ("KT1Ti9x7gXoDzZGFgLC23ZRn3SnjMZP2y5gD" : address);
                    id = 1n
                };
            } : sale_info)]
        } : sale_configuration)) 0tez
    in

    let result = Test.transfer_to_contract contract
         (Update_sales ([({
                buyer = Some (admin);
                commodity = (Tez (130000mutez));
                fa2_token = {
                    address = ("KT1Ti9x7gXoDzZGFgLC23ZRn3SnjMZP2y5gD" : address);
                    id = 0n 
                };
            } : sale_info ); ({
                buyer = None;
                commodity = (Tez (100mutez));
                fa2_token = {
                    address = ("KT1Ti9x7gXoDzZGFgLC23ZRn3SnjMZP2y5gD" : address);
                    id = 1n
                };
            } : sale_info)])
        ) 0tez
    in

    match result with
        Success _gas -> failwith "UpdateSale - Buyer is sender : This test should fail"
    |   Fail (Rejected (err, _)) -> (
            let () = assert_with_error ( Test.michelson_equal err (Test.eval "BUYER_CANNOT_BE_SELLER") ) "UpdateSale - Buyer is sender : Should not work if buyer is sender" in
            "Passed"
        )
    |   Fail _ -> failwith "Internal test failure"    

// Should fail if sender is not owner of the sale
let test_update_sales_not_owner =
    let _, t_add, _, _, admin  = get_fixed_price_contract (false) in


    let () = Test.set_source admin in
    let contract = Test.to_contract t_add in

    let _gas = Test.transfer_to_contract_exn contract
        (Create_sales ({
            sale_infos = [({
                commodity = (Tez (150000mutez));
                buyer = None;
                fa2_token = {
                    address = ("KT1Ti9x7gXoDzZGFgLC23ZRn3SnjMZP2y5gD" : address);
                    id = 0n 
                };
            } : sale_info ); ({
                buyer = Some ("tz1LWtbjgecb1SZ6AjHtyGCXPMiR6QZqtm6i" : address);
                commodity = (Tez (100000mutez));
                fa2_token = {
                    address = ("KT1Ti9x7gXoDzZGFgLC23ZRn3SnjMZP2y5gD" : address);
                    id = 1n
                };
            } : sale_info)]
        } : sale_configuration)) 0tez
    in

    let no_admin_addr = Test.nth_bootstrap_account 1 in
    let () = Test.set_source no_admin_addr in

    // Attacker trying to change sale params to there own address an change the price
    let result = Test.transfer_to_contract contract
         (Update_sales ([({
                buyer = Some (no_admin_addr : address);
                commodity = (Tez (100000mutez));
                fa2_token = {
                    address = ("KT1Ti9x7gXoDzZGFgLC23ZRn3SnjMZP2y5gD" : address);
                    id = 0n 
                };
            } : sale_info ); ({
                buyer = Some (no_admin_addr : address);
                commodity = (Tez (1000000mutez));
                fa2_token = {
                    address = ("KT1Ti9x7gXoDzZGFgLC23ZRn3SnjMZP2y5gD" : address);
                    id = 1n
                };
            } : sale_info)])
        ) 0tez
    in

    match result with
        Success _gas -> failwith "UpdateSale - Not sale owner : This test should fail"
    |   Fail (Rejected (err, _)) -> (
            let () = assert_with_error ( Test.michelson_equal err (Test.eval "NOT_SELLER_OR_NOT_FOR_SALE") ) "UpdateSale - Not sale owner : Should not work if sender is not seller" in
            "Passed"
        )
    |   Fail _ -> failwith "Internal test failure"   


// Should fail if sale is not created
let test_update_sales_not_created =
    let _, t_add, _, _, admin  = get_fixed_price_contract (false) in


    let () = Test.set_source admin in
    let contract = Test.to_contract t_add in

    let result = Test.transfer_to_contract contract
         (Update_sales ([({
                buyer = None;
                commodity = (Tez (130000mutez));
                fa2_token = {
                    address = ("KT1Ti9x7gXoDzZGFgLC23ZRn3SnjMZP2y5gD" : address);
                    id = 0n 
                };
            } : sale_info ); ({
                buyer = None;
                commodity = (Tez (100mutez));
                fa2_token = {
                    address = ("KT1Ti9x7gXoDzZGFgLC23ZRn3SnjMZP2y5gD" : address);
                    id = 1n
                };
            } : sale_info)])
        ) 0tez
    in

    match result with
        Success _gas -> failwith "UpdateSale - Sale is not created : This test should fail"
    |   Fail (Rejected (err, _)) -> (
            let () = assert_with_error ( Test.michelson_equal err (Test.eval "NOT_SELLER_OR_NOT_FOR_SALE") ) "UpdateSale - Sale is not created : Should not work if sale is not created" in
            "Passed"
        )
    |   Fail _ -> failwith "Internal test failure"    

// -- REVOKE SALE --

// Success
let test_revoke_sales = 
    let _, t_add, _, _, admin  = get_fixed_price_contract (false) in


    let () = Test.set_source admin in
    let contract = Test.to_contract t_add in

    let _gas = Test.transfer_to_contract_exn contract
        (Create_sales ({
            sale_infos = [({
                commodity = (Tez (150000mutez));
                buyer = None;
                fa2_token = {
                    address = ("KT1Ti9x7gXoDzZGFgLC23ZRn3SnjMZP2y5gD" : address);
                    id = 0n 
                };
            } : sale_info ); ({
                buyer = Some ("tz1LWtbjgecb1SZ6AjHtyGCXPMiR6QZqtm6i" : address);
                commodity = (Tez (100000mutez));
                fa2_token = {
                    address = ("KT1Ti9x7gXoDzZGFgLC23ZRn3SnjMZP2y5gD" : address);
                    id = 1n
                };
            } : sale_info)]
        } : sale_configuration)) 0tez
    in

    // Changing sale infos (switching buyer option and prices) - Changing two times the same sale and verify last result is taken
    let result = Test.transfer_to_contract contract
        (Revoke_sales ({
            fa2_tokens = [
            ({
                address = ("KT1Ti9x7gXoDzZGFgLC23ZRn3SnjMZP2y5gD" : address);
                id = 0n 
            } : fa2_base ); 
            ({
                address = ("KT1Ti9x7gXoDzZGFgLC23ZRn3SnjMZP2y5gD" : address);
                id = 1n
            }: fa2_base)
        ]} : revoke_param)) 0tez
    in

    let new_str = Test.get_storage t_add in
    match result with
          Success _gas -> (
                // Check first sale if well saved
                let first_deleted_sale_key : fa2_base * address = (
                    {
                        address = ( "KT1Ti9x7gXoDzZGFgLC23ZRn3SnjMZP2y5gD" : address);
                        id = 0n
                    },
                    admin
                 ) in
                let () = match Big_map.find_opt first_deleted_sale_key new_str.for_sale with
                        Some _ -> (failwith "RevokeSale - Success : This test should pass (err: First sale should be deleted)" : unit)
                    |   None -> unit
                in
                // Check second sale if well saved
                let second_deleted_sale_key : fa2_base * address = (
                    {
                        address = ( "KT1Ti9x7gXoDzZGFgLC23ZRn3SnjMZP2y5gD" : address);
                        id = 1n
                    },
                    admin
                 ) in
                let () = match Big_map.find_opt second_deleted_sale_key new_str.for_sale with
                        Some _ -> (failwith "RevokeSale - Success : This test should pass (err: Second sale should be deleted)" : unit)
                    |   None -> unit
                in
                "Passed"
          )
        |   Fail (Rejected (_err, _)) -> "RevokeSale - Success : This test should pass"
        |   Fail _ -> failwith "Internal test failure"    

// Should fail if amount specified
let test_revoke_sales_with_amount = 
    let _, t_add, _, _, admin  = get_fixed_price_contract (false) in


    let () = Test.set_source admin in
    let contract = Test.to_contract t_add in

    let result = Test.transfer_to_contract contract
        (Revoke_sales ({
            fa2_tokens = [
            ({
                address = ("KT1Ti9x7gXoDzZGFgLC23ZRn3SnjMZP2y5gD" : address);
                id = 0n 
            } : fa2_base ); 
            ({
                address = ("KT1Ti9x7gXoDzZGFgLC23ZRn3SnjMZP2y5gD" : address);
                id = 1n
            }: fa2_base)
        ]} : revoke_param)) 1tez
    in

    match result with
        Success _gas -> failwith "RevokeSale - No amount : This test should fail (err: Amount specified for revoke_sales entrypoint)"
    |   Fail (Rejected (err, _)) -> (
            let () = assert_with_error ( Test.michelson_equal err (Test.eval "AMOUNT_SHOULD_BE_0TEZ") ) "RevokeSale - No amount : Should not work if amount specified" in
            "Passed"
        )
    |   Fail _ -> failwith "Internal test failure"    

// Should fail if sale is not created
let test_revoke_sales_not_created =
    let _, t_add, _, _, admin  = get_fixed_price_contract (false) in


    let () = Test.set_source admin in
    let contract = Test.to_contract t_add in

   let result = Test.transfer_to_contract contract
        (Revoke_sales ({
            fa2_tokens = [
            ({
                address = ("KT1Ti9x7gXoDzZGFgLC23ZRn3SnjMZP2y5gD" : address);
                id = 0n 
            } : fa2_base ); 
            ({
                address = ("KT1Ti9x7gXoDzZGFgLC23ZRn3SnjMZP2y5gD" : address);
                id = 1n
            }: fa2_base)
        ]} : revoke_param)) 0tez
    in

    match result with
        Success _gas -> failwith "RevokeSale - Sale is not created : This test should fail"
    |   Fail (Rejected (err, _)) -> (
            let () = assert_with_error ( Test.michelson_equal err (Test.eval "NOT_SELLER_OR_NOT_FOR_SALE") ) "RevokeSale - Sale is not created : Should not work if sale is not created" in
            "Passed"
        )
    |   Fail _ -> failwith "Internal test failure"    

// Should fail if sender not owner
let test_revoke_sales_not_owner =
    let _, t_add, _, _, admin  = get_fixed_price_contract (false) in


    let () = Test.set_source admin in
    let contract = Test.to_contract t_add in

    let _gas = Test.transfer_to_contract_exn contract
        (Create_sales ({
            sale_infos = [({
                commodity = (Tez (150000mutez));
                buyer = None;
                fa2_token = {
                    address = ("KT1Ti9x7gXoDzZGFgLC23ZRn3SnjMZP2y5gD" : address);
                    id = 0n 
                };
            } : sale_info ); ({
                buyer = Some ("tz1LWtbjgecb1SZ6AjHtyGCXPMiR6QZqtm6i" : address);
                commodity = (Tez (100000mutez));
                fa2_token = {
                    address = ("KT1Ti9x7gXoDzZGFgLC23ZRn3SnjMZP2y5gD" : address);
                    id = 1n
                };
            } : sale_info)]
        } : sale_configuration)) 0tez
    in

    let no_admin_addr = Test.nth_bootstrap_account 1 in
    let () = Test.set_source no_admin_addr in

   let result = Test.transfer_to_contract contract
        (Revoke_sales ({
            fa2_tokens = [
            ({
                address = ("KT1Ti9x7gXoDzZGFgLC23ZRn3SnjMZP2y5gD" : address);
                id = 0n 
            } : fa2_base ); 
            ({
                address = ("KT1Ti9x7gXoDzZGFgLC23ZRn3SnjMZP2y5gD" : address);
                id = 1n
            }: fa2_base)
        ]} : revoke_param)) 0tez
    in

    match result with
        Success _gas -> failwith "RevokeSale - Not sale owner : This test should fail"
    |   Fail (Rejected (err, _)) -> (
            let () = assert_with_error ( Test.michelson_equal err (Test.eval "NOT_SELLER_OR_NOT_FOR_SALE") ) "RevokeSale - Not sale owner : Should not work if not sale owner" in
            "Passed"
        )
    |   Fail _ -> failwith "Internal test failure"    
