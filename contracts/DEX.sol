pragma solidity >=0.4.22 <0.9.0;

import "../utils/SafeMath.sol";
import "./ERC20API.sol";
import "./IERC20.sol";


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
        emit loguint256("Initial amount: ",_amount);
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
        uint256 currentOffer;
        //uint256 ethAmount = 0;
        bytes32 otherType;

        if(equals(_type,"buy")){
            otherType = "sell";
        }else{
            otherType = "buy";
        }
        uint256 currentPrice = selfToken.Book[otherType].first_price;
        emit logString(string(abi.encodePacked(otherType)));
        emit loguint256("Current price: ",currentPrice);

        //IERC20 baseToken = ERC20API(_baseTokenAddress);
        IERC20 token = IERC20(_tokenAddress);
        IERC20 baseToken = IERC20(_baseToken);

        //No offer for this token
        if(selfToken.Book[otherType].number_of_prices == 0){
            feedback[2] = true;
            emit logString("No offer for this token");
            //possible entry for batched execution
            return feedback;
        }
        while(remainingAmount > 0 && !feedback[1] && !feedback[2]){
            //offerPointer
            //currentOffer = selfToken.buy_order_book[currentPrice].highest_priority;
            currentOffer = selfToken.Book[otherType].prices[currentPrice].highest_priority;
            emit logOffer(selfToken.Book[otherType].prices[currentPrice].offer_list[currentOffer].offer_amount,
                selfToken.Book[otherType].prices[currentPrice].offer_list[currentOffer].offer_maker,
                selfToken.Book[otherType].prices[currentPrice].offer_list[currentOffer].higher_priority,
                selfToken.Book[otherType].prices[currentPrice].offer_list[currentOffer].lower_priority);
            while (
            //question
                currentOffer <= selfToken.Book[otherType].prices[currentPrice].lowest_priority &&
                remainingAmount > 0 &&
                !feedback[1]
            ) {

                uint256 currentOfferAmount = selfToken.Book[otherType].prices[currentPrice]
                .offer_list[currentOffer]
                .offer_amount;
                emit loguint256("Current Offer Amount", currentOfferAmount);

                if(currentOfferAmount >= remainingAmount){
                    emit logString("currentOfferAmount >= remainingAmount");
                    //fully filled
                    // currentOfferAmount >= remainingAmount
                    if ((getTokenBalance(msg.sender, _tokenAddress) >= remainingAmount)){
                        emit logString("(getTokenBalance(msg.sender, _tokenAddress) >= remainingAmount)");
                        //msg.sender has enough token on his account
                        //ethAmount = (remainingAmount.mul(currentPrice)).div(1e3);

                        // approve exchange to move token to maker
                        token.approve(
                            msg.sender,
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
//                        baseToken.transferFrom(
//                            selfToken.Book[otherType].prices[currentPrice]
//                            .offer_list[currentOffer]
//                            .offer_maker,
//                            msg.sender,
//                            (remainingAmount.mul(currentPrice)).div(1e3)
//                        );
                        //question: should combine equal case to other else?
//                        if(currentOfferAmount == remainingAmount){
//                            emit logString("currentOfferAmount == remainingAmount");
//                            //remove this order from order book
//                            //call remove offer
//
//                            //removeOrder(_baseToken,_token,_type.equals("sell") ? true : false,currentPrice);
//                            selfToken.Book[otherType].prices[currentPrice].offer_list[currentOffer]
//                            .offer_amount = 0;
//
//                            selfToken.Book[otherType].prices[currentPrice]
//                            .highest_priority = selfToken.Book[otherType].prices[currentPrice]
//                            .offer_list[currentOffer]
//                            .lower_priority;
//
//                            selfToken.Book[otherType].prices[currentPrice].offer_length = selfToken.Book[otherType].prices[currentPrice].offer_length.sub(1);
//
//                            emit loguint256("Current Offer Amount", selfToken.Book[otherType].prices[currentPrice].offer_list[currentOffer]
//                                .offer_amount);
//                            emit loguint256("Current Offer highest priority", selfToken.Book[otherType].prices[currentPrice]
//                                .highest_priority);
//                            emit loguint256("Offer length", selfToken.Book[otherType].prices[currentPrice].offer_length);
//                        }else{
//                            emit logString("currentOfferAmount != remainingAmount");
//                            //keep the order, modify the amount
//                            selfToken.Book[otherType].prices[currentPrice].offer_list[currentOffer]
//                            .offer_amount =
//                            selfToken.Book[otherType].prices[currentPrice].offer_list[currentOffer].offer_amount
//                            .sub(remainingAmount);
//
//                            emit loguint256("Current Offer Amount", selfToken.Book[otherType].prices[currentPrice].offer_list[currentOffer]
//                                .offer_amount);
//                            emit loguint256("Current Offer highest priority", selfToken.Book[otherType].prices[currentPrice]
//                                .highest_priority);
//                            emit loguint256("Offer length", selfToken.Book[otherType].prices[currentPrice].offer_length);
//                        }
                        remainingAmount = 0;

                    }else{
                        //currentOfferAmount >= remainingAmount > (getTokenBalance(msg.sender, _tokenAddress)
                        emit logString("Order canceled");
                        return feedback;
                    }

                }else{
                    emit logString("currentOfferAmount < remainingAmount");
                    //partially filled
                    //currentOfferAmount < remainingAmount

                    if ((getTokenBalance(msg.sender, _tokenAddress) >= remainingAmount)){
                        emit logString("(getTokenBalance(msg.sender, _tokenAddress) >= remainingAmount)");
                        ////currentOfferAmount < remainingAmount < msg.sender's token in account
                        //msg.sender has enough token on his account
                        //ethAmount = (currentOfferAmount.mul(currentPrice)).div(1e3);

                        // approve exchange to move token to maker
                        token.approve(
                            msg.sender,
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

                        emit loguint256("Current Offer Amount", selfToken.Book[otherType].prices[currentPrice].offer_list[currentOffer]
                            .offer_amount);
                        emit loguint256("Current Offer highest priority", selfToken.Book[otherType].prices[currentPrice]
                            .highest_priority);
                        emit loguint256("Offer length", selfToken.Book[otherType].prices[currentPrice].offer_length);

                        remainingAmount = remainingAmount.sub(currentOfferAmount);

                    }else{
                        //currentOfferAmount < remainingAmount
                        // msg.sender's token in account < remainingAmount
                        //depends on which one is smaller, currentOfferAmount or msg.sender's token in account
                        emit logString("feedback[1] = true");
                        feedback[1] = true;
                    }
                }

//                if (currentOffer == selfToken.Book[otherType].prices[currentPrice].lowest_priority &&
//                    selfToken.Book[otherType].prices[currentPrice].offer_list[currentOffer].offer_amount == 0
//                ) {
//                    emit logString("no more order at this price");
//                    //no more order at this price
//                    selfToken.Book[otherType].number_of_prices = selfToken.Book[otherType].number_of_prices.sub(1);
//                    selfToken.Book[otherType].prices[currentPrice].offer_length = 0;
//
//                    if (
//                        currentPrice == selfToken.Book[otherType].prices[currentPrice].next_price ||
//                        selfToken.Book[otherType].prices[currentPrice].next_price == 0
//                    ) {
//                        emit logString("no more order");
//                        selfToken.Book[otherType].prices[currentPrice].next_price = 0;
//                        selfToken.Book[otherType].number_of_prices = 0;
//                        selfToken.Book[otherType].first_price = 0;
//                        selfToken.Book[otherType].last_price = 0;
//                        return feedback;
//                    } else {
//                        selfToken.Book[otherType].first_price = selfToken.Book[otherType].prices[currentPrice].next_price;
//                        emit loguint256("first price change to next price", selfToken.Book[otherType].first_price);
//                    }
//                    break;
//                }
                currentOffer = selfToken.Book[otherType].prices[currentPrice].offer_list[currentOffer].lower_priority;
                //这个price的order全没了
                //return feedback;
            }
            currentPrice = selfToken.Book[_type].first_price;
            emit loguint256("current price updated", currentPrice);

        }
        if (remainingAmount == 0) {
            feedback[0] = true;
        }
        //emit MarketResult(feedback[0], feedback[1], feedback[2]);
        return feedback;
    }
    function test(address _token,
            bool is_sell,
        uint256 _price,
        uint256 _amount,
        address _maker) public {
    }

    function storeOrder(
        address _token,
        bool is_sell,
        uint256 _price,
        uint256 _amount,
        address _maker
    ) public {
        bytes32 book_name = "buy";
        if (is_sell) {
            book_name = "sell";
        }
        OrderBook storage orderBook = token_list[_token].Book[book_name];
        orderBook.prices[_price].offer_length = orderBook.prices[_price].offer_length.add(1);

//        emit test(_price);
        if (orderBook.prices[_price].offer_length == 1) {
            //If this is the first offer at this price
            orderBook.prices[_price].highest_priority = 1;
            orderBook.prices[_price].lowest_priority = 1;
            orderBook.number_of_prices = orderBook.number_of_prices.add(1);

            orderBook.prices[_price].offer_list[orderBook.prices[_price].offer_length] = Offer(_amount, _maker, 0, 1);

            uint256 firstPrice = orderBook.first_price;
            uint256 lastPrice = orderBook.last_price;

            if (lastPrice == 0 || is_sell && lastPrice < _price || !is_sell && lastPrice > _price) {
                //insert this price to the end of the orderbook
                if (firstPrice == 0) {
                    //if this is also the first price
                    orderBook.first_price = _price;
                    orderBook.prices[_price].next_price = _price;
                } else {
                    orderBook.prices[lastPrice]
                    .next_price = _price;
                    orderBook.prices[_price].next_price = _price;
                }
                orderBook.last_price = _price;
            } else if (is_sell && firstPrice > _price || !is_sell && firstPrice < _price) {
                //insert this price to the front of the orderbook
                orderBook.prices[_price].next_price = firstPrice;
                orderBook.first_price = _price;
            } else {
                //insert this price in the middle of the orderbook
                uint256 currentPrice = orderBook.first_price;
                bool inserted = false;
                while (currentPrice > 0 && !inserted) {
                    if (
                        is_sell &&
                        currentPrice < _price &&
                        orderBook.prices[currentPrice].next_price > _price
                        ||
                        !is_sell &&
                        currentPrice > _price &&
                        orderBook.prices[currentPrice].next_price < _price
                    ) {
                        orderBook.prices[_price].next_price = orderBook.prices[currentPrice].next_price;

                        orderBook.prices[currentPrice].next_price = _price;
                        inserted = true;
                    }
                    currentPrice = orderBook.prices[currentPrice].next_price;
                }
            }

        } else {
            uint256 currentLowest = orderBook.prices[_price].lowest_priority.add(1);
            orderBook.prices[_price].offer_list[currentLowest] = Offer(
                _amount,
                _maker,
                orderBook.prices[_price].lowest_priority,
                currentLowest
            );
            orderBook.prices[_price].offer_list[orderBook.prices[_price]
            .lowest_priority]
            .lower_priority = currentLowest;
            orderBook.prices[_price].lowest_priority = currentLowest;
        }
    }

    function removeOrder(
        address _baseToken,
        address _token,
        bool is_sell,
        uint256 _price
    ) public {
        bytes32 book_name = "buy";
        if (is_sell) {
            book_name = "sell";
        }
        OrderBook storage orderBook = token_list[_token].Book[book_name];
//        uint256 totalOffers = 0;
//        ERC20API token = ERC20API(_token);
//        ERC20API baseToken = ERC20API(_baseToken);
        //This function assume this is a valid price
        // remove all offer_list for this price
        uint256 counter = orderBook.first_price;
        bool found = false;
        if (orderBook.first_price == _price ) found = true;
        while (counter != orderBook.last_price && !found) {
            counter = orderBook.prices[counter].next_price;
            if (counter == _price) {
                found = true;
                break;
            }
        }
        if (found) {
            emit logString("found");
        }
        counter = orderBook.prices[_price].highest_priority;
        while (counter <= orderBook.prices[_price].lowest_priority && found) {
            if (
                orderBook.prices[_price].offer_list[counter].offer_maker ==
                msg.sender
            ) {
//                totalOffers = totalOffers.add(1);

                orderBook.prices[_price].offer_length = orderBook.prices[_price]
                .offer_length
                .sub(1);

                if (orderBook.prices[_price].highest_priority == orderBook.prices[_price].lowest_priority) {
                   //If this is the only offer left
                    orderBook.prices[_price].highest_priority =0;
                    orderBook.prices[_price].lowest_priority = 0;
                    orderBook.prices[_price].offer_length = 0;

                } else if (
//                    orderBook.prices[_price].offer_list[counter]
//                    .higher_priority == 0
                    counter == orderBook.prices[_price].highest_priority ||
                    orderBook.prices[_price].offer_list[counter].higher_priority == 0
                ) {
                    // if this offer is first in queue
                    orderBook.prices[_price]
                    .highest_priority = orderBook.prices[_price]
                    .offer_list[counter]
                    .lower_priority;
                    orderBook.prices[_price].offer_list[orderBook.prices[_price]
                    .offer_list[counter]
                    .lower_priority]
                    .higher_priority = 0;
                } else if (
//                    orderBook.prices[_price].offer_list[counter]
//                    .lower_priority ==
//                    orderBook.prices[_price].lowest_priority
                        counter == orderBook.prices[_price].lowest_priority
                ) {
                    // if this offer is the last in queue
                    orderBook.prices[_price]
                    .lowest_priority = orderBook.prices[_price]
                    .offer_list[counter]
                    .higher_priority;
                    orderBook.prices[_price].offer_list[orderBook.prices[_price]
                    .offer_list[counter]
                    .higher_priority]
                    .lower_priority = orderBook.prices[_price]
                    .lowest_priority;
                } else {
                    //orderBook.prices[_price].offer_list[counter].offer_amount = 0;
                    // Set lower priority's higher_priority to current higher_priority
                    orderBook.prices[_price].offer_list[orderBook.prices[_price]
                    .offer_list[counter]
                    .lower_priority]
                    .higher_priority = orderBook.prices[_price]
                    .offer_list[counter]
                    .higher_priority;
                    // Set higher priority's lower_priority to current lower_priority
                    orderBook.prices[_price].offer_list[orderBook.prices[_price]
                    .offer_list[counter]
                    .higher_priority]
                    .lower_priority = orderBook.prices[_price]
                    .offer_list[counter]
                    .lower_priority;
                }
            }
            if (counter == orderBook.prices[_price].lowest_priority) {
                break;
            }
            counter = orderBook.prices[_price].offer_list[counter]
            .lower_priority;
        }

        // If offer list is empty, remove the price from price list
        if (
            orderBook.prices[_price].offer_length == 0 && found
//            orderBook.prices[_price].offer_length == 0 && totalOffers > 0
        ) {
            if (
                orderBook.number_of_prices == 1 &&
                orderBook.first_price == _price
            ) {
                // if this is the only price left
                orderBook.prices[_price].offer_length = 0;
                orderBook.prices[_price].next_price = 0;
                orderBook.number_of_prices = 0;
                orderBook.first_price = 0;
                orderBook.last_price = 0;
            } else if (orderBook.first_price == _price) {
                // if this is the first price in order book list
                orderBook.first_price = orderBook.prices[_price]
                .next_price;
                orderBook.number_of_prices = orderBook
                .number_of_prices
                .sub(1);
            } else {
                // if we are in between order book list
                uint256 previousPrice = orderBook.first_price;
                while (orderBook.prices[previousPrice].next_price != _price) {
                    previousPrice = orderBook.prices[previousPrice].next_price;
                }
                if (_price == orderBook.last_price) {
                    // if this is the last price in order book list
                    orderBook.prices[previousPrice].next_price = previousPrice;
                    orderBook.last_price = previousPrice;
                } else {
                    // if we are in between order book list
                    orderBook.prices[previousPrice].next_price
                    = orderBook.prices[_price].next_price;
                }
                orderBook.number_of_prices = orderBook
                .number_of_prices
                .sub(1);

                orderBook.prices[_price].highest_priority = 0;
                orderBook.prices[_price].lowest_priority = 0;
                orderBook.prices[_price].next_price = 0;
                // if we are in between order book list
//                uint256 previousPrice = orderBook.first_price;
//                while (orderBook.prices[previousPrice].next_price != orderBook.last_price) {
//                    previousPrice = orderBook.prices[previousPrice].next_price;
//                    if (orderBook.prices[previousPrice].next_price == _price) break;
//                }
//                if (_price == orderBook.last_price) {
//                    // if this is the last price in order book list
//                    orderBook.prices[previousPrice].next_price = previousPrice;
//                    orderBook.last_price = previousPrice;
//                    orderBook.number_of_prices = orderBook
//                    .number_of_prices
//                    .sub(1);
//                } else if (orderBook.prices[previousPrice].next_price != orderBook.last_price){
//                    // if we are in between order book list
//                    orderBook.prices[previousPrice].next_price
//                    = orderBook.prices[_price].next_price;
//                    orderBook.number_of_prices = orderBook
//                    .number_of_prices
//                    .sub(1);
//                }
//                orderBook.number_of_prices = orderBook
//                .number_of_prices
//                .sub(1);
            }
        }
    }

    function getOrders(address _token, bool is_sell)
    public
    view
    returns (uint256[] memory, uint256[] memory)
    {
        bytes32 book_name = "buy";
        if (is_sell) {
            book_name = "sell";
        }
        OrderBook storage orderBook = token_list[_token].Book[book_name];

        uint256 currentPrice = orderBook.first_price;
        uint256 no_total_offer = 0;
        //loop the orderBook and increase no_total_offer
        if (orderBook.first_price > 0) {
            while (!is_sell && currentPrice <= orderBook.first_price ||
            is_sell && currentPrice >= orderBook.first_price) {
                no_total_offer += orderBook.prices[currentPrice].offer_length;

                if (currentPrice == orderBook.prices[currentPrice].next_price) {
                    break;
                } else {
                    currentPrice = orderBook.prices[currentPrice].next_price;
                }
            }
        }

        uint256[] memory ordersPrices = new uint256[](no_total_offer);
        uint256[] memory ordersVolumes = new uint256[](no_total_offer);

        currentPrice = orderBook.first_price;
        uint256 counter = 0;

        if (orderBook.first_price > 0) {
            while (!is_sell && currentPrice <= orderBook.first_price ||
                    is_sell && currentPrice >= orderBook.first_price) {
                // uint256 priceVolume = 0;
                uint256 offerPointer = orderBook.prices[currentPrice].highest_priority;

                while (
                    offerPointer <= orderBook.prices[currentPrice].lowest_priority
                ) {
                    ordersPrices[counter] = currentPrice;
                    ordersVolumes[counter] = orderBook.prices[currentPrice].offer_list[offerPointer].offer_amount;

                    counter = counter.add(1);
                    if (offerPointer == orderBook.prices[currentPrice].offer_list[offerPointer].lower_priority){
                        break;
                    } else {
                        offerPointer = orderBook.prices[currentPrice].offer_list[offerPointer].lower_priority;
                    }
                }

                if (currentPrice == orderBook.prices[currentPrice].next_price) {
                    break;
                } else {
                    currentPrice = orderBook.prices[currentPrice].next_price;
                }
            }
        }

        return (ordersPrices, ordersVolumes);
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
                    //this offer cannot fulfill the amount

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
                    //this offer can fulfill the amount
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
                    //if this price has no offer left, remove it from order book
                    orderBook.number_of_prices = orderBook.number_of_prices.sub(1);
                    orderBook.prices[currentTradePrice].offer_length = 0;

                    if (
                        currentTradePrice == orderBook.prices[currentTradePrice].next_price ||
                        orderBook.prices[currentTradePrice].next_price == 0
                    ) {
                        //this price is the only price in the order book
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



    function getTokenBalance(address user, address _tokenAddress) public view returns(uint256) {
        ERC20API tokenLoaded = ERC20API(_tokenAddress);
        return tokenLoaded.balanceOf(user);
    }

    //string comparison
    function equals(bytes32 str1, bytes32 str2) public pure returns(bool) {
        return (str1 == str2);
    }

    function test(uint256 numTokens) public returns (bool){
        return true;
    }

    function getOrderBookInfo(address _token, bool is_sell) public view returns (string memory, uint256, uint256, uint256) {
        bytes32 book_name = "buy";
        if (is_sell) {
            book_name = "sell";
        }
        OrderBook storage orderBook = token_list[_token].Book[book_name];
        uint256 firstPrice = orderBook.first_price;
        uint256 no_prices = orderBook.number_of_prices;
        uint256 lastPrice = orderBook.last_price;
        string memory name = "buy";
        if (is_sell) {
            name = "sell";
        }
//        emit logOrderBook(name, no_prices, firstPrice, lastPrice);
        return (name, no_prices, firstPrice, lastPrice);
    }
    function getOffersInfo(address _token, bool is_sell, uint256 _price) public view returns (uint256, uint256, uint256, uint256) {
        bytes32 book_name = "buy";
        if (is_sell) {
            book_name = "sell";
        }
        OfferLinkedList storage offers = token_list[_token].Book[book_name].prices[_price];
        uint256  len = offers.offer_length;
        uint256 highest_p = offers.highest_priority;
        uint256 lowest_p = offers.lowest_priority;
        uint256 next_price = offers.next_price;
//        emit logOfferList(len, highest_p, lowest_p, next_price);
        return (len, highest_p, lowest_p, next_price);
    }

    event logBytes32(bytes32 _type);
    event loguint256(string logMessage, uint256 message);
    event logOffer(uint256 offer_amount, address offer_maker, uint256 higher_priority, uint256 lower_priority);


    event loguint256(uint256 message);
    event logString(string _string);
    event logOfferList(uint256 no_of_offers, uint256 highest_priority, uint256 lowest_priority, uint256 next_price);
    event logOrderBook(string book_name, uint256 no_of_prices, uint256 first_price, uint256 last_price);
}
