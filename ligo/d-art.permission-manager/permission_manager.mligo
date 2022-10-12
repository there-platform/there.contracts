#include "interface.mligo"
#include "admin.mligo"

[@inline]
let assert_msg (condition, msg : bool * string ) : unit = if (not condition) then failwith(msg) else unit

type art_serie_factory = 
    |   Admin of admin_factory_entrypoints
    |   Accept_admin_invitation of admin_response_param

let permission_manager_main (param, storage : art_serie_factory * storage)  : (operation list) * storage = 
    let () : unit = assert_msg (Tezos.amount = 0mutez, "AMOUNT_SHOULD_BE_0TEZ") in
    match param with
        |   Admin a ->
                admin_main (a, storage)

        |   Accept_admin_invitation param ->
                let () : unit = fail_if_sender_not_pending_admin (storage) in
                if param.accept = true
                then ([] : operation list), { storage with admin.pending_admin = (None : address option); admin.admin = Tezos.sender }
                else ([] : operation list), { storage with admin.pending_admin = (None : address option) }