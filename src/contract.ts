require('dotenv').config()
import * as fs from 'fs';
import * as path from 'path';
import * as kleur from 'kleur';
import * as child from 'child_process';

import { loadFile } from './helper';
import { NFTStorage } from 'nft.storage';
import { char2Bytes } from '@taquito/tzip16';
import { Parser } from '@taquito/michel-codec';
import { InMemorySigner } from '@taquito/signer';
import { MichelsonMap, TezosToolkit } from '@taquito/taquito';

// -- View import

// Fa2 gallery originated
import {
    TokenMetadataViewGallery,
    RoyaltyDistributionViewGallery,
    SplitsViewGallery,
    RoyaltySplitsViewGallery,
    RoyaltyViewGallery,
    MinterViewGallery,
    IsTokenMinterViewGallery,
    CommissionSplitsViewGallery
} from './views/fa2_editions_gallery.tz';

// FA2 Legacy
import {
    TokenMetadataViewLegacy,
    RoyaltyDistributionViewLegacy,
    SplitsViewLegacy,
    RoyaltySplitsViewLegacy,
    RoyaltyViewLegacy,
    MinterViewLegacy,
    IsTokenMinterViewLegacy
} from './views/fa2_editions_legacy.tz';

// FA2 Serie
import {
    TokenMetadataViewSerie,
    RoyaltyDistributionViewSerie,
    SplitsViewRoyalty,
    RoyaltySplitsViewSerie,
    RoyaltyViewSerie,
    MinterViewSerie,
    IsTokenMinterViewSerie
} from './views/fa2_editions_serie.tz';


const client = new NFTStorage({
    token: process.env.NFT_STORAGE_KEY!,
})

export enum ContractAction {
    COMPILE = "compile contract",
    SIZE = "info measure-contract"
}

async function contractAction(contractName: string, action: ContractAction, pathString: string, mainFunction: string, compilePath?: string): Promise<void> {
    await new Promise<void>((resolve, reject) =>
        child.exec(
            path.join(__dirname, `../ligo/exec_ligo ${action} ` + path.join(__dirname, `../ligo/${pathString}`) + ` -e ${mainFunction}`),
            (err, stdout) => {
                if (err) {
                    console.log(kleur.red('Failed to compile the contract.'));
                    console.log(kleur.yellow().dim(err.toString()))
                    reject();
                } else {
                    // Write json contract into json file
                    if (action === ContractAction.COMPILE) {
                        console.log(kleur.green(`Compiled ${contractName} contract succesfully at: `))
                        console.log('  ' + path.join(__dirname, `../ligo/${compilePath}`))
                        fs.writeFileSync(path.join(__dirname, `../ligo/${compilePath}`), stdout)
                    }

                    if (action === ContractAction.SIZE) {
                        console.log(kleur.green(`Contract ${contractName} size: ${stdout}`))
                    }
                    resolve();
                }
            }
        )
    );
}

// -- Compile contracts --

export async function contracts(param: any, type: ContractAction): Promise<void> {
    switch (param.title) {
        case "fixed-price":
            contractAction("Fixed-price", type, "d-art.fixed-price/fixed_price_main.mligo", "fixed_price_main", "d-art.fixed-price/compile/fixed_price_main.tz")
            break;
        case "fa2-editions":
            contractAction("Fa2 editions", type, "d-art.fa2-editions/compile_fa2_editions.mligo", "editions_main --views 'token_metadata, royalty_distribution, splits, royalty_splits, royalty, minter, is_token_minter, is_unique_edition'", "d-art.fa2-editions/compile/multi_nft_token_editions.tz")
            break;
        case "fa2-editions-serie":
            contractAction("Fa2 editions serie", type, "d-art.fa2-editions/compile_fa2_editions_serie.mligo", "editions_main --views 'token_metadata, royalty_distribution, splits, royalty_splits, royalty, minter, is_token_minter, is_unique_edition'", "d-art.art-factories/compile/serie.tz")
            break;
        case "fa2-editions-gallery":
            contractAction("Fa2 editions gallery", type, "d-art.fa2-editions/compile_fa2_editions_gallery.mligo", "editions_main --views 'token_metadata, royalty_distribution, splits, royalty_splits, royalty, minter, is_token_minter, is_unique_edition, commission_splits'", "d-art.art-factories/compile/gallery.tz")
            break;
        case "serie-factory":
            contractAction("Serie factory", type, "d-art.art-factories/serie_factory.mligo", "serie_factory_main", "d-art.art-factories/compile/serie_factory.tz")
            break;
        case "gallery-factory":
            contractAction("Gallery factory", type, "d-art.art-factories/gallery_factory.mligo", "gallery_factory_main", "d-art.art-factories/compile/gallery_factory.tz")
            break;
        case "permission-manager":
            contractAction("Permission manager", type, "d-art.permission-manager/permission_manager.mligo", "permission_manager_main", "d-art.permission-manager/compile/permission_manager.tz")
            break;
        default:
            contractAction("Fixed-price", type, "d-art.fixed-price/fixed_price_main.mligo", "fixed_price_main", "d-art.fixed-price/compile/fixed_price_main.tz")
            contractAction("Fa2 editions", type, "d-art.fa2-editions/compile_fa2_editions.mligo", "editions_main --views 'token_metadata, royalty_distribution, splits, royalty_splits, royalty, minter, is_token_minter, is_unique_edition'", "d-art.fa2-editions/compile/multi_nft_token_editions.tz")
            contractAction("Fa2 editions factory", type, "d-art.fa2-editions/compile_fa2_editions_serie.mligo", "editions_main --views 'token_metadata, royalty_distribution, splits, royalty_splits, royalty, minter, is_token_minter, is_unique_edition'", "d-art.art-factories/compile/serie.tz")
            contractAction("Fa2 editions gallery", type, "d-art.fa2-editions/compile_fa2_editions_gallery.mligo", "editions_main --views 'token_metadata, royalty_distribution, splits, royalty_splits, royalty, minter, is_token_minter, is_unique_edition, commission_splits'", "d-art.art-factories/compile/gallery.tz")
            contractAction("Serie factory", type, "d-art.art-factories/serie_factory.mligo", "serie_factory_main", "d-art.art-factories/compile/serie_factory.tz")
            contractAction("Gallery factory", type, "d-art.art-factories/gallery_factory.mligo", "gallery_factory_main", "d-art.art-factories/compile/gallery_factory.tz")
            contractAction("Permission manager", type, "d-art.permission-manager/views.mligo", "permission_manager_main --views 'is_minter, is_gallery, is_admin'", "d-art.permission-manager/compile/permission_manager.tz")
            break;
    }
}

// -- Deploy contracts --

export async function deployFixedPriceContract(permissionManager: string): Promise<void> {
    const code = await loadFile(path.join(__dirname, '../ligo/d-art.fixed-price/compile/fixed_price_main.tz'))

    const fixed_price_contract_metadata = {
        name: 'A:RT - Marketplace (fixed price)',
        description: 'Marketplace contract in order to sell edition tokens.',
        authors: 'tz1KhMoukVbwDXRZ7EUuDm7K9K5EmJSGewxd',
        homepage: 'https://github.com/D-a-rt/d-art.contracts',
        license: "MIT",
        interfaces: ['TZIP-016'],
        imageUri: "ipfs://bafkreidnvjk6h7w7a6lp27t2tkmrzoqyjizedqnr5ojf525sm5jkfel2yy"
    }

    const contractMetadata = await client.storeBlob(
        new Blob([JSON.stringify(fixed_price_contract_metadata)]),
    )

    if (!contractMetadata) {
        console.log(kleur.red(`An error happened while uploading the ipfs metadata of the contract.`));
        return;
    }

    const originateParam = {
        code: code,
        storage: {
            admin: {
                permission_manager: permissionManager,
                pb_key: process.env.SIGNER_PUBLIC_KEY,
                signed_message_used: new MichelsonMap(),
                contract_will_update: false
            },
            for_sale: MichelsonMap.fromLiteral({}),
            drops: MichelsonMap.fromLiteral({}),
            fa2_sold: MichelsonMap.fromLiteral({}),
            fa2_dropped: MichelsonMap.fromLiteral({}),
            offers: MichelsonMap.fromLiteral({}),
            fee_primary: {
                address: process.env.ADMIN_PUBLIC_KEY_HASH,
                percent: 100,
            },
            fee_secondary: {
                address: process.env.ADMIN_PUBLIC_KEY_HASH,
                percent: 25,
            },
            stable_coin: MichelsonMap.fromLiteral({}),
            metadata: MichelsonMap.fromLiteral({
                "": char2Bytes(`ipfs://${contractMetadata}`),
            })
        }
    }

    try {
        const toolkit = await new TezosToolkit('https://ghostnet.ecadinfra.com');

        toolkit.setProvider({ signer: await InMemorySigner.fromSecretKey(process.env.ORIGINATOR_PRIVATE_KEY!) });

        const originationOp = await toolkit.contract.originate(originateParam);

        await originationOp.confirmation();
        const { address } = await originationOp.contract()

        console.log('Fixed price contract deployed at: ', address)

    } catch (error) {
        const jsonError = JSON.stringify(error);
        console.log(kleur.red(`Fixed price sale (tez) origination error ${jsonError}`));
    }
}

export async function deployEditionContract(permisionManagerAdd: string): Promise<void> {
    const code = await loadFile(path.join(__dirname, '../ligo/d-art.fa2-editions/compile/multi_nft_token_editions.tz'))

    const p = new Parser();

    const parsedSplitsMichelsonCode = p.parseMichelineExpression(SplitsViewLegacy.code);
    const parsedMinterMichelsonCode = p.parseMichelineExpression(MinterViewLegacy.code);
    const parsedRoyaltyMichelsonCode = p.parseMichelineExpression(RoyaltyViewLegacy.code);
    const parsedIsTokenMinterMichelsonCode = p.parseMichelineExpression(IsTokenMinterViewLegacy.code);
    const parsedRoyaltySplitsMichelsonCode = p.parseMichelineExpression(RoyaltySplitsViewLegacy.code);
    const parsedEditionMetadataMichelsonCode = p.parseMichelineExpression(TokenMetadataViewLegacy.code);
    const parsedRoyaltyDistributionMichelsonCode = p.parseMichelineExpression(RoyaltyDistributionViewLegacy.code);

    const editions_contract_metadata = {
        name: 'A:RT - Legacy',
        description: 'The lecgacy contract for D a:rt NFTs, is the genesis of A:RT tokens. Where all curated artist can create only one unique piece.',
        authors: 'tz1KhMoukVbwDXRZ7EUuDm7K9K5EmJSGewxd',
        homepage: 'https://github.com/D-a-rt/d-art.contracts',
        license: "MIT",
        interfaces: ['TZIP-012', 'TZIP-016'],
        imageUri: "ipfs://bafkreidnvjk6h7w7a6lp27t2tkmrzoqyjizedqnr5ojf525sm5jkfel2yy",
        views: [{
            name: 'token_metadata',
            description: 'Get the metadata for the tokens minted using this contract',
            pure: false,
            implementations: [
                {
                    michelsonStorageView:
                    {
                        parameter: {
                            prim: 'nat',
                        },
                        // (pair (nat %token_id) (map %token_info string bytes))
                        returnType: {
                            prim: "pair",
                            args: [
                                { prim: "nat", annots: ["%token_id"] },
                                { prim: "map", args: [{ prim: "string" }, { prim: "bytes" }], annots: ["%token_info"] },
                            ],
                        },
                        code: parsedEditionMetadataMichelsonCode,
                    },
                },
            ],
        }, {
            name: 'royalty_distribution',
            description: 'Get the minter of a specify token as well as the amount of royalty and the splits corresponding to it.',
            pure: true,
            implementations: [
                {
                    michelsonStorageView:
                    {
                        parameter: {
                            prim: 'nat',
                        },
                        // (pair address (pair (nat %royalty) (list %splits (pair (address %address) (nat %pct)))))
                        returnType: {
                            prim: "pair",
                            args: [
                                { prim: "address" },
                                {
                                    prim: "pair",
                                    args: [
                                        { prim: "nat", annots: ["%royalty"] },
                                        {
                                            prim: "list",
                                            args: [
                                                {
                                                    prim: "pair",
                                                    args: [
                                                        { prim: "address", annots: ["%address"] },
                                                        { prim: "nat", annots: ["%pct"] },
                                                    ]
                                                }
                                            ],
                                            annots: ["%splits"]
                                        },
                                    ]
                                },
                            ],
                        },
                        code: parsedRoyaltyDistributionMichelsonCode,
                    },
                },
            ],
        }, {
            name: 'splits',
            description: 'Get the splits for a token id.',
            pure: true,
            implementations: [
                {
                    michelsonStorageView:
                    {
                        parameter: {
                            prim: 'nat',
                        },
                        // (list (pair (address %address) (nat %pct)))
                        returnType: {
                            prim: "list",
                            args: [
                                {
                                    prim: "pair",
                                    args: [
                                        { prim: "address", annots: ["%address"] },
                                        { prim: "nat", annots: ["%pct"] },
                                    ]
                                }
                            ],
                            annots: ["%splits"]
                        },
                        code: parsedSplitsMichelsonCode,
                    },
                },
            ],
        }, {
            name: 'royalty_splits',
            description: 'Get the royalty and splits for a token id.',
            pure: true,
            implementations: [
                {
                    michelsonStorageView:
                    {
                        parameter: {
                            prim: 'nat',
                        },
                        // (pair (nat %royalty) (list %splits (pair (address %address) (nat %pct))))
                        returnType: {
                            prim: "pair",
                            args: [
                                { prim: "nat", annots: ["%royalty"] },
                                {
                                    prim: "list",
                                    args: [
                                        {
                                            prim: "pair",
                                            args: [
                                                { prim: "address", annots: ["%address"] },
                                                { prim: "nat", annots: ["%pct"] },
                                            ]
                                        }
                                    ],
                                    annots: ["%splits"]
                                },
                            ]
                        },
                        code: parsedRoyaltySplitsMichelsonCode,
                    },
                },
            ],
        }, {
            name: 'royalty',
            description: 'Get the royalty for a token id.',
            pure: true,
            implementations: [
                {
                    michelsonStorageView:
                    {
                        parameter: {
                            prim: 'nat',
                        },
                        // nat
                        returnType: {
                            prim: 'nat',
                        },
                        code: parsedRoyaltyMichelsonCode,
                    },
                },
            ],
        }, {
            name: 'minter',
            description: 'Get the minter for a token id.',
            pure: true,
            implementations: [
                {
                    michelsonStorageView:
                    {
                        parameter: {
                            prim: 'nat',
                        },
                        // nat
                        returnType: {
                            prim: 'address',
                        },
                        code: parsedMinterMichelsonCode,
                    },
                },
            ],
        }, {
            name: 'is_token_minter',
            description: 'Verify if address is minter on the contract.',
            pure: false,
            implementations: [
                {
                    michelsonStorageView:
                    {
                        parameter: {
                            prim: 'pair',
                            args: [
                                { prim: "address" },
                                { prim: "nat" }
                            ]
                        },
                        // nat
                        returnType: {
                            prim: 'bool',
                        },
                        code: parsedIsTokenMinterMichelsonCode,
                    },
                },
            ],
        }],
    };

    const contractMetadata = await client.storeBlob(
        new Blob([JSON.stringify(editions_contract_metadata)]),
    )

    if (!contractMetadata) {
        console.log(kleur.red(`An error happened while uploading the ipfs metadata of the contract.`));
        return;
    }

    const originateParam = {
        code: code,
        storage: {
            next_token_id: 0,
            max_editions_per_run: 1,
            as_minted: MichelsonMap.fromLiteral({}),
            proposals: MichelsonMap.fromLiteral({}),
            editions_metadata: MichelsonMap.fromLiteral({}),
            assets: {
                ledger: MichelsonMap.fromLiteral({}),
                operators: MichelsonMap.fromLiteral({}),
                token_metadata: MichelsonMap.fromLiteral({})
            },
            admin: {
                pause_minting: false,
                permission_manager: permisionManagerAdd,
            },
            metadata: MichelsonMap.fromLiteral({
                "": char2Bytes(`ipfs://${contractMetadata}`),
                "symbol": "A:RT"
            })
        }
    }

    try {
        const toolkit = await new TezosToolkit('https://ghostnet.ecadinfra.com');

        toolkit.setProvider({ signer: await InMemorySigner.fromSecretKey(process.env.ORIGINATOR_PRIVATE_KEY!) });


        const originationOp = await toolkit.contract.originate(originateParam);

        await originationOp.confirmation();
        const { address } = await originationOp.contract()

        console.log('Edition FA2 contract deployed at: ', address)

    } catch (error) {
        const jsonError = JSON.stringify(error);
        console.log(kleur.red(`Edition FA2 origination error ${jsonError}`));
    }
}

export async function deploySerieFactory(permisionManagerAdd: string): Promise<void> {
    const code = await loadFile(path.join(__dirname, '../ligo/d-art.art-factories/compile/serie_factory.tz'))

    const serieFactoryMetadata = {
        name: 'A:RT - Serie Factory',
        description: 'This contract is responsible to originate series for authorized artists on D a:rt.',
        authors: 'tz1KhMoukVbwDXRZ7EUuDm7K9K5EmJSGewxd',
        homepage: 'https://github.com/D-a-rt/d-art.contracts',
        license: "MIT",
        interfaces: ['TZIP-016']
    }

    const contractMetadata = await client.storeBlob(
        new Blob([JSON.stringify(serieFactoryMetadata)]),
    )

    if (!contractMetadata) {
        console.log(kleur.red(`An error happened while uploading the ipfs metadata of the contract.`));
        return;
    }

    const originateParam = {
        code: code,
        storage: {
            admin: "tz1KhMoukVbwDXRZ7EUuDm7K9K5EmJSGewxd",
            permission_manager: permisionManagerAdd,
            series: MichelsonMap.fromLiteral({}),
            metadata: MichelsonMap.fromLiteral({
                "": char2Bytes(`ipfs://${contractMetadata}`),
            }),
            next_serie_id: 0
        }
    }

    try {
        const toolkit = await new TezosToolkit('https://ghostnet.ecadinfra.com');

        toolkit.setProvider({ signer: await InMemorySigner.fromSecretKey(process.env.ORIGINATOR_PRIVATE_KEY!) });


        const originationOp = await toolkit.contract.originate(originateParam);

        await originationOp.confirmation();
        const { address } = await originationOp.contract()

        console.log('Serie Factory contract deployed at: ', address)

    } catch (error) {
        const jsonError = JSON.stringify(error);
        console.log(kleur.red(`Serie Factory origination error ${jsonError}`));
    }
}

export async function deployGalleryFactory(permisionManagerAdd: string): Promise<void> {
    const code = await loadFile(path.join(__dirname, '../ligo/d-art.art-factories/compile/gallery_factory.tz'))

    const galleryFactoryMetadata = {
        name: 'A:RT - Gallery Factory',
        description: 'This contract is responsible to originate new gallery contract to let them the possibilities to curate artists and create NFTs in collaboration with them on the D a:rt platform.',
        authors: 'tz1KhMoukVbwDXRZ7EUuDm7K9K5EmJSGewxd',
        homepage: 'https://github.com/D-a-rt/d-art.contracts',
        license: "MIT",
        interfaces: ['TZIP-016']
    }

    const contractMetadata = await client.storeBlob(
        new Blob([JSON.stringify(galleryFactoryMetadata)]),
    )

    if (!contractMetadata) {
        console.log(kleur.red(`An error happened while uploading the ipfs metadata of the contract.`));
        return;
    }

    const originateParam = {
        code: code,
        storage: {
            permission_manager: permisionManagerAdd,
            galleries: MichelsonMap.fromLiteral({}),
            metadata: MichelsonMap.fromLiteral({
                "": char2Bytes(`ipfs://${contractMetadata}`),
            })
        }
    }

    try {
        const toolkit = await new TezosToolkit('https://ghostnet.ecadinfra.com');

        toolkit.setProvider({ signer: await InMemorySigner.fromSecretKey(process.env.ORIGINATOR_PRIVATE_KEY!) });


        const originationOp = await toolkit.contract.originate(originateParam);

        await originationOp.confirmation();
        const { address } = await originationOp.contract()

        console.log('Gallery Factory contract deployed at: ', address)

    } catch (error) {
        const jsonError = JSON.stringify(error);
        console.log(kleur.red(`Gallery Factory origination error ${jsonError}`));
    }
}

export async function deployPermissionManager(): Promise<string | undefined> {
    const code = await loadFile(path.join(__dirname, '../ligo/d-art.permission-manager/compile/permission_manager.tz'))

    const permissionManagerMetadata = {
        name: 'A:RT - Permission Manager',
        description: 'This contract is responsible to manage access to the D A:RT system.',
        authors: 'tz1KhMoukVbwDXRZ7EUuDm7K9K5EmJSGewxd',
        homepage: 'https://github.com/D-a-rt/d-art.contracts',
        license: "MIT",
        interfaces: ['TZIP-016']
    }

    const contractMetadata = await client.storeBlob(
        new Blob([JSON.stringify(permissionManagerMetadata)]),
    )

    if (!contractMetadata) {
        console.log(kleur.red(`An error happened while uploading the ipfs metadata of the contract.`));
        throw Error('Unable to upload data to ipfs')
    }

    const originateParam = {
        code: code,
        storage: {
            admin_str: {
                admin: "tz1KhMoukVbwDXRZ7EUuDm7K9K5EmJSGewxd",
                pending_admin: null,
            },
            minters: MichelsonMap.fromLiteral({}),
            galleries: MichelsonMap.fromLiteral({}),
            metadata: MichelsonMap.fromLiteral({
                "": char2Bytes(`ipfs://${contractMetadata}`),
            })
        }
    }

    try {
        const toolkit = await new TezosToolkit('https://ghostnet.ecadinfra.com');

        toolkit.setProvider({ signer: await InMemorySigner.fromSecretKey(process.env.ORIGINATOR_PRIVATE_KEY!) });


        const originationOp = await toolkit.contract.originate(originateParam);

        await originationOp.confirmation();
        const { address } = await originationOp.contract()

        console.log('Permission manager contract deployed at: ', address)
        return address
    } catch (error) {
        const jsonError = JSON.stringify(error);
        console.log(kleur.red(`Permission manager origination error ${jsonError}`));
    }
}

export const deployContracts = async (param: any) => {
    switch (param.title) {
        case "fixed-price":
            if (param.permissionManager) await deployFixedPriceContract(param.permissionManager)
            break;
        case "fa2-editions":
            if (param.permissionManager) await deployEditionContract(param.permissionManager)
            break;
        case "serie-factory":
            if (param.permissionManager) await deploySerieFactory(param.permissionManager)
            break;
        case "gallery-factory":
            console.log(param.permissionManager)
            if (param.permissionManager) await deployGalleryFactory(param.permissionManager)
            break;
        case "permission-manager":
            await deployPermissionManager()
            break;
        default:
            const permissionManagerAdd = await deployPermissionManager()
            if (permissionManagerAdd) await deployEditionContract(permissionManagerAdd)
            if (permissionManagerAdd) await deployFixedPriceContract(permissionManagerAdd)
            if (permissionManagerAdd) await deploySerieFactory(permissionManagerAdd)
            if (permissionManagerAdd) await deployGalleryFactory(permissionManagerAdd)
            break;
    }
}

// -- Tests --

async function testFixedPriceContract(): Promise<void> {
    await new Promise<void>((resolve, reject) => {
        console.log(kleur.green(`Testing admin entrypoints...`))

        child.exec(
            path.join(__dirname, `../ligo/exec_ligo run test ${path.join(__dirname, "../ligo/test/d-art.fixed-price/admin_main.test.mligo")}`),
            (err, stdout) => {
                if (err) {
                    console.log(kleur.red('Failed to run tests.'));
                    console.log(kleur.yellow().dim(err.toString()))
                    reject();
                } else {
                    console.log(`Results: ${stdout}`)
                    resolve()
                }
            }
        )
    })

    await new Promise<void>((resolve, reject) => {
        console.log(kleur.green(`Testing fixed_price_sale entrypoints...`))

        child.exec(
            path.join(__dirname, `../ligo/exec_ligo run test ${path.join(__dirname, "../ligo/test/d-art.fixed-price/fixed_price_main_sale.test.mligo")}`),
            (err, stdout) => {
                if (err) {
                    console.log(kleur.red('Failed to run tests.'));
                    console.log(kleur.yellow().dim(err.toString()))
                    reject();
                } else {
                    console.log(`Results: ${stdout}`)
                    resolve()
                }
            }
        )
    })

    await new Promise<void>((resolve, reject) => {
        console.log(kleur.green(`Testing fixed_price_drop entrypoints...`))

        child.exec(
            path.join(__dirname, `../ligo/exec_ligo run test ${path.join(__dirname, "../ligo/test/d-art.fixed-price/fixed_price_main_drop.test.mligo")}`),
            (err, stdout) => {
                if (err) {
                    console.log(kleur.red('Failed to run tests.'));
                    console.log(kleur.yellow().dim(err.toString()))
                    reject();
                } else {
                    console.log(`Results: ${stdout}`)
                    resolve()
                }
            }
        )
    })

    await new Promise<void>((resolve, reject) => {
        console.log(kleur.green(`Testing buy_fixed_price entrypoints...`))

        child.exec(
            path.join(__dirname, `../ligo/exec_ligo run test ${path.join(__dirname, "../ligo/test/d-art.fixed-price/fixed_price_main_buy_sale.test.mligo")}`),
            (err, stdout) => {
                if (err) {
                    console.log(kleur.red('Failed to run tests.'));
                    console.log(kleur.yellow().dim(err.toString()))
                    reject();
                } else {
                    console.log(`Results: ${stdout}`)
                    resolve()
                }
            }
        )
    })

    await new Promise<void>((resolve, reject) => {
        console.log(kleur.green(`Testing buy_dropped entrypoints...`))

        child.exec(
            path.join(__dirname, `../ligo/exec_ligo run test ${path.join(__dirname, "../ligo/test/d-art.fixed-price/fixed_price_main_buy_drop.test.mligo")}`),
            (err, stdout) => {
                if (err) {
                    console.log(kleur.red('Failed to run tests.'));
                    console.log(kleur.yellow().dim(err.toString()))
                    reject();
                } else {
                    console.log(`Results: ${stdout}`)
                    resolve()
                }
            }
        )
    })
}

async function testEditionContract(): Promise<void> {
    await new Promise<void>((resolve, reject) => {
        console.log(kleur.green(`Testing fa2 admin entrypoints...`))

        child.exec(
            path.join(__dirname, `../ligo/exec_ligo run test ${path.join(__dirname, "../ligo/test/d-art.fa2-editions/admin.test.mligo")}`),
            (err, stdout) => {
                if (err) {
                    console.log(kleur.red('Failed to run tests.'));
                    console.log(kleur.yellow().dim(err.toString()))

                } else {
                    console.log(`Results: ${stdout}`)
                    resolve()
                }
            }
        )
    })

    await new Promise<void>((resolve, reject) => {
        console.log(kleur.green(`Testing fa2 operator entrypoints...`))

        child.exec(
            path.join(__dirname, `../ligo/exec_ligo run test ${path.join(__dirname, "../ligo/test/d-art.fa2-editions/operator_lib.test.mligo")}`),
            (err, stdout) => {
                if (err) {
                    console.log(kleur.red('Failed to run tests.'));
                    console.log(kleur.yellow().dim(err.toString()))
                    reject();
                } else {
                    console.log(`Results: ${stdout}`)
                    resolve()
                }
            }
        )
    })

    await new Promise<void>((resolve, reject) => {
        console.log(kleur.green(`Testing fa2 standard entrypoints...`))

        child.exec(
            path.join(__dirname, `../ligo/exec_ligo run test ${path.join(__dirname, "../ligo/test/d-art.fa2-editions/standard.test.mligo")}`),
            (err, stdout) => {
                if (err) {
                    console.log(kleur.red('Failed to run tests.'));
                    console.log(kleur.yellow().dim(err.toString()))
                    reject();
                } else {
                    console.log(`Results: ${stdout}`)
                    resolve()
                }
            }
        )
    })

    await new Promise<void>((resolve, reject) => {
        console.log(kleur.green(`Testing fa2 main (mint and burn) entrypoints for fa2_editions...`))

        child.exec(
            path.join(__dirname, `../ligo/exec_ligo run test ${path.join(__dirname, "../ligo/test/d-art.fa2-editions/fa2_editions.test.mligo")}`),
            (err, stdout) => {
                if (err) {
                    console.log(kleur.red('Failed to run tests.'));
                    console.log(kleur.yellow().dim(err.toString()))
                    reject();
                } else {
                    console.log(`Results: ${stdout}`)
                    resolve()
                }
            }
        )
    })

    await new Promise<void>((resolve, reject) => {
        console.log(kleur.green(`Testing fa2 main (mint and burn) entrypoints for fa2_editions_serie...`))

        child.exec(
            path.join(__dirname, `../ligo/exec_ligo run test ${path.join(__dirname, "../ligo/test/d-art.fa2-editions/fa2_editions_serie.test.mligo")}`),
            (err, stdout) => {
                if (err) {
                    console.log(kleur.red('Failed to run tests.'));
                    console.log(kleur.yellow().dim(err.toString()))
                    reject();
                } else {
                    console.log(`Results: ${stdout}`)
                    resolve()
                }
            }
        )
    })

    await new Promise<void>((resolve, reject) => {
        console.log(kleur.green(`Testing fa2 main (mint and burn) entrypoints for fa2_editions_gallery...`))

        child.exec(
            path.join(__dirname, `../ligo/exec_ligo run test ${path.join(__dirname, "../ligo/test/d-art.fa2-editions/fa2_editions_gallery.test.mligo")}`),
            (err, stdout) => {
                if (err) {
                    console.log(kleur.red('Failed to run tests.'));
                    console.log(kleur.yellow().dim(err.toString()))
                    reject();
                } else {
                    console.log(`Results: ${stdout}`)
                    resolve()
                }
            }
        )
    })

    await new Promise<void>((resolve, reject) => {
        console.log(kleur.green(`Testing fa2 views entrypoints...`))

        child.exec(
            path.join(__dirname, `../ligo/exec_ligo run test ${path.join(__dirname, "../ligo/test/d-art.fa2-editions/views.test.mligo")}`),
            (err, stdout) => {
                if (err) {
                    console.log(kleur.red('Failed to run tests.'));
                    console.log(kleur.yellow().dim(err.toString()))
                    reject();
                } else {
                    console.log(`Results: ${stdout}`)
                    resolve()
                }
            }
        )
    })
}

async function testSerieFactoryContract(): Promise<void> {

    await new Promise<void>((resolve, reject) => {
        console.log(kleur.green(`Testing serie factory main entrypoints...`))

        child.exec(
            path.join(__dirname, `../ligo/exec_ligo run test ${path.join(__dirname, "../ligo/test/d-art.art-factories/serie_factory_main.test.mligo")}`),
            (err, stdout) => {
                if (err) {
                    console.log(kleur.red('Failed to run tests.'));
                    console.log(kleur.yellow().dim(err.toString()))
                    reject();
                } else {
                    console.log(`Results: ${stdout}`)
                    resolve()
                }
            }
        )
    })
}

async function testGalleryFactoryContract(): Promise<void> {
    await new Promise<void>((resolve, reject) => {
        console.log(kleur.green(`Testing gallery factory main entrypoints...`))

        child.exec(
            path.join(__dirname, `../ligo/exec_ligo run test ${path.join(__dirname, "../ligo/test/d-art.art-factories/gallery_factory_main.test.mligo")}`),
            (err, stdout) => {
                if (err) {
                    console.log(kleur.red('Failed to run tests.'));
                    console.log(kleur.yellow().dim(err.toString()))
                    reject();
                } else {
                    console.log(`Results: ${stdout}`)
                    resolve()
                }
            }
        )
    })
}

async function testPermissionManagerContract(): Promise<void> {

    await new Promise<void>((resolve, reject) => {
        console.log(kleur.green(`Testing permission manager main entrypoints...`))

        child.exec(
            path.join(__dirname, `../ligo/exec_ligo run test ${path.join(__dirname, "../ligo/test/d-art.permission-manager/permission_manager.test.mligo")}`),
            (err, stdout) => {
                if (err) {
                    console.log(kleur.red('Failed to run tests.'));
                    console.log(kleur.yellow().dim(err.toString()))
                    reject();
                } else {
                    console.log(`Results: ${stdout}`)
                    resolve()
                }
            }
        )
    })

    await new Promise<void>((resolve, reject) => {
        console.log(kleur.green(`Testing permission manager views entrypoints...`))

        child.exec(
            path.join(__dirname, `../ligo/exec_ligo run test ${path.join(__dirname, "../ligo/test/d-art.permission-manager/views.test.mligo")}`),
            (err, stdout) => {
                if (err) {
                    console.log(kleur.red('Failed to run tests.'));
                    console.log(kleur.yellow().dim(err.toString()))
                    reject();
                } else {
                    console.log(`Results: ${stdout}`)
                    resolve()
                }
            }
        )
    })
}

export const testContracts = async (param: any) => {
    switch (param.title) {
        case "fixed-price":
            await testFixedPriceContract()
            break;
        case "fa2-editions":
            await testEditionContract()
            break;
        case "serie-factory":
            await testSerieFactoryContract()
            break;
        case "gallery-factory":
            await testGalleryFactoryContract()
            break;
        case "permission-manager":
            await testPermissionManagerContract()
            break;
        default:
            console.log(kleur.magenta(`Testing editions contracts:`))
            console.log(kleur.magenta(` `))
            await testEditionContract()
            console.log(kleur.magenta(`Testing fixed price contracts:`))
            console.log(kleur.magenta(` `))
            await testFixedPriceContract()
            console.log(kleur.magenta(`Testing serie factory contracts:`))
            console.log(kleur.magenta(` `))
            await testSerieFactoryContract()
            console.log(kleur.magenta(`Testing gallery factory contracts:`))
            console.log(kleur.magenta(` `))
            await testGalleryFactoryContract()
            console.log(kleur.magenta(`Testing permission manager contracts:`))
            console.log(kleur.magenta(` `))
            await testPermissionManagerContract()
            break;
    }
}

// Example metadata upload for Legacy contracts
export const uploadContractMetadataLegacy = async () => {

    const p = new Parser();

    const parsedSplitsMichelsonCode = p.parseMichelineExpression(SplitsViewLegacy.code);
    const parsedMinterMichelsonCode = p.parseMichelineExpression(MinterViewLegacy.code);
    const parsedRoyaltyMichelsonCode = p.parseMichelineExpression(RoyaltyViewLegacy.code);
    const parsedIsTokenMinterMichelsonCode = p.parseMichelineExpression(IsTokenMinterViewLegacy.code);
    const parsedRoyaltySplitsMichelsonCode = p.parseMichelineExpression(RoyaltySplitsViewLegacy.code);
    const parsedEditionMetadataMichelsonCode = p.parseMichelineExpression(TokenMetadataViewLegacy.code);
    const parsedRoyaltyDistributionMichelsonCode = p.parseMichelineExpression(RoyaltyDistributionViewLegacy.code);

    const editions_contract_metadata = {
        name: 'A:RT - Legacy',
        description: 'The lecgacy contract for D a:rt NFTs, is the genesis of A:RT tokens. Where all curated artist can create only one unique piece.',
        authors: 'tz1KhMoukVbwDXRZ7EUuDm7K9K5EmJSGewxd',
        interfaces: ['TZIP-012', 'TZIP-016'],
        imageUri: "ipfs://QmUxNNqSrsDK5JLk42u2iwwFkP8osFM2pcfYRuEZKsmwrL",
        imageUriSvg: true, // Or false if not
        headerLogo: "ipfs://Qmf4LS9HgwYSWVq73AL1HVaaeW1s44qJvZuUDJkVyTEKze",
        headerLogoSvg: true, // Or false if not
        views: [{
            name: 'token_metadata',
            description: 'Get the metadata for the tokens minted using this contract',
            pure: false,
            implementations: [
                {
                    michelsonStorageView:
                    {
                        parameter: {
                            prim: 'nat',
                        },
                        // (pair (nat %token_id) (map %token_info string bytes))
                        returnType: {
                            prim: "pair",
                            args: [
                                { prim: "nat", annots: ["%token_id"] },
                                { prim: "map", args: [{ prim: "string" }, { prim: "bytes" }], annots: ["%token_info"] },
                            ],
                        },
                        code: parsedEditionMetadataMichelsonCode,
                    },
                },
            ],
        }, {
            name: 'royalty_distribution',
            description: 'Get the minter of a specify token as well as the amount of royalty and the splits corresponding to it.',
            pure: true,
            implementations: [
                {
                    michelsonStorageView:
                    {
                        parameter: {
                            prim: 'nat',
                        },
                        // (pair address (pair (nat %royalty) (list %splits (pair (address %address) (nat %pct)))))
                        returnType: {
                            prim: "pair",
                            args: [
                                { prim: "address" },
                                {
                                    prim: "pair",
                                    args: [
                                        { prim: "nat", annots: ["%royalty"] },
                                        {
                                            prim: "list",
                                            args: [
                                                {
                                                    prim: "pair",
                                                    args: [
                                                        { prim: "address", annots: ["%address"] },
                                                        { prim: "nat", annots: ["%pct"] },
                                                    ]
                                                }
                                            ],
                                            annots: ["%splits"]
                                        },
                                    ]
                                },
                            ],
                        },
                        code: parsedRoyaltyDistributionMichelsonCode,
                    },
                },
            ],
        }, {
            name: 'splits',
            description: 'Get the splits for a token id.',
            pure: true,
            implementations: [
                {
                    michelsonStorageView:
                    {
                        parameter: {
                            prim: 'nat',
                        },
                        // (list (pair (address %address) (nat %pct)))
                        returnType: {
                            prim: "list",
                            args: [
                                {
                                    prim: "pair",
                                    args: [
                                        { prim: "address", annots: ["%address"] },
                                        { prim: "nat", annots: ["%pct"] },
                                    ]
                                }
                            ],
                            annots: ["%splits"]
                        },
                        code: parsedSplitsMichelsonCode,
                    },
                },
            ],
        }, {
            name: 'royalty_splits',
            description: 'Get the royalty and splits for a token id.',
            pure: true,
            implementations: [
                {
                    michelsonStorageView:
                    {
                        parameter: {
                            prim: 'nat',
                        },
                        // (pair (nat %royalty) (list %splits (pair (address %address) (nat %pct))))
                        returnType: {
                            prim: "pair",
                            args: [
                                { prim: "nat", annots: ["%royalty"] },
                                {
                                    prim: "list",
                                    args: [
                                        {
                                            prim: "pair",
                                            args: [
                                                { prim: "address", annots: ["%address"] },
                                                { prim: "nat", annots: ["%pct"] },
                                            ]
                                        }
                                    ],
                                    annots: ["%splits"]
                                },
                            ]
                        },
                        code: parsedRoyaltySplitsMichelsonCode,
                    },
                },
            ],
        }, {
            name: 'royalty',
            description: 'Get the royalty for a token id.',
            pure: true,
            implementations: [
                {
                    michelsonStorageView:
                    {
                        parameter: {
                            prim: 'nat',
                        },
                        // nat
                        returnType: {
                            prim: 'nat',
                        },
                        code: parsedRoyaltyMichelsonCode,
                    },
                },
            ],
        }, {
            name: 'minter',
            description: 'Get the minter for a token id.',
            pure: true,
            implementations: [
                {
                    michelsonStorageView:
                    {
                        parameter: {
                            prim: 'nat',
                        },
                        // nat
                        returnType: {
                            prim: 'address',
                        },
                        code: parsedMinterMichelsonCode,
                    },
                },
            ],
        }, {
            name: 'is_token_minter',
            description: 'Verify if address is minter on the contract.',
            pure: false,
            implementations: [
                {
                    michelsonStorageView:
                    {
                        parameter: {
                            prim: 'pair',
                            args: [
                                { prim: "address" },
                                { prim: "nat" }
                            ]
                        },
                        // nat
                        returnType: {
                            prim: 'bool',
                        },
                        code: parsedIsTokenMinterMichelsonCode,
                    },
                },
            ],
        }],
    };

    const contractMetadata = await client.storeBlob(
        new Blob([JSON.stringify(editions_contract_metadata)]),
    )

    if (!contractMetadata) {
        console.log(kleur.red(`An error happened while uploading the ipfs metadata of the contract.`));
        return;
    }

    console.log(contractMetadata)
}

// Example metadata upload for serie factory generated contracts
export const uploadContractMetadataSerie = async () => {

    const p = new Parser();

    const parsedSplitsMichelsonCode = p.parseMichelineExpression(SplitsViewRoyalty.code);
    const parsedMinterMichelsonCode = p.parseMichelineExpression(MinterViewSerie.code);
    const parsedRoyaltyMichelsonCode = p.parseMichelineExpression(RoyaltyViewSerie.code);
    const parsedIsTokenMinterMichelsonCode = p.parseMichelineExpression(IsTokenMinterViewSerie.code);
    const parsedRoyaltySplitsMichelsonCode = p.parseMichelineExpression(RoyaltySplitsViewSerie.code);
    const parsedEditionMetadataMichelsonCode = p.parseMichelineExpression(TokenMetadataViewSerie.code);
    const parsedRoyaltyDistributionMichelsonCode = p.parseMichelineExpression(RoyaltyDistributionViewSerie.code);

    const editions_contract_metadata = {
        name: 'A:RT Gallery',
        description: 'We present work across all media including painting, drawing, sculpture, installation, photography and video and we seek to cultivate the lineages that run between emerging and established artists.',
        authors: 'tz1KhMoukVbwDXRZ7EUuDm7K9K5EmJSGewxd',
        interfaces: ['TZIP-012', 'TZIP-016'],
        imageUri: "ipfs://QmUxNNqSrsDK5JLk42u2iwwFkP8osFM2pcfYRuEZKsmwrL",
        views: [{
            name: 'token_metadata',
            description: 'Get the metadata for the tokens minted using this contract',
            pure: false,
            implementations: [
                {
                    michelsonStorageView:
                    {
                        parameter: {
                            prim: 'nat',
                        },
                        // (pair (nat %token_id) (map %token_info string bytes))
                        returnType: {
                            prim: "pair",
                            args: [
                                { prim: "nat", annots: ["%token_id"] },
                                { prim: "map", args: [{ prim: "string" }, { prim: "bytes" }], annots: ["%token_info"] },
                            ],
                        },
                        code: parsedEditionMetadataMichelsonCode,
                    },
                },
            ],
        }, {
            name: 'royalty_distribution',
            description: 'Get the minter of a specify token as well as the amount of royalty and the splits corresponding to it.',
            pure: true,
            implementations: [
                {
                    michelsonStorageView:
                    {
                        parameter: {
                            prim: 'nat',
                        },
                        // (pair address (pair (nat %royalty) (list %splits (pair (address %address) (nat %pct)))))
                        returnType: {
                            prim: "pair",
                            args: [
                                { prim: "address" },
                                {
                                    prim: "pair",
                                    args: [
                                        { prim: "nat", annots: ["%royalty"] },
                                        {
                                            prim: "list",
                                            args: [
                                                {
                                                    prim: "pair",
                                                    args: [
                                                        { prim: "address", annots: ["%address"] },
                                                        { prim: "nat", annots: ["%pct"] },
                                                    ]
                                                }
                                            ],
                                            annots: ["%splits"]
                                        },
                                    ]
                                },
                            ],
                        },
                        code: parsedRoyaltyDistributionMichelsonCode,
                    },
                },
            ],
        }, {
            name: 'splits',
            description: 'Get the splits for a token id.',
            pure: true,
            implementations: [
                {
                    michelsonStorageView:
                    {
                        parameter: {
                            prim: 'nat',
                        },
                        // (list (pair (address %address) (nat %pct)))
                        returnType: {
                            prim: "list",
                            args: [
                                {
                                    prim: "pair",
                                    args: [
                                        { prim: "address", annots: ["%address"] },
                                        { prim: "nat", annots: ["%pct"] },
                                    ]
                                }
                            ],
                            annots: ["%splits"]
                        },
                        code: parsedSplitsMichelsonCode,
                    },
                },
            ],
        }, {
            name: 'royalty_splits',
            description: 'Get the royalty and splits for a token id.',
            pure: true,
            implementations: [
                {
                    michelsonStorageView:
                    {
                        parameter: {
                            prim: 'nat',
                        },
                        // (pair (nat %royalty) (list %splits (pair (address %address) (nat %pct))))
                        returnType: {
                            prim: "pair",
                            args: [
                                { prim: "nat", annots: ["%royalty"] },
                                {
                                    prim: "list",
                                    args: [
                                        {
                                            prim: "pair",
                                            args: [
                                                { prim: "address", annots: ["%address"] },
                                                { prim: "nat", annots: ["%pct"] },
                                            ]
                                        }
                                    ],
                                    annots: ["%splits"]
                                },
                            ]
                        },
                        code: parsedRoyaltySplitsMichelsonCode,
                    },
                },
            ],
        }, {
            name: 'royalty',
            description: 'Get the royalty for a token id.',
            pure: true,
            implementations: [
                {
                    michelsonStorageView:
                    {
                        parameter: {
                            prim: 'nat',
                        },
                        // nat
                        returnType: {
                            prim: 'nat',
                        },
                        code: parsedRoyaltyMichelsonCode,
                    },
                },
            ],
        }, {
            name: 'minter',
            description: 'Get the minter for a token id.',
            pure: true,
            implementations: [
                {
                    michelsonStorageView:
                    {
                        parameter: {
                            prim: 'nat',
                        },
                        // nat
                        returnType: {
                            prim: 'address',
                        },
                        code: parsedMinterMichelsonCode,
                    },
                },
            ],
        }, {
            name: 'is_token_minter',
            description: 'Verify if address is minter on the contract.',
            pure: false,
            implementations: [
                {
                    michelsonStorageView:
                    {
                        parameter: {
                            prim: 'pair',
                            args: [
                                { prim: "address" },
                                { prim: "nat" }
                            ]
                        },
                        // nat
                        returnType: {
                            prim: 'bool',
                        },
                        code: parsedIsTokenMinterMichelsonCode,
                    },
                },
            ],
        }],
    };

    const contractMetadata = await client.storeBlob(
        new Blob([JSON.stringify(editions_contract_metadata)]),
    )

    if (!contractMetadata) {
        console.log(kleur.red(`An error happened while uploading the ipfs metadata of the contract.`));
        return;
    }

    console.log(contractMetadata)
}

// Example metadata upload for gallery factory generated contracts
export const uploadContractMetadataGallery = async () => {

    const p = new Parser();

    const parsedSplitsMichelsonCode = p.parseMichelineExpression(SplitsViewGallery.code);
    const parsedMinterMichelsonCode = p.parseMichelineExpression(MinterViewGallery.code);
    const parsedRoyaltyMichelsonCode = p.parseMichelineExpression(RoyaltyViewGallery.code);
    const parsedIsTokenMinterMichelsonCode = p.parseMichelineExpression(IsTokenMinterViewGallery.code);
    const parsedRoyaltySplitsMichelsonCode = p.parseMichelineExpression(RoyaltySplitsViewGallery.code);
    const parsedEditionMetadataMichelsonCode = p.parseMichelineExpression(TokenMetadataViewGallery.code);
    const parsedRoyaltyDistributionMichelsonCode = p.parseMichelineExpression(RoyaltyDistributionViewGallery.code);
    const parsedCommissionSplitsGalleryMichelsonCode = p.parseMichelineExpression(CommissionSplitsViewGallery.code);

    const editions_contract_metadata = {
        name: 'A:RT Gallery',
        description: 'We present work across all media including painting, drawing, sculpture, installation, photography and video and we seek to cultivate the lineages that run between emerging and established artists.',
        authors: 'tz1KhMoukVbwDXRZ7EUuDm7K9K5EmJSGewxd',
        interfaces: ['TZIP-012', 'TZIP-016'],
        imageUri: "ipfs://QmUxNNqSrsDK5JLk42u2iwwFkP8osFM2pcfYRuEZKsmwrL",
        imageUriSvg: true,
        headerLogo: "ipfs://Qmf4LS9HgwYSWVq73AL1HVaaeW1s44qJvZuUDJkVyTEKze",
        headerLogoSvg: true,
        views: [{
            name: 'token_metadata',
            description: 'Get the metadata for the tokens minted using this contract',
            pure: false,
            implementations: [
                {
                    michelsonStorageView:
                    {
                        parameter: {
                            prim: 'nat',
                        },
                        // (pair (nat %token_id) (map %token_info string bytes))
                        returnType: {
                            prim: "pair",
                            args: [
                                { prim: "nat", annots: ["%token_id"] },
                                { prim: "map", args: [{ prim: "string" }, { prim: "bytes" }], annots: ["%token_info"] },
                            ],
                        },
                        code: parsedEditionMetadataMichelsonCode,
                    },
                },
            ],
        }, {
            name: 'royalty_distribution',
            description: 'Get the minter of a specify token as well as the amount of royalty and the splits corresponding to it.',
            pure: true,
            implementations: [
                {
                    michelsonStorageView:
                    {
                        parameter: {
                            prim: 'nat',
                        },
                        // (pair address (pair (nat %royalty) (list %splits (pair (address %address) (nat %pct)))))
                        returnType: {
                            prim: "pair",
                            args: [
                                { prim: "address" },
                                {
                                    prim: "pair",
                                    args: [
                                        { prim: "nat", annots: ["%royalty"] },
                                        {
                                            prim: "list",
                                            args: [
                                                {
                                                    prim: "pair",
                                                    args: [
                                                        { prim: "address", annots: ["%address"] },
                                                        { prim: "nat", annots: ["%pct"] },
                                                    ]
                                                }
                                            ],
                                            annots: ["%splits"]
                                        },
                                    ]
                                },
                            ],
                        },
                        code: parsedRoyaltyDistributionMichelsonCode,
                    },
                },
            ],
        }, {
            name: 'splits',
            description: 'Get the splits for a token id.',
            pure: true,
            implementations: [
                {
                    michelsonStorageView:
                    {
                        parameter: {
                            prim: 'nat',
                        },
                        // (list (pair (address %address) (nat %pct)))
                        returnType: {
                            prim: "list",
                            args: [
                                {
                                    prim: "pair",
                                    args: [
                                        { prim: "address", annots: ["%address"] },
                                        { prim: "nat", annots: ["%pct"] },
                                    ]
                                }
                            ],
                            annots: ["%splits"]
                        },
                        code: parsedSplitsMichelsonCode,
                    },
                },
            ],
        }, {
            name: 'royalty_splits',
            description: 'Get the royalty and splits for a token id.',
            pure: true,
            implementations: [
                {
                    michelsonStorageView:
                    {
                        parameter: {
                            prim: 'nat',
                        },
                        // (pair (nat %royalty) (list %splits (pair (address %address) (nat %pct))))
                        returnType: {
                            prim: "pair",
                            args: [
                                { prim: "nat", annots: ["%royalty"] },
                                {
                                    prim: "list",
                                    args: [
                                        {
                                            prim: "pair",
                                            args: [
                                                { prim: "address", annots: ["%address"] },
                                                { prim: "nat", annots: ["%pct"] },
                                            ]
                                        }
                                    ],
                                    annots: ["%splits"]
                                },
                            ]
                        },
                        code: parsedRoyaltySplitsMichelsonCode,
                    },
                },
            ],
        }, {
            name: 'commission_splits',
            description: 'Get the commission and splits from the gallery for a token id',
            pure: true,
            implementations: [
                {
                    michelsonStorageView:
                    {
                        parameter: {
                            prim: 'nat',
                        },
                        returnType: {
                            prim: "pair",
                            args: [
                                { prim: "nat", annots: ["%commission_pct"] },
                                {
                                    prim: "list",
                                    args: [
                                        {
                                            prim: "pair",
                                            args: [
                                                { prim: "address", annots: ["%address"] },
                                                { prim: "nat", annots: ["%pct"] },
                                            ]
                                        }
                                    ],
                                    annots: ["%splits"]
                                }
                            ]
                        },
                        code: parsedCommissionSplitsGalleryMichelsonCode,
                    }
                }
            ]
        }, {
            name: 'royalty',
            description: 'Get the royalty for a token id.',
            pure: true,
            implementations: [
                {
                    michelsonStorageView:
                    {
                        parameter: {
                            prim: 'nat',
                        },
                        // nat
                        returnType: {
                            prim: 'nat',
                        },
                        code: parsedRoyaltyMichelsonCode,
                    },
                },
            ],
        }, {
            name: 'minter',
            description: 'Get the minter for a token id.',
            pure: true,
            implementations: [
                {
                    michelsonStorageView:
                    {
                        parameter: {
                            prim: 'nat',
                        },
                        // nat
                        returnType: {
                            prim: 'address',
                        },
                        code: parsedMinterMichelsonCode,
                    },
                },
            ],
        }, {
            name: 'is_token_minter',
            description: 'Verify if address is minter on the contract.',
            pure: false,
            implementations: [
                {
                    michelsonStorageView:
                    {
                        parameter: {
                            prim: 'pair',
                            args: [
                                { prim: "address" },
                                { prim: "nat" }
                            ]
                        },
                        // nat
                        returnType: {
                            prim: 'bool',
                        },
                        code: parsedIsTokenMinterMichelsonCode,
                    },
                },
            ],
        }],
    };

    const contractMetadata = await client.storeBlob(
        new Blob([JSON.stringify(editions_contract_metadata)]),
    )

    if (!contractMetadata) {
        console.log(kleur.red(`An error happened while uploading the ipfs metadata of the contract.`));
        return;
    }

    console.log(contractMetadata)
}