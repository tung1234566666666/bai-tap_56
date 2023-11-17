module lesson5::discount_coupon {
    
    use sui::object::{Self, UID};
    use sui::tx_context::{Self, TxContext};
    use sui::transfer;
    use sui::coin;
    use sui::sui::SUI;
    use sui::clock::{Self, Clock};

    const EXPIRED: u64 = 1;

    const MINT_FEE: u64 = 1_000_000_000;
    const VAULT: address = @vault;

    struct DiscountCoupon has key, store {
        id: UID,
        owner: address,
        discount: u8,
        expiration: u64,
    }

    public fun owner(coupon: &DiscountCoupon): address {
        coupon.owner
    }

    public fun discount(coupon: &DiscountCoupon): u8 {
        coupon.discount
    }

    public entry fun mint_and_topup(
        coin: coin::Coin<SUI>,
        discount: u8,
        expiration: u64,
        recipient: address,
        ctx: &mut TxContext,
    ) {
        let coupon = DiscountCoupon{
            id: object::new(ctx),
            owner: recipient,
            expiration: expiration,
            discount: discount
        };
        let fee = coin::split(&mut coin, MINT_FEE, ctx);
        transfer::public_transfer(coin, tx_context::sender(ctx));
        transfer::public_transfer(fee, VAULT);
        transfer::public_transfer(coupon, recipient);
    }

    public entry fun transfer_coupon(coupon: DiscountCoupon, recipient: address) {
        transfer::public_transfer(coupon, recipient);
    }

    public fun burn(nft: DiscountCoupon): bool {
        let DiscountCoupon{
            id,
            owner: _,
            expiration: _,
            discount: _
        } = nft;
        object::delete(id);
        true
    }

    public entry fun scan(nft: DiscountCoupon, clock_obj: &Clock) {
        assert!(clock::timestamp_ms(clock_obj) <= nft.expiration, EXPIRED);
        burn(nft);
    }
}
