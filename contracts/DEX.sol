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

//    event test(uint256 s);

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
        token_list[_token].Book[book_name].prices[_price].offer_length = token_list[_token]
        .Book[book_name].prices[_price]
        .offer_length
        .add(1);

//        emit test(_price);
        if (token_list[_token].Book[book_name].prices[_price].offer_length == 1) {
            token_list[_token].Book[book_name].prices[_price].highest_priority = 1;
            token_list[_token].Book[book_name].prices[_price].lowest_priority = 1;
            token_list[_token].Book[book_name].number_of_prices = token_list[_token]
            .Book[book_name].number_of_prices
            .add(1);

            token_list[_token].Book[book_name].prices[_price].offer_list[token_list[_token]
            .Book[book_name].prices[_price]
            .offer_length] = Offer(_amount, _maker, 0, 1);

            uint256 firstPrice = token_list[_token].Book[book_name].first_price;
            uint256 lastPrice = token_list[_token].Book[book_name].last_price;

            if (lastPrice == 0 || is_sell && lastPrice < _price || !is_sell && lastPrice > _price) {
                if (firstPrice == 0) {
                    token_list[_token].Book[book_name].first_price = _price;
                    token_list[_token].Book[book_name].prices[_price].next_price = _price;
                } else {
                    token_list[_token].Book[book_name].prices[lastPrice]
                    .next_price = _price;
                    token_list[_token].Book[book_name].prices[_price].next_price = _price;
                }
                token_list[_token].Book[book_name].last_price = _price;
            } else if (is_sell && firstPrice > _price || !is_sell && firstPrice > _price) {
                token_list[_token].Book[book_name].prices[_price]
                .next_price = firstPrice;
                token_list[_token].Book[book_name].first_price = _price;
            } else {
                uint256 currentPrice = token_list[_token].Book[book_name].first_price;
                bool inserted = false;
                while (currentPrice > 0 && !inserted) {
                    if (
                        is_sell &&
                        currentPrice < _price &&
                        token_list[_token].Book[book_name].prices[currentPrice].next_price > _price
                        ||
                        !is_sell &&
                        currentPrice > _price &&
                        token_list[_token].Book[book_name].prices[currentPrice].next_price < _price
                    ) {
                        token_list[_token].Book[book_name].prices[_price]
                        .next_price = token_list[_token].Book[book_name].prices[currentPrice]
                        .next_price;

                        token_list[_token].Book[book_name].prices[currentPrice]
                        .next_price = _price;
                        inserted = true;
                    }
                    currentPrice = token_list[_token].Book[book_name].prices[currentPrice]
                    .next_price;
                }
            }

        } else {
            uint256 currentLowest = token_list[_token].Book[book_name].prices[_price]
            .lowest_priority
            .add(1);
            token_list[_token].Book[book_name].prices[_price].offer_list[token_list[_token]
            .Book[book_name].prices[_price]
            .offer_length] = Offer(
                _amount,
                _maker,
                token_list[_token].Book[book_name].prices[_price].lowest_priority,
                currentLowest
            );
            token_list[_token].Book[book_name].prices[_price].offer_list[token_list[_token]
            .Book[book_name].prices[_price]
            .lowest_priority]
            .lower_priority = currentLowest;
            token_list[_token].Book[book_name].prices[_price].lowest_priority = currentLowest;
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
        ERC20API token = ERC20API(_token);
        ERC20API baseToken = ERC20API(_baseToken);
        // remove all offer_list for this price
        uint256 counter = orderBook.prices[_price].highest_priority;
        while (counter <= orderBook.prices[_price].lowest_priority) {
            if (
                orderBook.prices[_price].offer_list[counter].offer_maker ==
                msg.sender
            ) {
                if (!is_sell) {
                    baseToken.reduceAllowance(
                        msg.sender,
                        address(this),
                        (
                        (
                        orderBook.prices[_price].offer_list[counter]
                        .offer_amount
                        .mul(_price)
                        )
                        .div(1e18)
                        )
                    );
                } else {
                    token.reduceAllowance(
                        msg.sender,
                        address(this),
                        orderBook.prices[_price].offer_list[counter].offer_amount
                    );
                }

//                totalOffers = totalOffers.add(1);
                orderBook.prices[_price].offer_length = orderBook.prices[_price]
                .offer_length
                .sub(1);

                if (
                    orderBook.prices[_price].offer_list[counter]
                    .higher_priority == 0
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
                    orderBook.prices[_price].offer_list[counter]
                    .lower_priority ==
                    orderBook.prices[_price].lowest_priority
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
                orderBook.first_price = 0;
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

        uint256[] memory ordersPrices = new uint256[](token_list[_token].Book[book_name].number_of_prices);
        uint256[] memory ordersVolumes = new uint256[](token_list[_token].Book[book_name].number_of_prices);

        uint256 currentPrice = orderBook.first_price;
        uint256 counter = 0;

        if (orderBook.first_price > 0) {
            while (!is_sell && currentPrice <= orderBook.first_price ||
                    is_sell && currentPrice >= orderBook.first_price) {
                // uint256 priceVolume = 0;
                uint256 offerPointer = orderBook.prices[currentPrice].highest_priority;

                while (
                    offerPointer <= orderBook.prices[currentPrice].offer_length
                ) {
                    // priceVolume = priceVolume.add(
                    //     loadedToken.buyBook[buyPrice].offers[offerPointer]
                    //         .amount
                    // );

                    ordersPrices[counter] = currentPrice;
                    ordersVolumes[counter] = orderBook.prices[currentPrice].offer_list[offerPointer].offer_amount;


                    counter = counter.add(1);
                    offerPointer = offerPointer.add(1);
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
//        } else {
//            ERC20API baseToken = ERC20API(_baseToken);
//            uint256 counter = loadedToken.buyBook[_price].highest_priority;
//            while (counter <= loadedToken.buyBook[_price].offer_length) {
//                if (
//                    loadedToken.buyBook[_price].offer_list[counter].offer_maker ==
//                    msg.sender
//                ) {
//                    baseToken.reduceAllowance(
//                        msg.sender,
//                        address(this),
//                        (
//                        (
//                        orderBook.prices[_price].offer_list[counter]
//                        .offer_amount
//                        .mul(_price)
//                        )
//                        .div(1e18)
//                        )
//                    );
//
//                    totalOffers = totalOffers.add(1);
//                    loadedToken.buyBook[_price].offer_length = loadedToken
//                    .buyBook[_price]
//                    .offer_length
//                    .sub(1);
//
//                    if (
//                        loadedToken.buyBook[_price].offer_list[counter]
//                        .higher_priority == 0
//                    ) {
//                        // if this offer is first in queue
//                        loadedToken.buyBook[_price]
//                        .highest_priority = loadedToken.buyBook[_price]
//                        .offer_list[counter]
//                        .lower_priority;
//                        loadedToken.buyBook[_price].offer_list[loadedToken
//                        .buyBook[_price]
//                        .offer_list[counter]
//                        .lower_priority]
//                        .higher_priority = 0;
//                    } else if (
//                        loadedToken.buyBook[_price].offer_list[counter]
//                        .lower_priority ==
//                        loadedToken.buyBook[_price].lowest_priority
//                    ) {
//                        // if this offer is last in queue
//                        loadedToken.buyBook[_price].lowest_priority = loadedToken
//                        .buyBook[_price]
//                        .offer_list[counter]
//                        .higher_priority;
//                        loadedToken.buyBook[_price].offer_list[loadedToken
//                        .buyBook[_price]
//                        .offer_list[counter]
//                        .higher_priority]
//                        .lower_priority = loadedToken.buyBook[_price]
//                        .lowest_priority;
//                    } else {
//                        // if offer is in between offer_list
//                        loadedToken.buyBook[_price].offer_list[loadedToken
//                        .buyBook[_price]
//                        .offer_list[counter]
//                        .higher_priority]
//                        .lower_priority = loadedToken.buyBook[_price]
//                        .offer_list[counter]
//                        .lower_priority;
//                        loadedToken.buyBook[_price].offer_list[loadedToken
//                        .buyBook[_price]
//                        .offer_list[counter]
//                        .lower_priority]
//                        .higher_priority = loadedToken.buyBook[_price]
//                        .offer_list[counter]
//                        .higher_priority;
//                    }
//                }
//                if (counter == loadedToken.buyBook[_price].lowest_priority) {
//                    break;
//                }
//                counter = loadedToken.buyBook[_price].offer_list[counter]
//                .lower_priority;
//            }
//
//            if (
//                loadedToken.buyBook[_price].offer_length == 0 && totalOffers > 0
//            ) {
//                // if no. of offer_list for this price is 0, this price is empty, remove this order book
//                if (
//                    loadedToken.buyBook[_price].lowerPrice == 0 &&
//                    loadedToken.buyBook[_price].higherPrice == _price
//                ) {
//                    // if this is the only price left
//                    loadedToken.buyBook[_price].offer_length = 0;
//                    loadedToken.buyBook[_price].higherPrice = 0;
//                    loadedToken.buyBook[_price].lowerPrice = 0;
//                    loadedToken.amountOfBuyPrices = 0;
//                    loadedToken.minBuyPrice = 0;
//                    loadedToken.maxBuyPrice = 0;
//                } else if (loadedToken.buyBook[_price].lowerPrice == 0) {
//                    // if this is the first price in order book list
//                    loadedToken.buyBook[loadedToken.buyBook[_price].higherPrice]
//                    .lowerPrice = 0;
//                    loadedToken.minBuyPrice = loadedToken.buyBook[_price]
//                    .higherPrice;
//                    loadedToken.amountOfBuyPrices = loadedToken
//                    .amountOfBuyPrices
//                    .sub(1);
//                } else if (loadedToken.buyBook[_price].higherPrice == _price) {
//                    // if this is the last price in order book list
//                    loadedToken.buyBook[loadedToken.buyBook[_price].lowerPrice]
//                    .higherPrice = loadedToken.buyBook[_price].lowerPrice;
//                    loadedToken.maxBuyPrice = loadedToken.buyBook[_price]
//                    .lowerPrice;
//                    loadedToken.amountOfBuyPrices = loadedToken
//                    .amountOfBuyPrices
//                    .sub(1);
//                } else {
//                    // if we are in between order book list
//                    loadedToken.buyBook[loadedToken.buyBook[_price].lowerPrice]
//                    .higherPrice = loadedToken.buyBook[_price].higherPrice;
//                    loadedToken.buyBook[loadedToken.buyBook[_price].higherPrice]
//                    .lowerPrice = loadedToken.buyBook[_price].lowerPrice;
//                    loadedToken.amountOfBuyPrices = loadedToken
//                    .amountOfBuyPrices
//                    .sub(1);
//                }
//            }
//        }


}
