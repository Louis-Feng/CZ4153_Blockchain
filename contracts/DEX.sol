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


    function executeTokenMarket(
        address _baseToken,
        address _tokenAddress,
        uint256 _amount,
        bytes32  _type
    ) public returns (bool[] memory){
        emit logBytes32(_type);
        emit loguint256(_amount);
        // fulfilled, insufficient token, insufficient buy orders
        bool[] memory feedback = new bool[](3);
        feedback[0] = false;
        feedback[1] = false;
        feedback[2] = false;

        Token storage selfToken = token_list[_tokenAddress];
        uint256 remainingAmount = _amount;
        //question
        //uint256 currentPrice = selfToken.buy_order_book.highest_priority;
        //lowest price for buy order, highest price for sell order
        uint256 currentPrice = selfToken.Book[_type].first_price;
        uint256 currentOffer;
        //uint256 ethAmount = 0;
        bytes32 otherType;

        if(equals(_type,"buy")){
            otherType = "sell";
        }else{
            otherType = "buy";
        }
        emit logBytes32(otherType);
        emit logBytes32(_type);

        //ERC20API baseToken = ERC20API(_baseTokenAddress);
        ERC20API token = ERC20API(_tokenAddress);
        ERC20API baseToken = ERC20API(_baseToken);

        //No offer for this token
        if(selfToken.Book[otherType].number_of_prices == 0){
            feedback[2] = true;
            //possible entry for batched execution
            return feedback;
        }
        while(remainingAmount > 0 && !feedback[1] && !feedback[2]){
            //offerPointer
            //currentOffer = selfToken.buy_order_book[currentPrice].highest_priority;
            currentOffer = selfToken.Book[otherType].prices[currentPrice].highest_priority;

            while (
            //question
                currentOffer <= selfToken.Book[otherType].prices[currentPrice].lowest_priority &&
                remainingAmount > 0 &&
                !feedback[1]
            ) {

                uint256 currentOfferAmount = selfToken.Book[otherType].prices[currentPrice]
                .offer_list[currentOffer]
                .offer_amount;

                if(currentOfferAmount >= remainingAmount){
                    //fully filled
                    // currentOfferAmount >= remainingAmount
                    if ((getTokenBalance(msg.sender, _tokenAddress) >= remainingAmount)){
                        //msg.sender has enough token on his account
                        //ethAmount = (remainingAmount.mul(currentPrice)).div(1e3);

                        // approve exchange to move token to maker
                        token.approve(
                            msg.sender,
                            address(this),
                            remainingAmount
                        );
                        // send token to maker
                        token.transferFrom(
                            msg.sender,
                            selfToken.Book[otherType].prices[currentPrice]
                            .offer_list[currentOffer]
                            .offer_maker,
                            remainingAmount
                        );
                        // send weth to taker
                        baseToken.transferFrom(
                            selfToken.Book[otherType].prices[currentPrice]
                            .offer_list[currentOffer]
                            .offer_maker,
                            msg.sender,
                            (remainingAmount.mul(currentPrice)).div(1e3)
                        );
                        //question: should combine equal case to other else?
                        if(currentOfferAmount == remainingAmount){
                            //remove this order from order book
                            //call remove offer

                            //removeOrder(_baseToken,_token,_type.equals("sell") ? true : false,currentPrice);
                            selfToken.Book[otherType].prices[currentPrice].offer_list[currentOffer]
                            .offer_amount = 0;
                            selfToken.Book[otherType].prices[currentPrice]
                            .highest_priority = selfToken.Book[otherType].prices[currentPrice]
                            .offer_list[currentOffer]
                            .lower_priority;
                            selfToken.Book[otherType].prices[currentPrice].offer_length = selfToken.Book[otherType].prices[currentPrice].offer_length.sub(1);

                        }else{
                            //keep the order, modify the amount
                            selfToken.Book[otherType].prices[currentPrice].offer_list[currentOffer]
                            .offer_amount =
                            selfToken.Book[otherType].prices[currentPrice].offer_list[currentOffer].offer_amount
                            .sub(remainingAmount);
                        }
                        remainingAmount = 0;

                    }else{
                        //currentOfferAmount >= remainingAmount > (getTokenBalance(msg.sender, _tokenAddress)
                        return feedback;
                    }

                }else{
                    //partially filled
                    //currentOfferAmount < remainingAmount

                    if ((getTokenBalance(msg.sender, _tokenAddress) >= remainingAmount)){
                        ////currentOfferAmount < remainingAmount < msg.sender's token in account
                        //msg.sender has enough token on his account
                        //ethAmount = (currentOfferAmount.mul(currentPrice)).div(1e3);

                        // approve exchange to move token to maker
                        token.approve(
                            msg.sender,
                            address(this),
                            currentOfferAmount
                        );
                        // send token to maker
                        token.transferFrom(
                            msg.sender,
                            selfToken.Book[otherType].prices[currentPrice]
                            .offer_list[currentOffer]
                            .offer_maker,
                            currentOfferAmount
                        );
                        // send weth to taker
                        baseToken.transferFrom(
                            selfToken.Book[otherType].prices[currentPrice]
                            .offer_list[currentOffer]
                            .offer_maker,
                            msg.sender,
                            (remainingAmount.mul(currentPrice)).div(1e3)
                        );
                        //remove offer
                        //removeOrder(_baseToken,_token,_type.equals("sell") ? true : false,currentPrice);
                        selfToken.Book[otherType].prices[currentPrice]
                        .highest_priority = selfToken.Book[otherType].prices[currentPrice]
                        .offer_list[currentOffer]
                        .lower_priority;
                        selfToken.Book[otherType].prices[currentPrice].offer_list[currentOffer]
                        .offer_amount;
                        selfToken.Book[otherType].prices[currentPrice].offer_length = selfToken.Book[otherType].prices[currentPrice].offer_length.sub(1);

                        remainingAmount = remainingAmount.sub(currentOfferAmount);

                    }else{
                        //currentOfferAmount < remainingAmount
                        // msg.sender's token in account < remainingAmount
                        //depends on which one is smaller, currentOfferAmount or msg.sender's token in account
                        feedback[1] = true;
                    }
                }
                //这个price的order全没了
            }
            currentPrice = selfToken.Book[_type].first_price;

        }
        if (remainingAmount == 0) {
            feedback[0] = true;
        }
        //emit MarketResult(feedback[0], feedback[1], feedback[2]);
        return feedback;
    }





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


    function getTokenBalance(address user, address _tokenAddress) public view returns(uint256) {
        ERC20API tokenLoaded = ERC20API(_tokenAddress);
        return tokenLoaded.balanceOf(user);
    }

    //string comparison
    function equals(bytes32 str1, bytes32 str2) public pure returns(bool) {
        return (str1 == str2);
    }

    event logBytes32(bytes32 _type);
    event loguint256(uint256 message);
}
