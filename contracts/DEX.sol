pragma solidity >=0.4.22 <0.9.0;

import "../utils/SafeMath.sol";
import "./ERC20API.sol";
import "./IERC20.sol";
import "./EthBank.sol";
import "./BasicToken.sol";


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
                currentOffer <= selfToken.Book[otherType].prices[currentPrice].lowest_priority &&
                remainingAmount > 0 &&
                !feedback[1]
            ) {

//                uint256 currentOfferAmount = selfToken.Book[otherType].prices[currentPrice]
//                .offer_list[currentOffer]
//                .offer_amount;
                emit loguint256("Current Offer Amount", selfToken.Book[otherType].prices[currentPrice]
                .offer_list[currentOffer]
                    .offer_amount);

                if(selfToken.Book[otherType].prices[currentPrice]
                .offer_list[currentOffer]
                .offer_amount >= remainingAmount){
                    emit logString("currentOfferAmount >= remainingAmount");
                    //fully filled
                    // currentOfferAmount >= remainingAmount
                    if(equals(_type,"buy")){
                        require(getTokenBalance(msg.sender, _baseToken) >= (remainingAmount.mul(currentPrice)), "buyer has insufficient Ether");
                        // approve exchange to move token to maker
                        baseToken.approve(
                            msg.sender,
                            (remainingAmount.mul(currentPrice))
                        );
                        emit logAddress(msg.sender);
                        // send token to maker
                        baseToken.transferFrom(
                            msg.sender,
                            selfToken.Book[otherType].prices[currentPrice]
                            .offer_list[currentOffer]
                            .offer_maker,
                            (remainingAmount.mul(currentPrice))
                        );
                        // approve exchange to move baseToken to maker
                        token.approve(
                            selfToken.Book[otherType].prices[currentPrice]
                            .offer_list[currentOffer]
                            .offer_maker,
                            remainingAmount.mul(1e18)
                        );
                        // send weth to taker
                        token.transferFrom(
                            selfToken.Book[otherType].prices[currentPrice]
                            .offer_list[currentOffer]
                            .offer_maker,
                            msg.sender,
                            remainingAmount.mul(1e18)
                        );
                    }else{
                        require(getTokenBalance(msg.sender, _tokenAddress) >= remainingAmount, "seller has insufficient token");
                        // approve exchange to move token to maker
                        token.approve(
                            msg.sender,
                            remainingAmount.mul(1e18)
                        );
                        emit logAddress(msg.sender);
                        // send token to maker
                        token.transferFrom(
                            msg.sender,
                            selfToken.Book[otherType].prices[currentPrice]
                            .offer_list[currentOffer]
                            .offer_maker,
                            remainingAmount.mul(1e18)
                        );
                        // approve exchange to move baseToken to maker
                        baseToken.approve(
                            selfToken.Book[otherType].prices[currentPrice]
                            .offer_list[currentOffer]
                            .offer_maker,
                            (remainingAmount.mul(currentPrice))
                        );
                        // send weth to taker
                        baseToken.transferFrom(
                            selfToken.Book[otherType].prices[currentPrice]
                            .offer_list[currentOffer]
                            .offer_maker,
                            msg.sender,
                            (remainingAmount.mul(currentPrice))
                        );
                    }

                            //question: should combine equal case to other else?
                            if(selfToken.Book[otherType].prices[currentPrice]
                            .offer_list[currentOffer]
                            .offer_amount == remainingAmount){
                                emit logString("currentOfferAmount == remainingAmount");

                                //removeOrder(_baseToken,_token,_type.equals("sell") ? true : false,currentPrice);
                                selfToken.Book[otherType].prices[currentPrice].offer_list[currentOffer]
                                .offer_amount = 0;

                                selfToken.Book[otherType].prices[currentPrice]
                                .highest_priority = selfToken.Book[otherType].prices[currentPrice]
                                .offer_list[currentOffer]
                                .lower_priority;

                                selfToken.Book[otherType].prices[currentPrice].offer_length = selfToken.Book[otherType].prices[currentPrice].offer_length.sub(1);

                                emit loguint256("Current Offer Amount", selfToken.Book[otherType].prices[currentPrice].offer_list[currentOffer]
                                    .offer_amount);
                                emit loguint256("Current Offer highest priority", selfToken.Book[otherType].prices[currentPrice]
                                    .highest_priority);
                                emit loguint256("Offer length", selfToken.Book[otherType].prices[currentPrice].offer_length);
                            }else{
                                emit logString("currentOfferAmount != remainingAmount");
                                //keep the order, modify the amount
                                selfToken.Book[otherType].prices[currentPrice].offer_list[currentOffer]
                                .offer_amount =
                                selfToken.Book[otherType].prices[currentPrice].offer_list[currentOffer].offer_amount
                                .sub(remainingAmount);

                                emit loguint256("Current Offer Amount", selfToken.Book[otherType].prices[currentPrice].offer_list[currentOffer]
                                    .offer_amount);
                                emit loguint256("Current Offer highest priority", selfToken.Book[otherType].prices[currentPrice]
                                    .highest_priority);
                                emit loguint256("Offer length", selfToken.Book[otherType].prices[currentPrice].offer_length);
                            }
                            remainingAmount = 0;



                }else{
                    emit logString("currentOfferAmount < remainingAmount");
                    //partially filled
                    //currentOfferAmount < remainingAmount
                    if(equals(_type,"buy")){
                        require(getTokenBalance(msg.sender, _baseToken) >= (selfToken.Book[otherType].prices[currentPrice]
                                .offer_list[currentOffer]
                                .offer_amount.mul(currentPrice)), "buyer has insufficient Ether");

                        // approve exchange to move token to maker
                        baseToken.approve(
                            msg.sender,

                                (selfToken.Book[otherType].prices[currentPrice]
                                .offer_list[currentOffer]
                                .offer_amount.mul(currentPrice))
                        );
                        // send token to maker
                        baseToken.transferFrom(
                            msg.sender,
                            selfToken.Book[otherType].prices[currentPrice]
                            .offer_list[currentOffer]
                            .offer_maker,
                                

                                (selfToken.Book[otherType].prices[currentPrice]
                                .offer_list[currentOffer]
                                .offer_amount.mul(currentPrice))
                        );
                        // approve exchange to move baseToken to maker
                        token.approve(
                            selfToken.Book[otherType].prices[currentPrice]
                            .offer_list[currentOffer]
                            .offer_maker,
                            selfToken.Book[otherType].prices[currentPrice]
                                .offer_list[currentOffer]
                                .offer_amount.mul(1e18)
                        );
                        // send weth to taker
                        token.transferFrom(
                            selfToken.Book[otherType].prices[currentPrice]
                            .offer_list[currentOffer]
                            .offer_maker,
                            msg.sender,
                            selfToken.Book[otherType].prices[currentPrice]
                                .offer_list[currentOffer]
                                .offer_amount.mul(1e18)
                        );
                    }else{
                        require(getTokenBalance(msg.sender, _tokenAddress) >= selfToken.Book[otherType].prices[currentPrice]
                        .offer_list[currentOffer]
                        .offer_amount, "seller has insufficient token");

                        // approve exchange to move token to maker
                        token.approve(
                            msg.sender,
                                selfToken.Book[otherType].prices[currentPrice]
                                .offer_list[currentOffer]
                                .offer_amount.mul(1e18)
                        );
                        // send token to maker
                        token.transferFrom(
                            msg.sender,
                            selfToken.Book[otherType].prices[currentPrice]
                            .offer_list[currentOffer]
                            .offer_maker,
                                selfToken.Book[otherType].prices[currentPrice]
                                .offer_list[currentOffer]
                                .offer_amount.mul(1e18)
                        );
                        // approve exchange to move baseToken to maker
                        baseToken.approve(
                            selfToken.Book[otherType].prices[currentPrice]
                            .offer_list[currentOffer]
                            .offer_maker,
                            (selfToken.Book[otherType].prices[currentPrice]
                                .offer_list[currentOffer]
                                .offer_amount.mul(currentPrice))
                        );
                        // send weth to taker
                        baseToken.transferFrom(
                            selfToken.Book[otherType].prices[currentPrice]
                            .offer_list[currentOffer]
                            .offer_maker,
                            msg.sender,
                            (selfToken.Book[otherType].prices[currentPrice]
                                .offer_list[currentOffer]
                                .offer_amount.mul(currentPrice))
                        );
                    }

                        //msg.sender has enough token on his account
                        //ethAmount = (currentOfferAmount.mul(currentPrice)).div(1e3);

                        //remove offer
                        //removeOrder(_baseToken,_token,_type.equals("sell") ? true : false,currentPrice);
                        remainingAmount = remainingAmount.sub(selfToken.Book[otherType].prices[currentPrice]
                        .offer_list[currentOffer]
                            .offer_amount);
                        selfToken.Book[otherType].prices[currentPrice]
                        .highest_priority = selfToken.Book[otherType].prices[currentPrice]
                        .offer_list[currentOffer]
                        .lower_priority;
                        selfToken.Book[otherType].prices[currentPrice].offer_list[currentOffer]
                        .offer_amount = 0;
                        selfToken.Book[otherType].prices[currentPrice].offer_length = selfToken.Book[otherType].prices[currentPrice].offer_length.sub(1);

                        emit loguint256("Current Offer Amount", selfToken.Book[otherType].prices[currentPrice].offer_list[currentOffer]
                            .offer_amount);
                        emit loguint256("Current Offer highest priority", selfToken.Book[otherType].prices[currentPrice]
                            .highest_priority);
                        emit loguint256("Offer length", selfToken.Book[otherType].prices[currentPrice].offer_length);




                }

                if (currentOffer == selfToken.Book[otherType].prices[currentPrice].lowest_priority &&
                    selfToken.Book[otherType].prices[currentPrice].offer_list[currentOffer].offer_amount == 0
                ) {
                    emit logString("no more order at this price");
                    //no more order at this price
                    selfToken.Book[otherType].number_of_prices = selfToken.Book[otherType].number_of_prices.sub(1);
                    selfToken.Book[otherType].prices[currentPrice].offer_length = 0;

                    if (
                        currentPrice == selfToken.Book[otherType].prices[currentPrice].next_price ||
                        selfToken.Book[otherType].prices[currentPrice].next_price == 0
                    ) {
                        emit logString("no more order");
                        selfToken.Book[otherType].prices[currentPrice].next_price = 0;
                        selfToken.Book[otherType].number_of_prices = 0;
                        selfToken.Book[otherType].first_price = 0;
                        selfToken.Book[otherType].last_price = 0;
                        return feedback;
                    } else {
                        selfToken.Book[otherType].first_price = selfToken.Book[otherType].prices[currentPrice].next_price;
                        emit loguint256("first price change to next price", selfToken.Book[otherType].first_price);
                    }
                    break;
                }
                currentOffer = selfToken.Book[otherType].prices[currentPrice].offer_list[currentOffer].lower_priority;
                //这个price的order全没了
                //return feedback;
            }
            currentPrice = selfToken.Book[otherType].first_price;
            emit loguint256("current price updated", currentPrice);

        }
        if (remainingAmount == 0) {
            feedback[0] = true;
        }
        //emit MarketResult(feedback[0], feedback[1], feedback[2]);
        return feedback;
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
        uint256 _price,
        uint256 _priority
    ) public {
        bytes32 book_name = "buy";
        if (is_sell) {
            book_name = "sell";
        }
        OrderBook storage orderBook = token_list[_token].Book[book_name];

        //This function assume this is a valid price
        // remove all offer_list for this price

        uint256 counter = orderBook.prices[_price].highest_priority;
        while (counter <= orderBook.prices[_price].lowest_priority ) {
            if (
                orderBook.prices[_price].offer_list[counter].offer_maker ==
                msg.sender && counter == _priority

            ) {

                orderBook.prices[_price].offer_length = orderBook.prices[_price]
                .offer_length
                .sub(1);

                if (orderBook.prices[_price].highest_priority == orderBook.prices[_price].lowest_priority) {
                   //If this is the only offer left
                    orderBook.prices[_price].highest_priority =0;
                    orderBook.prices[_price].lowest_priority = 0;
                    orderBook.prices[_price].offer_length = 0;

                } else if (
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
            orderBook.prices[_price].offer_length == 0
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

    function getUserOrders(address _token, bool is_sell)
    public
    view
    returns (uint256[] memory, uint256[] memory, uint256[] memory)
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
        uint256[] memory ordersPriorities = new uint256[](no_total_offer);

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
                    if (msg.sender == orderBook.prices[currentPrice].offer_list[offerPointer].offer_maker) {
                        ordersPrices[counter] = currentPrice;
                        ordersVolumes[counter] = orderBook.prices[currentPrice].offer_list[offerPointer].offer_amount;
                        ordersPriorities[counter] = offerPointer;
                    }

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

        return (ordersPrices, ordersVolumes, ordersPriorities);
    }

    function executeLimitOrder (
        address _basicToken,
        address _token,
        uint256 _price,
        uint256 _amount,
        bool _isBuy
    ) public {

        Token storage currentToken = token_list[_token]; // find the desired Token object.
        IERC20 basicToken = IERC20(_basicToken);
        IERC20 desiredToken = IERC20(_token);

        if (_isBuy)
        {   require(
                basicToken.balanceOf(msg.sender) >= (_price.mul(_amount)),
                "executeLimitOrder: the WETH balance < ETH required."
            );
        } else {
            require(
                desiredToken.balanceOf(msg.sender) >= _amount,
                "executeLimitOrder: the token amount balance < amount required."
            );
        }

        bytes32 orderType;

        if (_isBuy) orderType = "sell";
        else orderType = "buy";
        //OrderBook storage orderBook = (_isBuy ? currentToken.Book["sell"]:currentToken.Book["buy"]);
        // choose the desired order book: buy -> sell order book; sell -> buy order book

        // check if the proposed order price is able to match any order price
        if (
            (_isBuy && _price < currentToken.Book[orderType].first_price) || // buy order price smaller than minimum sell price
            (!_isBuy && _price > currentToken.Book[orderType].first_price) || // sell order price higher than maximum buy price
            currentToken.Book[orderType].number_of_prices == 0 // there is no order to match.
        ) {
            storeOrder(_token, !_isBuy, _price, _amount, msg.sender); // store the order and delay its execution
            //emit OrderStored(msg.sender, _token, _price, _amount, _isBuy);
        } else {

            uint256 totalEtherToTrade = 0;
            uint256 amountLeftToTrade = _amount;
            uint256 currentTradePrice = currentToken.Book[orderType].first_price;
            uint256 offerPtr;

            while (currentTradePrice != 0 && amountLeftToTrade > 0) {
                if ((_isBuy && _price < currentTradePrice) || (!_isBuy && _price > currentTradePrice)) {
                    storeOrder(_token, !_isBuy, _price, amountLeftToTrade, msg.sender);
                    //emit OrderStored(msg.sender, _token, _price, _amount, _isBuy);
                    break;
                }
                offerPtr = currentToken.Book[orderType].prices[currentTradePrice].highest_priority;
                // initiate the helper offer pointer to traverse the price node.
                //emit OfferPtrUpdated(offerPtr);
                while (offerPtr <= currentToken.Book[orderType].prices[currentTradePrice].lowest_priority
                    && amountLeftToTrade > 0) {
                    //emit OfferAmountLessThanTradeAmount(currentToken.Book[orderType].prices[currentTradePrice].offer_list[offerPtr].offer_amount <= amountLeftToTrade);
                    if (currentToken.Book[orderType].prices[currentTradePrice].offer_list[offerPtr].offer_amount <= amountLeftToTrade) {

                        totalEtherToTrade = (currentToken.Book[orderType].prices[currentTradePrice].offer_list[offerPtr].offer_amount).mul(currentTradePrice);
                        //this offer cannot fulfill the amount

                        if (_isBuy)
                        {
                            require(
                                basicToken.balanceOf(msg.sender) >= totalEtherToTrade,
                                "executeLimitOrder: insufficient ether balance."
                            );
                            // approve exchange to move token to maker
                            basicToken.approve(msg.sender, totalEtherToTrade);

                            basicToken.transferFrom(
                                msg.sender,
                                currentToken.Book[orderType].prices[currentTradePrice].offer_list[offerPtr].offer_maker,
                                totalEtherToTrade
                            );

                            desiredToken.approve(currentToken.Book[orderType].prices[currentTradePrice].offer_list[offerPtr].offer_maker, currentToken.Book[orderType].prices[currentTradePrice].offer_list[offerPtr].offer_amount.mul(1e18));

                            desiredToken.transferFrom(
                                currentToken.Book[orderType].prices[currentTradePrice].offer_list[offerPtr].offer_maker,
                                msg.sender,
                                currentToken.Book[orderType].prices[currentTradePrice].offer_list[offerPtr].offer_amount.mul(1e18)
                            );
                        } else {
                            require(
                                basicToken.balanceOf(currentToken.Book[orderType].prices[currentTradePrice].offer_list[offerPtr].offer_maker) >= totalEtherToTrade,
                                "executeLimitOrder: insufficient ether balance."
                            );
                            // approve exchange to move token to maker
                            basicToken.approve(currentToken.Book[orderType].prices[currentTradePrice].offer_list[offerPtr].offer_maker, totalEtherToTrade);

                            basicToken.transferFrom(
                                currentToken.Book[orderType].prices[currentTradePrice].offer_list[offerPtr].offer_maker,
                                msg.sender,
                                totalEtherToTrade
                            );

                            desiredToken.approve(msg.sender, currentToken.Book[orderType].prices[currentTradePrice].offer_list[offerPtr].offer_amount.mul(1e18));

                            desiredToken.transferFrom(
                                msg.sender,
                                currentToken.Book[orderType].prices[currentTradePrice].offer_list[offerPtr].offer_maker,
                                currentToken.Book[orderType].prices[currentTradePrice].offer_list[offerPtr].offer_amount.mul(1e18)
                            );
                        }

                        amountLeftToTrade = amountLeftToTrade.sub(currentToken.Book[orderType].prices[currentTradePrice].offer_list[offerPtr].offer_amount);
                        currentToken.Book[orderType].prices[currentTradePrice].offer_list[offerPtr].offer_amount = 0;
                        currentToken.Book[orderType].prices[currentTradePrice].offer_length = currentToken.Book[orderType].prices[currentTradePrice].offer_length.sub(1);
                        currentToken.Book[orderType].prices[currentTradePrice].highest_priority = currentToken.Book[orderType].prices[currentTradePrice].offer_list[offerPtr].lower_priority;
                    }
                    else {
                        //this offer can fulfill the amount
                        totalEtherToTrade = amountLeftToTrade.mul(currentTradePrice);

                        if (_isBuy) {

                            // approve exchange to move token to maker

                            require(
                                basicToken.balanceOf(msg.sender) >= totalEtherToTrade,
                                "executeLimitOrder: insufficient ether balance."
                            );

                            basicToken.approve(msg.sender, totalEtherToTrade);

                            basicToken.transferFrom(
                                msg.sender,
                                currentToken.Book[orderType].prices[currentTradePrice].offer_list[offerPtr].offer_maker,
                                totalEtherToTrade
                            );

                            desiredToken.approve(currentToken.Book[orderType].prices[currentTradePrice].offer_list[offerPtr].offer_maker, amountLeftToTrade.mul(1e18));

                            desiredToken.transferFrom(
                                currentToken.Book[orderType].prices[currentTradePrice].offer_list[offerPtr].offer_maker,
                                msg.sender,
                                amountLeftToTrade.mul(1e18)
                            );
                        } else {

                            require(
                                basicToken.balanceOf(currentToken.Book[orderType].prices[currentTradePrice].offer_list[offerPtr].offer_maker) >= totalEtherToTrade,
                                "executeLimitOrder: insufficient ether balance."
                            );

                            basicToken.approve(currentToken.Book[orderType].prices[currentTradePrice].offer_list[offerPtr].offer_maker, totalEtherToTrade);

                            basicToken.transferFrom(
                                currentToken.Book[orderType].prices[currentTradePrice].offer_list[offerPtr].offer_maker,
                                msg.sender,
                                totalEtherToTrade
                            );

                            desiredToken.approve(msg.sender, amountLeftToTrade.mul(1e18));

                            desiredToken.transferFrom(
                                msg.sender,
                                currentToken.Book[orderType].prices[currentTradePrice].offer_list[offerPtr].offer_maker,
                                amountLeftToTrade.mul(1e18)
                            );
                        }

                        currentToken.Book[orderType].prices[currentTradePrice].offer_list[offerPtr].offer_amount =
                        currentToken.Book[orderType].prices[currentTradePrice].offer_list[offerPtr].offer_amount.sub(amountLeftToTrade);
                        amountLeftToTrade = 0;
                    }

                    if (offerPtr == currentToken.Book[orderType].prices[currentTradePrice].lowest_priority &&
                        currentToken.Book[orderType].prices[currentTradePrice].offer_list[offerPtr].offer_amount == 0
                    ) {
                        //if this price has no offer left, remove it from order book
                        currentToken.Book[orderType].number_of_prices = currentToken.Book[orderType].number_of_prices.sub(1);
                        currentToken.Book[orderType].prices[currentTradePrice].offer_length = 0;

                        if (
                            currentTradePrice == currentToken.Book[orderType].prices[currentTradePrice].next_price ||
                            currentToken.Book[orderType].prices[currentTradePrice].next_price == 0
                        ) {
                            //this price is the only price in the order book
                            currentToken.Book[orderType].prices[currentTradePrice].next_price = 0;
                            currentToken.Book[orderType].number_of_prices = 0;
                            currentToken.Book[orderType].first_price = 0;
                            currentToken.Book[orderType].last_price = 0;
                        } else {
                            currentToken.Book[orderType].first_price = currentToken.Book[orderType].prices[currentTradePrice].next_price;
                        }
                        break;
                    }
                    if (offerPtr == currentToken.Book[orderType].prices[currentTradePrice].offer_list[offerPtr].lower_priority)
                        break;
                    else
                        offerPtr = currentToken.Book[orderType].prices[currentTradePrice].offer_list[offerPtr].lower_priority;
                }
                currentTradePrice = currentToken.Book[orderType].first_price;
                if (currentTradePrice == 0 && amountLeftToTrade != 0) {
                    storeOrder(_token, !_isBuy, _price, amountLeftToTrade, msg.sender);
                    //emit OrderStored(msg.sender, _token, _price, _amount, _isBuy);
                    break;
                }
            }
        }
    }



    function getTokenBalance(address user, address _tokenAddress) public view returns(uint256) {
        IERC20 tokenLoaded = IERC20(_tokenAddress);
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


    function swapBasicToken(address bank_address, address token_address) public payable {
        Bank ethBank = Bank(bank_address);
        ethBank.deposit.value(msg.value)(msg.sender);
        BasicToken token = BasicToken(token_address);
        token.mint(msg.sender, msg.value);
        
    }
    function withdrawEth(address bank_address, address token_address, uint value) public {
        BasicToken token = BasicToken(token_address);
        token.burn(msg.sender, value);
        Bank ethBank = Bank(bank_address);
        ethBank.withdraw(value, msg.sender);
        
    }



    event logBytes32(bytes32 _type);
    event loguint256(string logMessage, uint256 message);
    event logOffer(uint256 offer_amount, address offer_maker, uint256 higher_priority, uint256 lower_priority);

    event logAddress(address _address);
    event loguint256(uint256 message);
    event logString(string _string);
    event logOfferList(uint256 no_of_offers, uint256 highest_priority, uint256 lowest_priority, uint256 next_price);
    event logOrderBook(string book_name, uint256 no_of_prices, uint256 first_price, uint256 last_price);
}
