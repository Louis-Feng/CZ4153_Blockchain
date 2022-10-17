pragma solidity ^0.4.0;

import "../utils/SafeMath.sol";

contract DEX {
    using SafeMath for uint256;

    struct Offer {
        uint256 offer_amount;
        address offer_maker;
        uint256 higher_priority;
        uint256 lower_priority;
    }
    struct OrderBook {
        uint256 higher_price;
        uint256 lower_price;
        mapping(uint256 => Offer) offer_list;
        uint256 highest_priority;
        uint256 lowest_priority;
        uint256 offer_length;
    }
    struct Token {
        address token_contract;
        mapping(uint256 => OrderBook) buy_order_book;
        uint256 max_bid_price;
        uint256 min_bid_price;
        uint256 amount_bid_prices;
        mapping(uint256 => OrderBook) sell_order_book;
        uint256 min_ask_price;
        uint256 max_ask_price;
        uint256 amount_ask_prices;
    }

    mapping(address => Token) token_list;

    mapping(address => uint256) ether_balance;

    mapping(address => string[]) token_address_list;

//    event BuyMarketResult(
//        bool completelyfulfilled,
//        bool insufficientEtherAmount,
//        bool insufficientOrderAmount
//    );
//
//    event SellMarketResult(
//        bool completelyfulfilled,
//        bool insufficientTokenAmount,
//        bool insufficientOrderAmount
//    );


}
