#include "storage.test.mligo"

// This storage is based on the contract fa2_editions
// you can find it at this link https://github.com/D-a-rt/there.fa2-editions
// The type below have been taken on the same contract for convenience

// Fail if buyer is seller
let test_buy_fixed_price_token_seller_buyer =
    let _, contract_t_add, _, _, admin = get_fixed_price_contract (false) in

    let () = Test.set_source admin in
    let contract = Test.to_contract contract_t_add in

    let result = Test.transfer_to_contract contract
        (Buy_fixed_price_token ({
            fa2_token = ({
                id = 0n;
                address = ("KT1Ti9x7gXoDzZGFgLC23ZRn3SnjMZP2y5gD" : address);
            } : fa2_base);
            seller = admin;
            receiver =admin;
            referrer = (None : address option);
        } : buy_token)) 0tez
    in

    match result with
        Success _gas -> failwith "Buy_fixed_price_token - Seller is buyer : This test should fail"
    |   Fail (Rejected (err, _)) -> (
            let () = assert_with_error ( Test.michelson_equal err (Test.eval "SELLER_NOT_AUTHORIZED") ) "Buy_fixed_price_token - Seller is buyer : Should not work if seller is buyer" in
            "Passed"
        )
    |   Fail _ -> failwith "Internal test failure"    

// Fail if wrong price specified
let test_buy_fixed_price_token_wrong_price = 
    let _, t_add,  fa2_add, _, admin = get_fixed_price_contract (false) in 
    
    let admin_addr = Test.nth_bootstrap_account 0 in
    let () = Test.set_source admin_addr in
    
    let contract = Test.to_contract t_add in

    let _gas = Test.transfer_to_contract_exn contract
        (Create_sales ({
            sale_infos = [({
                commodity = (Tez (150000mutez));
                buyer = None;
                fa2_token = {
                    address = (fa2_add : address);
                    id = 0n 
                };
            } : sale_info );]
        } : sale_configuration)) 0tez
    in

    let no_admin_addr = Test.nth_bootstrap_account 1 in
    let () = Test.set_source no_admin_addr in

    let result = Test.transfer_to_contract contract
        (Buy_fixed_price_token ({
            fa2_token = ({
                id = 0n;
                address = (fa2_add: address);
            } : fa2_base);
            seller = admin;
            receiver =no_admin_addr;
            referrer = (None : address option);
        })) 100mutez
    in

    match result with
        Success _gas -> failwith "Buy_fixed_price_token - Wrong price specified : This test should fail"
    |   Fail (Rejected (err, _)) -> (
            let () = assert_with_error ( Test.michelson_equal err (Test.eval "WRONG_PRICE_SPECIFIED") ) "Buy_fixed_price_token - Wrong price specified : Should not work if wrong price" in
            "Passed"
        )
    |   Fail _ -> failwith "Internal test failure"    

// Fail if not buyer
let test_buy_fixed_price_token_not_buyer =
    let _, t_add,  fa2_add, _, admin = get_fixed_price_contract (false) in 

    let admin_addr = Test.nth_bootstrap_account 0 in
    let () = Test.set_source admin_addr in
    
    let contract = Test.to_contract t_add in

    let _gas = Test.transfer_to_contract_exn contract
        (Create_sales ({
            sale_infos = [({
                commodity = (Tez (150000mutez));
                buyer = Some ("tz1LWtbjgecb1SZ6AjHtyGCXPMiR6QZqtm6i" : address );
                fa2_token = {
                    address = (fa2_add : address);
                    id = 0n 
                };
            } : sale_info );]
        } : sale_configuration)) 0tez
    in

    let no_admin_addr = Test.nth_bootstrap_account 1 in
    let () = Test.set_source no_admin_addr in

    let result = Test.transfer_to_contract contract
        (Buy_fixed_price_token ({
            fa2_token = ({
                id = 0n;
                address = (fa2_add : address);
            } : fa2_base);
            seller = admin;
            receiver =no_admin_addr;
            referrer = (None : address option);
      
        })) 150000mutez
    in

    match result with
        Success _gas -> failwith "Buy_fixed_price_token - Not specified buyer : This test should fail"
    |   Fail (Rejected (err, _)) -> (
            let () = assert_with_error ( Test.michelson_equal err (Test.eval "BUYER_NOT_AUTHORIZE_TO_BUY") ) "Buy_fixed_price_token - Not specified buyer : Should not work if buye not authorized" in
            "Passed"
        )
    |   Fail _ -> failwith "Internal test failure"    


// Success - verify fa2 transfer, fee & royalties
let test_buy_fixed_price_token_success =
    let _, t_add,  fa2_add, t_fa2_add, admin = get_fixed_price_contract (false) in 
    
    let token_seller = Test.nth_bootstrap_account 3 in
    let () = Test.set_source token_seller in
    
    let contract = Test.to_contract t_add in

    // Get balance of different actors of the sale to verify 
    // that fees and royalties are sent correctly
    let fee_account = Test.nth_bootstrap_account 2 in
    let fee_account_bal = Test.get_balance fee_account in
    
    let token_minter = Test.nth_bootstrap_account 4 in
    let token_minter_bal = Test.get_balance token_minter in

    let token_split = Test.nth_bootstrap_account 5 in
    let token_split_bal = Test.get_balance token_split in

    let _gas_creation_sale = Test.transfer_to_contract_exn contract
        (Create_sales ({
            sale_infos = [({
                commodity = (Tez (213210368547757mutez));
                buyer = None;
                fa2_token = {
                    address = (fa2_add : address);
                    id = 0n 
                };
            } : sale_info );]
        } : sale_configuration)) 0tez
    in

    let buyer = Test.nth_bootstrap_account 1 in
    let () = Test.set_source buyer in

    let token_seller_bal = Test.get_balance token_seller in

    let result = Test.transfer_to_contract contract
        (Buy_fixed_price_token ({
            fa2_token = ({
                id = 0n;
                address = (fa2_add : address);
            } : fa2_base);
            seller = token_seller;
            receiver = buyer;
            referrer = (None : address option);
        })) 213210368547757mutez
    in

    // To check the result of the edition storage account
    let edition_str = Test.get_storage t_fa2_add in
    // To check the result of the fixed price storage account
    let new_fp_str = Test.get_storage t_add in

    match result with
        Success _gas -> (
            // Check that sale is deleted from big map
            let sale_key : fa2_base * address = (
                {
                    address = (fa2_add : address);
                    id = 0n
                },
                admin
            ) in
            let () = match Big_map.find_opt sale_key new_fp_str.for_sale with
                    Some _ -> (failwith "Buy_fixed_price_token - Success : This test should pass (err: Token still for sale)" : unit)
                |   None -> unit
            in
            
            // Check that fees been transfer to fee address
            let new_fee_account_bal = Test.get_balance fee_account in
            let () =    if new_fee_account_bal - fee_account_bal = Some (21321036854775mutez)
                        then unit
                        else (failwith "Buy_fixed_price_token - Success : This test should pass (err: Wrong percentage sent to fee address)" : unit)
            in

            // Check that 50% of the 15% royalties have been sent correctly to minter
            let new_minter_account_bal = Test.get_balance token_minter in
            let () =    if new_minter_account_bal - token_minter_bal = Some (15990777641081mutez)
                        then unit
                        else (failwith "Buy_fixed_price_token - Success : This test should pass (err: Wrong percentage sent to minter address)" : unit)
            in

            // Admin 50% of the 15% royalties here
            let new_token_split_bal = Test.get_balance token_split in
            let () =    if new_token_split_bal - token_split_bal = Some (15990777641081mutez)
                        then unit
                        else (failwith "Buy_fixed_price_token - Success : This test should pass (err: Wrong percentage sent to royaltie address)" : unit)
            in

            // Check that seller got the right amount
            let new_token_seller_bal = Test.get_balance token_seller in
            let () =    if new_token_seller_bal - token_seller_bal = Some (159907776410820mutez)
                        then unit
                        else (failwith "Buy_fixed_price_token - Success : This test should pass (err: Wrong value sent to seller)" : unit)
            in
                                    
            // Check that buyer owns the token
            let () = match Big_map.find_opt 0n edition_str.assets.ledger with
                    Some add -> (
                        if add = buyer
                        then unit
                        else (failwith "Buy_fixed_price_token - Success : This test should pass (err: Wrong address to the token)" : unit) 
                    )
                |   None -> (failwith "Buy_fixed_price_token - Success : This test should pass (err: Token should have a value)" : unit)
            in
            "Passed"
        )   
    |   Fail (Rejected (_err, _)) -> failwith "Buy_fixed_price_token - Success : This test should pass"    
    
    |   Fail _err -> failwith "Internal test failure"    

// Success - verify fa2 space transfer, fee & royalties
let test_buy_fixed_price_token_success_commission =
    let _, t_add, space, fa2_add, t_fa2_add, admin = get_fixed_price_contract_space (false, true) in 
    
    let contract = Test.to_contract t_add in

    // Get balance of different actors of the sale to verify 
    // that fees and royalties are sent correctly
    let fee_account = Test.nth_bootstrap_account 2 in
    let fee_account_bal = Test.get_balance fee_account in
    
    let token_minter = Test.nth_bootstrap_account 3 in
    
    let token_split = Test.nth_bootstrap_account 5 in
    let token_split_bal = Test.get_balance token_split in

    let space_bal = Test.get_balance space in

    let () = Test.set_source token_minter in

    let _gas_creation_sale = Test.transfer_to_contract_exn contract
        (Create_sales ({
            sale_infos = [({
                commodity = (Tez (100tez));
                buyer = None;
                fa2_token = {
                    address = (fa2_add : address);
                    id = 0n 
                };
            } : sale_info );]
        } : sale_configuration)) 0tez
    in

    let token_minter_bal = Test.get_balance token_minter in

    let buyer = Test.nth_bootstrap_account 1 in
    let () = Test.set_source buyer in

    let result = Test.transfer_to_contract contract
        (Buy_fixed_price_token ({
            fa2_token = ({
                id = 0n;
                address = (fa2_add : address);
            } : fa2_base);
            seller = token_minter;
            receiver =buyer;
            referrer = (None : address option);
      
        })) 100tez
    in

    // To check the result of the edition storage account
    let edition_str = Test.get_storage t_fa2_add in
    // To check the result of the fixed price storage account
    let new_fp_str = Test.get_storage t_add in

    match result with
        Success _gas -> (
            // Check that sale is deleted from big map
            let sale_key : fa2_base * address = (
                {
                    address = (fa2_add : address);
                    id = 0n
                },
                admin
            ) in
            let () = match Big_map.find_opt sale_key new_fp_str.for_sale with
                    Some _ -> (failwith "Buy_fixed_price_token - Success : This test should pass (err: Token still for sale)" : unit)
                |   None -> unit
            in
            
            // Check that fees been transfer to fee address
            let new_fee_account_bal = Test.get_balance fee_account in
            let () =    if new_fee_account_bal - fee_account_bal = Some (10tez)
                        then unit
                        else (failwith "Buy_fixed_price_token - Success : This test should pass (err: Wrong percentage sent to fee address)" : unit)
            in

            // Admin 50% of the 15% royalties here
            let new_token_split_bal = Test.get_balance token_split in
            let () =    if new_token_split_bal - token_split_bal = Some (7.5tez)
                        then unit
                        else (failwith "Buy_fixed_price_token - Success : This test should pass (err: Wrong percentage sent to royaltie address)" : unit)
            in

            let new_space_account_bal = Test.get_balance space in
            let () =    if new_space_account_bal - space_bal = Some (50tez)
                        then unit   
                        else (failwith "AcceptOffer - Success : This test should pass (err: Wrong percentage sent to commission address)" : unit)
            in

            // Check that seller got the right amount
            let new_token_minter_bal = Test.get_balance token_minter in
            let () =    if new_token_minter_bal - token_minter_bal = Some (32.5tez)
                        then unit
                        else (failwith "Buy_fixed_price_token - Success : This test should pass (err: Wrong value sent to seller)" : unit)
            in
                                    
            // Check that buyer owns the token
            let () = match Big_map.find_opt 0n edition_str.assets.ledger with
                    Some add -> (
                        if add = buyer
                        then unit
                        else (failwith "Buy_fixed_price_token - Success : This test should pass (err: Wrong address to the token)" : unit) 
                    )
                |   None -> (failwith "Buy_fixed_price_token - Success : This test should pass (err: Token should have a value)" : unit)
            in
            "Passed"
        )   
    |   Fail (Rejected (_err, _)) -> failwith "Buy_fixed_price_token - Success : This test should pass"    
    |   Fail _err -> failwith "Internal test failure"        

let test_buy_fixed_price_token_success_secondary = 
    let _, t_add,  fa2_add, t_fa2_add, admin = get_fixed_price_contract (false) in 
    
    let token_seller = Test.nth_bootstrap_account 3 in
    let () = Test.set_source token_seller in
    
    let contract = Test.to_contract t_add in

    let _gas_creation_sale = Test.transfer_to_contract_exn contract
        (Create_sales ({
            sale_infos = [({
                commodity = (Tez (213210368547757mutez));
                buyer = None;
                fa2_token = {
                    address = (fa2_add : address);
                    id = 0n 
                };
            } : sale_info );]
        } : sale_configuration)) 0tez
    in

    let buyer = Test.nth_bootstrap_account 1 in
    let () = Test.set_source buyer in

    let _gas = Test.transfer_to_contract_exn contract
        (Buy_fixed_price_token ({
            fa2_token = ({
                id = 0n;
                address = (fa2_add : address);
            } : fa2_base);
            seller = token_seller;
            receiver =buyer;
            referrer = (None : address option);
      
        })) 213210368547757mutez
    in

    // Get balance of different actors of the sale to verify 
    // that fees and royalties are sent correctly
    

    let fee_account = Test.nth_bootstrap_account 2 in
    let fee_account_bal = Test.get_balance fee_account in
    
    let token_minter = Test.nth_bootstrap_account 4 in
    let token_minter_bal = Test.get_balance token_minter in

    let token_split = Test.nth_bootstrap_account 5 in
    let token_split_bal = Test.get_balance token_split in

    let _gas_creation_sale = Test.transfer_to_contract_exn contract
        (Create_sales ({
            sale_infos = [({
                commodity = (Tez (213210368547757mutez));
                buyer = None;
                fa2_token = {
                    address = (fa2_add : address);
                    id = 0n 
                };
            } : sale_info );]
        } : sale_configuration)) 0tez
    in

    let () = Test.set_source token_seller in
    let token_seller_bal = Test.get_balance buyer in

    let result = Test.transfer_to_contract contract
        (Buy_fixed_price_token ({
            fa2_token = ({
                id = 0n;
                address = (fa2_add : address);
            } : fa2_base);
            seller = buyer;
            receiver =token_seller;
            referrer = (None : address option);
      
        })) 213210368547757mutez
    in

    // To check the result of the edition storage account
    let edition_str = Test.get_storage t_fa2_add in
    // To check the result of the fixed price storage account
    let new_fp_str = Test.get_storage t_add in

    match result with
        Success _gas -> (
            // Check that sale is deleted from big map
            let sale_key : fa2_base * address = (
                {
                    address = (fa2_add : address);
                    id = 0n
                },
                admin
            ) in
            let () = match Big_map.find_opt sale_key new_fp_str.for_sale with
                    Some _ -> (failwith "Buy_fixed_price_token - Success : This test should pass (err: Token still for sale)" : unit)
                |   None -> unit
            in
            
            // Check that fees been transfer to fee address
            let new_fee_account_bal = Test.get_balance fee_account in
            let () =    if new_fee_account_bal - fee_account_bal = Some (7462362899171mutez)
                        then unit
                        else (failwith "Buy_fixed_price_token - Success : This test should pass (err: Wrong percentage sent to fee address)" : unit)
            in

            // Check that 50% of the 15% royalties have been sent correctly to minter
            let new_minter_account_bal = Test.get_balance token_minter in
            let () =    if new_minter_account_bal - token_minter_bal = Some (15990777641081mutez)
                        then unit
                        else (failwith "Buy_fixed_price_token - Success : This test should pass (err: Wrong percentage sent to minter address)" : unit)
            in

            // Admin 50% of the 15% royalties here
            let new_token_split_bal = Test.get_balance token_split in
            let () =    if new_token_split_bal - token_split_bal = Some (15990777641081mutez)
                        then unit
                        else (failwith "Buy_fixed_price_token - Success : This test should pass (err: Wrong percentage sent to royaltie address)" : unit)
            in

            // Check that seller got the right amount
            let new_token_seller_bal = Test.get_balance buyer in
            let () =    if new_token_seller_bal - token_seller_bal = Some (173766450366424mutez)
                        then unit
                        else (failwith "Buy_fixed_price_token - Success : This test should pass (err: Wrong value sent to seller)" : unit)
            in

            // Check that buyer owns the token
            let () = match Big_map.find_opt 0n edition_str.assets.ledger with
                    Some add -> (
                        if add = token_seller
                        then unit
                        else (failwith "Buy_fixed_price_token - Success : This test should pass (err: Wrong address to the token)" : unit) 
                    )
                |   None -> (failwith "Buy_fixed_price_token - Success : This test should pass (err: Token should have a value)" : unit)
            in
            "Passed"
        )   
    |   Fail (Rejected (_err, _)) -> failwith "Buy_fixed_price_token - Success : This test should pass"
    
    |   Fail _ -> failwith "Internal test failure"    


// Fail if seller not owner of token or token not in sale (same case)
let test_buy_fixed_price_token_fail_if_wrong_seller =
    let _, t_add,  fa2_add, _, admin = get_fixed_price_contract (false) in 
    
    let token_seller = Test.nth_bootstrap_account 3 in
    let () = Test.set_source token_seller in
    
    let contract = Test.to_contract t_add in

    let buyer = Test.nth_bootstrap_account 1 in
    let () = Test.set_source buyer in

    let result = Test.transfer_to_contract contract
        (Buy_fixed_price_token ({
            fa2_token = ({
                id = 0n;
                address = (fa2_add : address);
            } : fa2_base);
            seller = admin;
            receiver =buyer;
            referrer = (None : address option);
        })) 150000mutez
    in

    match result with
        Success _gas -> failwith "Buy_fixed_price_token - Seller is not for_sale owner : This test should fail"
    |   Fail (Rejected (err, _)) -> (
            let () = assert_with_error ( Test.michelson_equal err (Test.eval "TOKEN_IS_NOT_IN_SALE") ) "Buy_fixed_price_token - Seller is not for_sale owner : Should not work if seller is not owner" in
            "Passed"
        )
    |   Fail _ -> failwith "Internal test failure"    


let test_buy_fixed_price_token_success_secondary_commission = 
    let _, t_add, space, fa2_add, t_fa2_add, admin = get_fixed_price_contract_space (false, true) in 
    
    let token_minter = Test.nth_bootstrap_account 3 in
    let () = Test.set_source token_minter in
    
    let contract = Test.to_contract t_add in

    let _gas_creation_sale = Test.transfer_to_contract_exn contract
        (Create_sales ({
            sale_infos = [({
                commodity = (Tez (213210368547757mutez));
                buyer = None;
                fa2_token = {
                    address = (fa2_add : address);
                    id = 0n 
                };
            } : sale_info );]
        } : sale_configuration)) 0tez
    in

    let buyer = Test.nth_bootstrap_account 1 in
    let () = Test.set_source buyer in
    
    let _gas = Test.transfer_to_contract_exn contract
        (Buy_fixed_price_token ({
            fa2_token = ({
                id = 0n;
                address = (fa2_add : address);
            } : fa2_base);
            seller = token_minter;
            receiver =buyer;
            referrer = (None : address option);
      
        })) 213210368547757mutez
    in

    // Get balance of different actors of the sale to verify 
    // that fees and royalties are sent correctly
    

    let fee_account = Test.nth_bootstrap_account 2 in
    let fee_account_bal = Test.get_balance fee_account in
    
    let token_minter_bal = Test.get_balance token_minter in

    let token_split = Test.nth_bootstrap_account 5 in
    let token_split_bal = Test.get_balance token_split in

    let space_bal = Test.get_balance space in

    let second_buyer = Test.nth_bootstrap_account 9 in

    let _gas_creation_sale = Test.transfer_to_contract_exn contract
        (Create_sales ({
            sale_infos = [({
                commodity = (Tez (100tez));
                buyer = None;
                fa2_token = {
                    address = (fa2_add : address);
                    id = 0n 
                };
            } : sale_info );]
        } : sale_configuration)) 0tez
    in

    let () = Test.set_source second_buyer in
    let token_seller_bal = Test.get_balance buyer in

    let result = Test.transfer_to_contract contract
        (Buy_fixed_price_token ({
            fa2_token = ({
                id = 0n;
                address = (fa2_add : address);
            } : fa2_base);
            seller = buyer;
            receiver =second_buyer;
            referrer = (None : address option);
      
        })) 100tez
    in

    // To check the result of the edition storage account
    let edition_str = Test.get_storage t_fa2_add in
    // To check the result of the fixed price storage account
    let new_fp_str = Test.get_storage t_add in

    match result with
        Success _gas -> (
            // Check that sale is deleted from big map
            let sale_key : fa2_base * address = (
                {
                    address = (fa2_add : address);
                    id = 0n
                },
                admin
            ) in
            let () = match Big_map.find_opt sale_key new_fp_str.for_sale with
                    Some _ -> (failwith "Buy_fixed_price_token - Success : This test should pass (err: Token still for sale)" : unit)
                |   None -> unit
            in
            
            // Check that fees been transfer to fee address
            let new_fee_account_bal = Test.get_balance fee_account in
            let () =    if new_fee_account_bal - fee_account_bal = Some (3.5tez)
                        then unit
                        else (failwith "Buy_fixed_price_token - Success : This test should pass (err: Wrong percentage sent to fee address)" : unit)
            in

            // Check that 50% of the 15% royalties have been sent correctly to minter
            let new_minter_account_bal = Test.get_balance token_minter in
            let () =    if new_minter_account_bal - token_minter_bal = Some (7.5tez)
                        then unit
                        else (failwith "Buy_fixed_price_token - Success : This test should pass (err: Wrong percentage sent to minter address)" : unit)
            in

            // Admin 50% of the 15% royalties here
            let new_token_split_bal = Test.get_balance token_split in
            let () =    if new_token_split_bal - token_split_bal = Some (7.5tez)
                        then unit
                        else (failwith "Buy_fixed_price_token - Success : This test should pass (err: Wrong percentage sent to royaltie address)" : unit)
            in

            let new_space_bal = Test.get_balance space in
            let () =    if new_space_bal = space_bal
                        then unit
                        else (failwith "Buy_fixed_price_token - Success : This test should pass (err: Space should not get any commission on the secondary market)" : unit)
            in

            // Check that seller got the right amount
            let new_token_seller_bal = Test.get_balance buyer in
            let () =    if new_token_seller_bal - token_seller_bal = Some (81.5tez)
                        then unit
                        else (failwith "Buy_fixed_price_token - Success : This test should pass (err: Wrong value sent to seller)" : unit)
            in

            // Check that buyer owns the token
            let () = match Big_map.find_opt 0n edition_str.assets.ledger with
                    Some add -> (
                        if add = second_buyer
                        then unit
                        else (failwith "Buy_fixed_price_token - Success : This test should pass (err: Wrong address to the token)" : unit) 
                    )
                |   None -> (failwith "Buy_fixed_price_token - Success : This test should pass (err: Token should have a value)" : unit)
            in
            "Passed"
        )   
    |   Fail (Rejected (_err, _)) -> failwith "Buy_fixed_price_token - Success : This test should pass"
    
    |   Fail _ -> failwith "Internal test failure"    


// Fail if seller not owner of token or token not in sale (same case)
let test_buy_fixed_price_token_fail_if_wrong_seller =
    let _, t_add,  fa2_add, _, admin = get_fixed_price_contract (false) in 
    
    let token_seller = Test.nth_bootstrap_account 3 in
    let () = Test.set_source token_seller in
    
    let contract = Test.to_contract t_add in

    let buyer = Test.nth_bootstrap_account 1 in
    let () = Test.set_source buyer in

    let result = Test.transfer_to_contract contract
        (Buy_fixed_price_token ({
            fa2_token = ({
                id = 0n;
                address = (fa2_add : address);
            } : fa2_base);
            seller = admin;
            receiver =buyer;
            referrer = (None : address option);
        })) 150000mutez
    in

    match result with
        Success _gas -> failwith "Buy_fixed_price_token - Seller is not for_sale owner : This test should fail"
    |   Fail (Rejected (err, _)) -> (
            let () = assert_with_error ( Test.michelson_equal err (Test.eval "TOKEN_IS_NOT_IN_SALE") ) "Buy_fixed_price_token - Seller is not for_sale owner : Should not work if seller is not owner" in
            "Passed"
        )
    |   Fail _ -> failwith "Internal test failure"    


// Success - verify fa2 space transfer, fee & royalties, and referrer
let test_buy_fixed_price_token_success_commission_referrer =
    let _, t_add, space, fa2_add, t_fa2_add, admin = get_fixed_price_contract_space (false, true) in 
    
    let contract = Test.to_contract t_add in

    // Get balance of different actors of the sale to verify 
    // that fees and royalties are sent correctly
    let fee_account = Test.nth_bootstrap_account 2 in
    let fee_account_bal = Test.get_balance fee_account in
    
    let token_minter = Test.nth_bootstrap_account 3 in
    
    let token_split = Test.nth_bootstrap_account 5 in
    let token_split_bal = Test.get_balance token_split in

    let space_bal = Test.get_balance space in

    let () = Test.set_source token_minter in

    let _gas_creation_sale = Test.transfer_to_contract_exn contract
        (Create_sales ({
            sale_infos = [({
                commodity = (Tez (100tez));
                buyer = None;
                fa2_token = {
                    address = (fa2_add : address);
                    id = 0n 
                };
            } : sale_info );]
        } : sale_configuration)) 0tez
    in

    let token_minter_bal = Test.get_balance token_minter in

    let buyer = Test.nth_bootstrap_account 1 in
    let referrer = Test.nth_bootstrap_account 9 in
    let referrer_bal = Test.get_balance referrer in

    let () = Test.set_source buyer in

    let result = Test.transfer_to_contract contract
        (Buy_fixed_price_token ({
            fa2_token = ({
                id = 0n;
                address = (fa2_add : address);
            } : fa2_base);
            seller = token_minter;
            receiver =buyer;
            referrer = Some(referrer);
      
        })) 100tez
    in

    // To check the result of the edition storage account
    let edition_str = Test.get_storage t_fa2_add in
    // To check the result of the fixed price storage account
    let new_fp_str = Test.get_storage t_add in

    match result with
        Success _gas -> (
            // Check that sale is deleted from big map
            let sale_key : fa2_base * address = (
                {
                    address = (fa2_add : address);
                    id = 0n
                },
                admin
            ) in
            let () = match Big_map.find_opt sale_key new_fp_str.for_sale with
                    Some _ -> (failwith "Buy_fixed_price_token - Success : This test should pass (err: Token still for sale)" : unit)
                |   None -> unit
            in
            
            // Check that fees been transfer to referrer
            let new_referrer_bal = Test.get_balance referrer in
            let () =    if new_referrer_bal - referrer_bal = Some (1tez)
                        then unit
                        else (failwith "Buy_fixed_price_token - Success : This test should pass (err: Wrong percentage sent to fee address)" : unit)
            in
            
            // Check that fees been transfer to fee address
            let new_fee_account_bal = Test.get_balance fee_account in
            let () =    if new_fee_account_bal - fee_account_bal = Some (9tez)
                        then unit
                        else (failwith "Buy_fixed_price_token - Success : This test should pass (err: Wrong percentage sent to fee address)" : unit)
            in

            // Admin 50% of the 15% royalties here
            let new_token_split_bal = Test.get_balance token_split in
            let () =    if new_token_split_bal - token_split_bal = Some (7.5tez)
                        then unit
                        else (failwith "Buy_fixed_price_token - Success : This test should pass (err: Wrong percentage sent to royaltie address)" : unit)
            in

            let new_space_account_bal = Test.get_balance space in
            let () =    if new_space_account_bal - space_bal = Some (50tez)
                        then unit   
                        else (failwith "AcceptOffer - Success : This test should pass (err: Wrong percentage sent to commission address)" : unit)
            in

            // Check that seller got the right amount
            let new_token_minter_bal = Test.get_balance token_minter in
            let () =    if new_token_minter_bal - token_minter_bal = Some (32.5tez)
                        then unit
                        else (failwith "Buy_fixed_price_token - Success : This test should pass (err: Wrong value sent to seller)" : unit)
            in
                                    
            // Check that buyer owns the token
            let () = match Big_map.find_opt 0n edition_str.assets.ledger with
                    Some add -> (
                        if add = buyer
                        then unit
                        else (failwith "Buy_fixed_price_token - Success : This test should pass (err: Wrong address to the token)" : unit) 
                    )
                |   None -> (failwith "Buy_fixed_price_token - Success : This test should pass (err: Token should have a value)" : unit)
            in
            "Passed"
        )   
    |   Fail (Rejected (_err, _)) -> failwith "Buy_fixed_price_token - Success : This test should pass"    
    |   Fail err -> (
        let () = Test.log err in
        failwith "Internal test failure"        )


// Success - verify fa2 space transfer, fee & royalties, and referrer
let test_buy_fixed_price_token_success_commission_referrer_deactivated =
    let _, t_add, space, fa2_add, t_fa2_add, admin = get_fixed_price_contract_space (false, false) in 
    
    let contract = Test.to_contract t_add in

    // Get balance of different actors of the sale to verify 
    // that fees and royalties are sent correctly
    let fee_account = Test.nth_bootstrap_account 2 in
    let fee_account_bal = Test.get_balance fee_account in
    
    let token_minter = Test.nth_bootstrap_account 3 in
    
    let token_split = Test.nth_bootstrap_account 5 in
    let token_split_bal = Test.get_balance token_split in

    let space_bal = Test.get_balance space in

    let () = Test.set_source token_minter in

    let _gas_creation_sale = Test.transfer_to_contract_exn contract
        (Create_sales ({
            sale_infos = [({
                commodity = (Tez (100tez));
                buyer = None;
                fa2_token = {
                    address = (fa2_add : address);
                    id = 0n 
                };
            } : sale_info );]
        } : sale_configuration)) 0tez
    in

    let token_minter_bal = Test.get_balance token_minter in

    let buyer = Test.nth_bootstrap_account 1 in
    let referrer = Test.nth_bootstrap_account 9 in
    let referrer_bal = Test.get_balance referrer in

    let () = Test.set_source buyer in

    let result = Test.transfer_to_contract contract
        (Buy_fixed_price_token ({
            fa2_token = ({
                id = 0n;
                address = (fa2_add : address);
            } : fa2_base);
            seller = token_minter;
            receiver =buyer;
            referrer = Some(referrer);
      
        })) 100tez
    in

    // To check the result of the edition storage account
    let edition_str = Test.get_storage t_fa2_add in
    // To check the result of the fixed price storage account
    let new_fp_str = Test.get_storage t_add in

    match result with
        Success _gas -> (
            // Check that sale is deleted from big map
            let sale_key : fa2_base * address = (
                {
                    address = (fa2_add : address);
                    id = 0n
                },
                admin
            ) in
            let () = match Big_map.find_opt sale_key new_fp_str.for_sale with
                    Some _ -> (failwith "Buy_fixed_price_token - Success : This test should pass (err: Token still for sale)" : unit)
                |   None -> unit
            in
            
            // Check that fees been transfer to referrer
            let new_referrer_bal = Test.get_balance referrer in
            let () =    if new_referrer_bal - referrer_bal = Some (0tez)
                        then unit
                        else (failwith "Buy_fixed_price_token - Success : This test should pass (err: Wrong percentage sent to fee address)" : unit)
            in
            
            // Check that fees been transfer to fee address
            let new_fee_account_bal = Test.get_balance fee_account in
            let () =    if new_fee_account_bal - fee_account_bal = Some (10tez)
                        then unit
                        else (failwith "Buy_fixed_price_token - Success : This test should pass (err: Wrong percentage sent to fee address)" : unit)
            in

            // Admin 50% of the 15% royalties here
            let new_token_split_bal = Test.get_balance token_split in
            let () =    if new_token_split_bal - token_split_bal = Some (7.5tez)
                        then unit
                        else (failwith "Buy_fixed_price_token - Success : This test should pass (err: Wrong percentage sent to royaltie address)" : unit)
            in

            let new_space_account_bal = Test.get_balance space in
            let () =    if new_space_account_bal - space_bal = Some (50tez)
                        then unit   
                        else (failwith "AcceptOffer - Success : This test should pass (err: Wrong percentage sent to commission address)" : unit)
            in

            // Check that seller got the right amount
            let new_token_minter_bal = Test.get_balance token_minter in
            let () =    if new_token_minter_bal - token_minter_bal = Some (32.5tez)
                        then unit
                        else (failwith "Buy_fixed_price_token - Success : This test should pass (err: Wrong value sent to seller)" : unit)
            in
                                    
            // Check that buyer owns the token
            let () = match Big_map.find_opt 0n edition_str.assets.ledger with
                    Some add -> (
                        if add = buyer
                        then unit
                        else (failwith "Buy_fixed_price_token - Success : This test should pass (err: Wrong address to the token)" : unit) 
                    )
                |   None -> (failwith "Buy_fixed_price_token - Success : This test should pass (err: Token should have a value)" : unit)
            in
            "Passed"
        )   
    |   Fail (Rejected (_err, _)) -> failwith "Buy_fixed_price_token - Success : This test should pass"    
    |   Fail err -> (
        let () = Test.log err in
        failwith "Internal test failure"        )
