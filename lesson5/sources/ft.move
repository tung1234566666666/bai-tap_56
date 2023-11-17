module lesson5::FT_TOKEN {
    use std::option::{Self, Option};
    use std::string::{utf8, String};

    use std::ascii;
    use sui::object::{Self, UID};
    use sui::tx_context::{Self, TxContext};
    use sui::transfer;
    use sui::coin::{Self, Coin, TreasuryCap, CoinMetadata};
    use sui::url::{Self, Url};
    use sui::event::emit;

    struct FT_TOKEN  has drop{}
    struct Admin has key{
        id: UID
    }
    fun init(witness: FT_TOKEN, ctx: &mut TxContext) {
        let (treasury_cap, metadata) = coin::create_currency<FT_TOKEN>(
            witness, 
            9,
            b"FT",
            b"FT Token",
            b"Description",
            option::some(url::new_unsafe_from_bytes(b"https://github.com")),
            ctx
        );

        let admin = Admin {
            id: object::new(ctx)
        };
        transfer::public_share_object(treasury_cap);
        transfer::public_share_object(metadata);
        transfer::transfer(admin, tx_context::sender(ctx));
    }

    public fun mint(
        _: &Admin,
        treasury_cap: &mut TreasuryCap<FT_TOKEN>,
        amount: u64,
        account: address,
        ctx: &mut TxContext
    ) {
        let coin_minted = coin::mint<FT_TOKEN>(treasury_cap, amount, ctx);
        transfer::public_transfer(coin_minted, account);
        emit(UpdateEvent{
            success: true,
            data: utf8(b"Mint token success")
        })
    }

    public entry fun burn_token(
        treasury_cap: &mut TreasuryCap<FT_TOKEN>,
        coin: Coin<FT_TOKEN>
    ) {
        coin::burn<FT_TOKEN>(treasury_cap, coin);
        emit(UpdateEvent{
            success: true,
            data: utf8(b"Burn token success")
        })
    }

    public entry fun transfer_token(
        coin: Coin<FT_TOKEN>,
        account: address
    ) {
        transfer::public_transfer(coin, account);
         emit(UpdateEvent{
            success: true,
            data: utf8(b"Transfer token success")
        })
    }

    public entry fun split_token(
        coin: &mut Coin<FT_TOKEN>,
        account: address,
        split_amount: u64, 
        ctx: &mut TxContext
    ) {
        let coin_split = coin::split<FT_TOKEN>(coin, split_amount, ctx);
        transfer::public_transfer(coin_split, account);
        emit(UpdateEvent{
            success: true,
            data: utf8(b"Split token success")
        })
    }

    public entry fun update_name(
        _: &Admin,
        treasury: &TreasuryCap<FT_TOKEN>,
        metadata: &mut CoinMetadata<FT_TOKEN>,
        name: String
    ) {
        coin::update_name<FT_TOKEN>(treasury, metadata, name);
        emit(UpdateEvent{
            success: true,
            data: utf8(b"Name updated")
        })
    }
    public entry fun update_description(
        _: &Admin,
        treasury: &TreasuryCap<FT_TOKEN>,
        metadata: &mut CoinMetadata<FT_TOKEN>,
        description: String
    ) {
        coin::update_description<FT_TOKEN>(treasury, metadata, description);
        emit(UpdateEvent{
            success: true,
            data: utf8(b"Name updated")
        })
    }
    public entry fun update_symbol(
        _: &Admin,
        treasury: &TreasuryCap<FT_TOKEN>,
        metadata: &mut CoinMetadata<FT_TOKEN>,
        symbol: ascii::String
    ) {
        coin::update_symbol<FT_TOKEN>(treasury, metadata, symbol);
        emit(UpdateEvent{
            success: true,
            data: utf8(b"Name updated")
        })
    }
    public entry fun update_icon_url(
        _: &Admin,
        treasury: &TreasuryCap<FT_TOKEN>,
        metadata: &mut CoinMetadata<FT_TOKEN>,
        url: ascii::String
    ) {
        coin::update_icon_url<FT_TOKEN>(treasury, metadata, url);
        emit(UpdateEvent{
            success: true,
            data: utf8(b"Name updated")
        })
    }

    struct UpdateEvent has copy, drop {
        success: bool,
        data: String
    }

    public entry fun get_token_name(metadata: &CoinMetadata<FT_TOKEN>): String {
        coin::get_name<FT_TOKEN>(metadata)
    }
    public entry fun get_token_description(metadata: &CoinMetadata<FT_TOKEN>): String {
        coin::get_description<FT_TOKEN>(metadata)
    }
    public entry fun get_token_symbol(metadata: &CoinMetadata<FT_TOKEN>): ascii::String {
        coin::get_symbol<FT_TOKEN>(metadata)
    }
    public entry fun get_token_icon_url(metadata: &CoinMetadata<FT_TOKEN>): Option<Url> {
        coin::get_icon_url(metadata)
    }
}
