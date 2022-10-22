pragma solidity >=0.4.22 <0.8.0;

import "../utils/SafeMath.sol";

contract DEX {
    using SafeMath for uint256;

    struct Offer {
        uint256 offer_amount;
        address offer_maker;
        uint256 higher_priority;
        uint256 lower_priority;
    }
    struct OfferLinkedList {
        uint256 next_price;
        mapping(uint256 => Offer) offer_list;
        uint256 highest_priority;
        uint256 lowest_priority;
        uint256 offer_length;
    }
    struct Token {
        address token_contract;
        mapping(bytes32 => OrderBook) Book;
    }
    struct OrderBook {
        mapping(uint256 => OfferLinkedList) prices;
        uint256 first_price;
        uint256 last_price;
        uint256 number_of_prices;
    }

    mapping(address => Token) token_list;

    mapping(address => uint256) ether_balance;

    mapping(address => string[]) token_address_list;




}
