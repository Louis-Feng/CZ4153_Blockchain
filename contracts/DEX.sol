pragma solidity >=0.4.22 <0.8.0;

import "../utils/SafeMath.sol";
import "./ERC20API.sol";

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
        // 1. when the buy order comes in, we will be traversing the sell book,
        //      from low to high: because the buyer is looking for prices as low as possible to buy
        // 2. when the sell order comes in, we will be traversing the buy book,
        //      from high to low: because the seller is looking for prices as high as possible to sell.
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
        // 1. for the sell order book:
        //      first_price -> min price
        //      last_price -> max price
        // 2. for the buy order book:
        //      first_price -> max price
        //      last_price -> min price
        uint256 number_of_prices;
    }

    mapping(address => Token) token_list;

    mapping(address => uint256) ether_balance;

    mapping(address => string[]) token_address_list;

    function executeLimitOrder (
        address _basicToken,
        address _token,
        uint256 _price,
        uint256 _amount,
        bool _isBuy
    ) public {

        Token storage currentToken = token_list[_token]; // find the desired Token object.

        require(
            getTokenBalance(msg.sender, _basicToken) >= (_price.mul(_amount)).div(1e3),
            "executeLimitOrder: the WETH balance < ETH required."
        );

        OrderBook storage orderBook = (_isBuy ? currentToken.Book["sell"]:currentToken.Book["buy"]);
        // choose the desired order book: buy -> sell order book; sell -> buy order book

        // check if the proposed order price is able to match any order price
        if (
            (_isBuy && _price < orderBook.first_price) || // buy order price smaller than minimum sell price
            (!_isBuy && _price > orderBook.first_price) || // sell order price higher than maximum buy price
            orderBook.number_of_prices == 0 // there is no order to match.
        ) storeOrder(_token, !_isBuy, _price, _amount, msg.sender); // store the order and delay its execution

        ERC20API basicToken = ERC20API(_basicToken);
        ERC20API desiredToken = ERC20API(_token);
        uint256 totalEtherToTrade = 0;
        uint256 amountLeftToTrade = _amount;
        uint256 currentTradePrice = orderBook.first_price;
        uint256 offerPtr;

        while (currentTradePrice != 0 && amountLeftToTrade > 0){
            if ((_isBuy && _price < currentTradePrice) || (!_isBuy && _price > currentTradePrice)) {
                storeOrder(_token, !_isBuy, _price, amountLeftToTrade, msg.sender);
                break;
            }
            offerPtr = orderBook.prices[currentTradePrice].highest_priority; // initiate the helper offer pointer to traverse the price node.
            while (offerPtr != orderBook.prices[currentTradePrice].lowest_priority
                && amountLeftToTrade > 0) {

                if (orderBook.prices[currentTradePrice].offer_list[offerPtr].offer_amount <= amountLeftToTrade){

                    totalEtherToTrade = ((orderBook.prices[currentTradePrice].offer_list[offerPtr].offer_amount).mul(currentTradePrice)).div(1e3);

                    require(
                        getTokenBalance(msg.sender, _basicToken) >= totalEtherToTrade,
                        "executeLimitOrder: insufficient ether balance."
                    );

                    basicToken.transferFrom(
                        msg.sender,
                        orderBook.prices[currentTradePrice].offer_list[offerPtr].offer_maker,
                        totalEtherToTrade
                    );

                    desiredToken.transferFrom(
                        orderBook.prices[currentTradePrice].offer_list[offerPtr].offer_maker,
                        msg.sender,
                        orderBook.prices[currentTradePrice].offer_list[offerPtr].offer_amount
                    );

                    orderBook.prices[currentTradePrice].offer_list[offerPtr].offer_amount = 0;
                    orderBook.prices[currentTradePrice].offer_length = orderBook.prices[currentTradePrice].offer_length.sub(1);
                    orderBook.prices[currentTradePrice].highest_priority = orderBook.prices[currentTradePrice].offer_list[offerPtr].lower_priority;
                    amountLeftToTrade = amountLeftToTrade.sub(orderBook.prices[currentTradePrice].offer_list[offerPtr].offer_amount);
                    //removeOrder(_basicToken, _token, !_isBuy, currentTradePrice);
                } else {
                    totalEtherToTrade = (amountLeftToTrade.mul(currentTradePrice)).div(1e3);

                    require(
                        getTokenBalance(msg.sender, _basicToken) >= totalEtherToTrade,
                        "executeLimitOrder: insufficient ether balance."
                    );

                    basicToken.transferFrom(
                        msg.sender,
                        orderBook.prices[currentTradePrice].offer_list[offerPtr].offer_maker,
                        totalEtherToTrade
                    );

                    desiredToken.transferFrom(
                        orderBook.prices[currentTradePrice].offer_list[offerPtr].offer_maker,
                        msg.sender,
                        amountLeftToTrade
                    );

                    orderBook.prices[currentTradePrice].offer_list[offerPtr].offer_amount =
                        orderBook.prices[currentTradePrice].offer_list[offerPtr].offer_amount.sub(amountLeftToTrade);
                    amountLeftToTrade = 0;
                }

                if (offerPtr == orderBook.prices[currentTradePrice].lowest_priority &&
                    orderBook.prices[currentTradePrice].offer_list[offerPtr].offer_amount == 0
                ) {
                    orderBook.number_of_prices = orderBook.number_of_prices.sub(1);
                    orderBook.prices[currentTradePrice].offer_length = 0;

                    if (
                        currentTradePrice == orderBook.prices[currentTradePrice].next_price ||
                        orderBook.prices[currentTradePrice].next_price == 0
                    ) {
                        orderBook.prices[currentTradePrice].next_price = 0;
                        orderBook.number_of_prices = 0;
                        orderBook.first_price = 0;
                        orderBook.last_price = 0;
                    } else {
                        orderBook.first_price = orderBook.prices[currentTradePrice].next_price;
                    }
                    break;
                }
                offerPtr = orderBook.prices[currentTradePrice].offer_list[offerPtr].lower_priority;
            }
            currentTradePrice = orderBook.first_price;
        }
    }

    function storeOrder(address _token, bool _isSell, uint256 _price, uint256 amountLeftToTrade, address _sender) public {

    }

    function removeOrder(address _basicToken, address _token, bool _isSell, uint256 _price, uint256 _amount) public {

    }


    function getTokenBalance(address user, address _tokenAddress) public view returns(uint256) {
        ERC20API tokenLoaded = ERC20API(_tokenAddress);
        return tokenLoaded.balanceOf(user);
    }

    function test(uint256 numTokens) public {
        //return true;
    }
}
