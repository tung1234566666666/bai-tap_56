module lesson6::hero_game {
    use std::option::{Self, Option};
    use std::string::String;

    use sui::object::{Self, UID};
    use sui::tx_context::{Self, TxContext};
    use sui::transfer;
    use sui::coin::{Self, Coin};
    use sui::sui::SUI;

    const MINT_FEE: u64 = 1_000_000_000;
    const LEVEL_UP_FEE: u64 = 1_000_000_000;
    const VAULT: address = @vault;

    const HP_GAIN_BY_LEVEL: u64 = 100;
    const ATTACK_GAIN_BY_LEVEL: u64 = 5;
    const DEFENSE_GAIN_BY_LEVEL: u64 = 6;

    const BASIC_HP: u64 = 500;
    const BASIC_ATTACK: u64 = 60;
    const BASIC_DEFENSE: u64 = 30;

    const SWORD_ATTACK_GAIN_BY_LEVEL: u64 = 20;
    const SWORD_HP_GAIN_BY_LEVEL: u64 = 10;

    const ARMOR_DEFENSE_GAIN_BY_LEVEL: u64 = 20;
    const ARMOR_HP_GAIN_BY_LEVEL: u64 = 30;

    const EXPERIENCE_LEVEL: u64 = 1000;

    struct Hero has store, key {
        id: UID,
        name: String,
        hp: u64,
        attack: u64,
        defense: u64,
        experience: u64,
        level: u64,
        sword: Option<Sword>,
        armor: Option<Armor>
    }

    struct Sword has store, key {
        id: UID,
        attack: u64,
        hp: u64,
    }

    struct Armor has store, key {
        id: UID,
        defense: u64,
        hp: u64,
    }

    struct Monster has key {
        id: UID,
        hp: u64,
        attack: u64,
        defense: u64,
        experience: u64
    }

    struct GameInfo has key, store {
        id: UID
    }

    fun init(ctx: &mut TxContext) {
        let game_info = GameInfo{
            id: object::new(ctx)
        };
        transfer::public_transfer(game_info, tx_context::sender(ctx));
    }

    fun create_hero(
        name: String,
        coin: Coin<SUI>,
        ctx: &mut TxContext
    ) {
        let fee = coin::split(&mut coin, MINT_FEE, ctx);
        let hero = Hero{
            id: object::new(ctx),
            name: name,
            hp: BASIC_HP,
            attack: BASIC_ATTACK,
            defense: BASIC_DEFENSE,
            level: 1,
            experience: 0,
            sword: option::none<Sword>(),
            armor: option::none<Armor>()
        };
        transfer::public_transfer(fee, VAULT);
        transfer::public_transfer(coin, tx_context::sender(ctx));
        transfer::public_transfer(hero, tx_context::sender(ctx));
    }
    fun create_sword(
        attack: u64,
        hp: u64,
        ctx:&mut TxContext
    ) {
        let sword = Sword{
            id: object::new(ctx),
            hp: hp,
            attack: attack
        };
        transfer::public_transfer(sword, tx_context::sender(ctx));
    }
    fun create_armor(
        defense: u64,
        hp: u64,
        ctx:&mut TxContext
    ) {
        let armor = Armor{
            id: object::new(ctx),
            defense: defense,
            hp: hp
        };
        transfer::public_transfer(armor, tx_context::sender(ctx));
    }


    fun create_monster(
        _: &GameInfo,
        hp: u64,
        attack: u64,
        defense: u64,
        experience: u64,
        ctx: &mut TxContext
    ) {
        let monster = Monster{
            id: object::new(ctx),
            defense: defense,
            hp: hp,
            attack: attack,
            experience: experience
        };
        transfer::share_object(monster);
    }

    fun level_up_hero(
        hero: &mut Hero
    ) {
        if (hero.experience > EXPERIENCE_LEVEL) {
            hero.level = hero.level + 1;
            hero.experience = hero.experience - EXPERIENCE_LEVEL;
            hero.hp = hero.hp + HP_GAIN_BY_LEVEL;
            hero.attack = hero.attack + ATTACK_GAIN_BY_LEVEL;
            hero.defense = hero.defense + DEFENSE_GAIN_BY_LEVEL;
        }
    }
    fun level_up_sword(
        sword: &mut Sword,
        coin: &mut Coin<SUI>,
        ctx: &mut TxContext
    ) {
        let fee = coin::split(coin, LEVEL_UP_FEE, ctx);
        transfer::public_transfer(fee, VAULT);
        sword.hp = sword.hp + SWORD_HP_GAIN_BY_LEVEL;
        sword.attack = sword.attack + SWORD_ATTACK_GAIN_BY_LEVEL;
    }
    fun level_up_armor(
        armor: &mut Armor,
        coin: &mut Coin<SUI>,
        ctx: &mut TxContext
    ) {
        let fee = coin::split(coin, LEVEL_UP_FEE, ctx);
        transfer::public_transfer(fee, VAULT);
        armor.hp = armor.hp + ARMOR_HP_GAIN_BY_LEVEL;
        armor.defense = armor.defense + ARMOR_DEFENSE_GAIN_BY_LEVEL;
    }

    public entry fun equip_sword(
        hero: &mut Hero,
        sword: Sword,
    ) {
        hero.hp = hero.hp + sword.hp;
        hero.attack = hero.attack + sword.attack;
        option::fill(&mut hero.sword, sword);
    }

    public entry fun equip_armor(
        hero: &mut Hero,
        armor: Armor,
    ) {
        hero.hp = hero.hp + armor.hp;
        hero.defense = hero.defense + armor.defense;
        option::fill(&mut hero.armor, armor);
    }

    public entry fun unequip_sword(
        hero: &mut Hero,
        ctx: &mut TxContext
    ) {
        let sword = option::extract(&mut hero.sword);
        hero.hp = hero.hp - sword.hp;
        hero.attack = hero.attack - sword.attack;
        transfer::transfer(sword, tx_context::sender(ctx));
    }

    public entry fun unequip_armor(
        hero: &mut Hero,
        ctx: &mut TxContext
    ) {
        let armor = option::extract(&mut hero.armor);
        hero.hp = hero.hp - armor.hp;
        hero.defense = hero.defense - armor.defense;
        transfer::transfer(armor, tx_context::sender(ctx));
    }

    public entry fun attack_monster(
        hero: &mut Hero,
        monster: &Monster
    ) {
        let win = if (hero.attack <= monster.defense) {
            false
        } else if (hero.defense >= monster.defense) {
            true
        } else {
            monster.hp / (hero.attack - monster.defense) > hero.hp / (monster.attack - hero.defense)
        };

        if (win) {
            hero.experience = hero.experience + monster.experience;
        }
    }

}
