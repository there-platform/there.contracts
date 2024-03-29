#if SERIE_CONTRACT

type revoke_minting_param =
[@layout:comb]
{
  revoke: bool
}

(* Fails if sender is not admin *)
let fail_if_not_admin (storage : admin_storage) : unit =
  if Tezos.get_sender() <> storage.admin
  then failwith "NOT_AN_ADMIN"
  else unit

let fail_if_minting_revoked (storage : admin_storage) : unit =
  if storage.minting_revoked
  then failwith "MINTING_IS_REVOKED"
  else unit

#else

#if SPACE_CONTRACT

type admin_entrypoints =
    |   Send_admin_invitation of address
    |   Remove_admin_invitation of address
    |   Remove_admin of address
    |   Send_minter_invitation of address
    |   Remove_minter of address

let fail_if_sender_not_pending_minter (storage : admin_storage) :  unit =
    if Big_map.mem (Tezos.get_sender()) storage.pending_minters
    then unit
    else failwith "NOT_PENDING_MINTER"

let fail_if_sender_not_pending_admin (storage : admin_storage) :  unit =
    if Big_map.mem (Tezos.get_sender()) storage.pending_admins
    then unit
    else failwith "NOT_PENDING_ADMIN"

(* Fails if sender is not admin *)
let fail_if_not_admin (storage : admin_storage) : unit =
    if Big_map.mem (Tezos.get_sender()) storage.admins
    then unit
    else failwith "NOT_AN_ADMIN"

let fail_if_not_minter (add, storage : address * admin_storage) : unit =
    match (Big_map.find_opt add storage.minters ) with
            Some _minter -> unit
        |   None -> (failwith "NOT_A_MINTER" : unit)

let admin_main(param, storage : admin_entrypoints * admin_storage) : (operation list) * admin_storage =
    let () = fail_if_not_admin storage in 
    match param with
        |   Send_minter_invitation new_minter -> 
                if Big_map.mem new_minter storage.pending_minters
                then (failwith "INVITATION_ALREADY_SENT" : operation list * admin_storage)            
                else (
                    if Big_map.mem new_minter storage.minters then (failwith "ALREADY_MINTER" : operation list * admin_storage) 
                    else (([] : operation list), { storage with pending_minters = Big_map.add new_minter unit storage.pending_minters })
                )

        |   Remove_minter old_minter -> 
                ([]: operation list), { storage with pending_minters = Big_map.remove old_minter storage.pending_minters;  minters = Big_map.remove old_minter storage.minters }

        |   Send_admin_invitation new_admin ->
                if Big_map.mem new_admin storage.pending_admins
                then (failwith "INVITATION_ALREADY_SENT" : operation list * admin_storage)
                else (
                    if Big_map.mem new_admin storage.admins then (failwith "ALREADY_ADMIN" : operation list * admin_storage)
                    else (([] : operation list), { storage with pending_admins = Big_map.add new_admin unit storage.pending_admins})
            )

        |   Remove_admin_invitation add ->
            ([] : operation list), { storage with pending_admins = Big_map.remove add storage.pending_admins }

        |   Remove_admin add ->
            let () = assert_msg (add <> Tezos.get_sender(), "UNABLE_TO_REMOVE_YOURSELF") in
            ([] : operation list), { storage with admins = Big_map.remove add storage.admins}
            

#else

type proposal_param = 
[@layout:comb]
{
    proposal_id: nat
}

type admin_entrypoints =
    |   Pause_minting of bool
    |   Update_permission_manager of address
    |   Accept_proposals of proposal_param list
    |   Reject_proposals of proposal_param list

(* Fails if sender is not admin *)
let fail_if_not_admin (storage : admin_storage) : unit =
  match ((Tezos.call_view "is_admin" (Tezos.get_sender()) storage.permission_manager ): bool option) with
    None -> failwith "NOT_AN_ADMIN"
    | Some is_minter -> 
      if is_minter
      then unit
      else failwith "NOT_AN_ADMIN"

let fail_if_minting_paused (storage : admin_storage) : unit =
    if storage.paused_minting
    then failwith "MINTING_PAUSED"
    else unit

let fail_if_not_minter (storage : admin_storage) : unit =
    match ((Tezos.call_view "is_minter" (Tezos.get_sender()) storage.permission_manager ): bool option) with
        None -> failwith "NOT_A_MINTER"
        | Some is_minter -> 
            if is_minter
            then unit
            else failwith "NOT_A_MINTER"

let fail_if_already_minted (storage : editions_storage) : unit =
    if Big_map.mem (Tezos.get_sender()) storage.as_minted
    then failwith "ALREADY_MINTED"
    else unit

// Admin
let accept_proposals (accept_list, storage : proposal_param list * editions_storage ) : operation list * editions_storage =
    let accept_single_proposal : (editions_storage * proposal_param) -> editions_storage =
        fun (storage, param : editions_storage * proposal_param) -> (
            match Big_map.find_opt param.proposal_id storage.proposals with
                None -> (failwith "FA2_PROPOSAL_UNDEFINED"  : editions_storage)
            |   Some proposal -> (
                let new_proposal : proposal_metadata = { 
                    accepted = True;
                    minter = proposal.minter;
                    edition_info = proposal.edition_info;
                    license = proposal.license;
                    royalty = proposal.royalty;
                    splits = proposal.splits;
                    total_edition_number = 1n;
                } in
                
                { storage with proposals = Big_map.update param.proposal_id (Some new_proposal) storage.proposals; }
            )
        )
    in

    let new_storage = List.fold accept_single_proposal accept_list storage in
    ([] : operation list), new_storage

let reject_proposals (remove_list, storage : proposal_param list * editions_storage ) : operation list * editions_storage =
    let remove_single_proposal : (editions_storage * proposal_param) -> editions_storage =
        fun (storage, param : editions_storage * proposal_param) -> { storage with proposals = Big_map.remove param.proposal_id storage.proposals }
    in

    let new_storage = List.fold remove_single_proposal remove_list storage in
    ([] : operation list), new_storage

let admin_main(param, storage : admin_entrypoints * editions_storage) : (operation list) * editions_storage =
    let () = fail_if_not_admin storage.admin in 
    match param with
        |   Pause_minting paused ->
                (([]: operation list), { storage with admin.paused_minting = paused; })

        |   Update_permission_manager add ->
                (([] : operation list), { storage with admin.permission_manager = add; })

        |   Accept_proposals proposal_param ->
            accept_proposals (proposal_param, storage)
        
        |   Reject_proposals proposal_param ->
            reject_proposals (proposal_param, storage)

#endif
#endif
