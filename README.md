# CZ4153_Blockchain


## 1. Deployment
### 1.1 Requirements
- Truffle v5.6.1 (core: 5.6.1)

- Ganache v7.4.4
- Solidity - 0.5.16 (solc-js)
- Node v16.16.0
- Web3.js v1.7.4
- npm

### 1.2 Setup of Frontend
1.  `cd dex-fronted`
2. `npm install`

### 1.3 Setup of Ganache and Metamask
1. open local ganache, create a new project by importing the truffle-config.js
2. make sure the host is "127.0.0.1" and the port is 7545
3. open Metamask on Chrome. Go to Network -> Add Network to add Ganache network.
<img width="314" alt="Screenshot 2022-11-03 at 11 43 39 AM" src="https://user-images.githubusercontent.com/61575406/199643701-1a2a02c5-ad6f-43f5-ba3e-e31d63004bff.png">
4. Set New RPC URL = HTTP://127.0.0.1:7545, Chain ID = 1337 Currency symbol = ETH.
<img width="361" alt="Screenshot 2022-11-03 at 11 45 20 AM" src="https://user-images.githubusercontent.com/61575406/199643878-d1c458be-a3a0-4b18-8b50-3a261d8f6ddd.png">
5. Import account[0] of Ganache to Metamask by Accounts -> Import Accounts (with the private key of accounts[0])
<img width="348" alt="Screenshot 2022-11-03 at 11 47 58 AM" src="https://user-images.githubusercontent.com/61575406/199644122-0c18991f-30c2-4f0e-8d2f-69009e343ba3.png">
accounts[0] will be the issuer of Token A, Token B and Token C.

### 1.4 Build Project
1. change to the root folder and run `truffle migrate --reset`
2. `cd dex-fronted`
3. `npm run start`
4. go to localhost:3000

## 2. Roles
### 2.1 Central Bank
To get BasicToken to execute trade in our smart contracts, the user needs to use his ETH and swap BasicToken with the central bank (1 ETH = 1 BasicToken). The user can withdraw their BasicToken and get back corresponding amount of ETH
### 2.2 Issuer 
The Ganache accounts[0] will be the issuer of Token A, B and C in the Ganache network, with a total supply of 1,000,000 each. The issuer will sell these tokens to the market at a reasonable price. 
### 2.3 Users
The users can be other accounts in the Ganache network. The user can use their BasicToken to buy Token A, B or C from the issuer or other users. The users can sell thier token at hand to other users subsequently.

## 3. Order book
In this project, we are using a **central limit order book (CLOB)**. It matches customer orders (e.g. bids and offers) on a 'price time priority' basis.
- A token list will be used to store all supported tokens. Each token will have a buy order book and sell order book
- The sell order book stores prices in ascending order, i.e.  first_price = lowest price and last_price = highest price
- The buy order book stores prices in descending order, i.e.  first_price = highest price and last_price = lowest price
- At each price, the orders are stored using a self-defined double linked list for easy insertion and deletion.
- When an order is matched and fully executed, the order pointer will point to the next order at this price (inserted after current order)
- When orders at certain price runs out, the price pointer will point to the next price
- Orders at the same price are stored on a First-In-First-Out basis. Therefore, the priority is based on order price and order age
![Flowchart](https://user-images.githubusercontent.com/61575406/199647068-26c41cdb-c9bc-434d-a776-6f12db67e3c9.jpg)

## 4. Supported Trades
### 4.1 Market Order (Buy and Sell)
A market order is an instruction by a user to a broker to buy or sell tokens at the best available price in the current financial market. The user will only input amount of token he wants, and the order will be executed as long as there is enough amount of orders.
![Flowchart (8)](https://user-images.githubusercontent.com/61575406/200024090-385b5094-a3d1-4e14-a21e-72f6d2e7db64.jpg)



### 4.2 Limit Order (Buy and Sell)
The order is placed "at the limit": Limit orders set the maximum or minimum price at which you are willing to buy or sell. The user will input the price and amount of the order. For buy limit order, it will only be executed when the sell order's price is lower than the input price. For sell limit order, it will only be executed when the buy order's price is higher than the input price. 
![Flowchart (7)](https://user-images.githubusercontent.com/61575406/200022086-f7aa40d3-69ee-4c48-96f2-ed5378f9e985.jpg)




### 4.3 Order Cancellation 
At a given price, each offer stored has a unique priority. Therefore, given price and priority, a unique offer can be removed. On the webpage, users can see all the buy/sell offers they made and choose to remove any one of the unfulfilled/partially fulfilled offers.
The lower_priority pointer of previous offer will point to the next offer while the higher_priority pointer of the next offer will point to the previous offer (linked list element removal process).
![Flowchart (3)](https://user-images.githubusercontent.com/61575406/199650901-a7f813ae-0dde-4f46-8011-6093e6049756.jpg)

## 5. DEX Features
### 5.1 Integration with Metamask & User Profile
The DEX is integrated with Metamask and is able to display all the token amounts the user holds.
![user profile](https://user-images.githubusercontent.com/61575406/199879657-5abb2010-f0b5-4764-8b10-1e999f036b99.png)

### 5.2 Basic Token & ETH Swap
<img width="632" alt="Screenshot 2022-11-04 at 11 37 03 AM" src="https://user-images.githubusercontent.com/61575406/199879998-4db59e7e-e3f8-4379-8ab2-f0ea110193f3.png">

### 5.3 Basic Token Withdraw
<img width="633" alt="Screenshot 2022-11-04 at 11 38 03 AM" src="https://user-images.githubusercontent.com/61575406/199880194-3b4a7ff1-8727-4935-b3cc-00212d38db5d.png">

### 5.4 Trades
#### 5.4.1 Limit Order (Buy/Sell)
![Token Selection](https://user-images.githubusercontent.com/61575406/199880511-0b61c259-99ef-40c6-9915-1c58b9d18b9d.png)
Select token type to trade
![Input Trade](https://user-images.githubusercontent.com/61575406/199880505-04d4f313-0ca1-4a02-8844-dc649354a40f.png)
Input Price & Amount of Limit Order

#### 5.4.2 Market Order (Buy/Sell)
![market order](https://user-images.githubusercontent.com/61575406/199880797-196e1420-e163-4c44-943b-ebb0ccbc6e3a.png)

### 5.5 Display of Global Order Book
The DEX is able to display a global order book which contains the orders from all users in the system.
![Global order book](https://user-images.githubusercontent.com/61575406/199880913-5da2d43a-86a2-4c2f-9814-33ae63f61a93.png)

### 5.6 Display of User Order Book
The DEX is able to display a user order book which only contains the orders made by the current user
![user order book](https://user-images.githubusercontent.com/61575406/199881031-afbeb4f6-4c14-4863-b0ea-bed2d5cd58a7.png)

### 5.7 Cancellation of Trade
The DEX allows the user to cancel his own order if the order has not been executed yet
![user order book](https://user-images.githubusercontent.com/61575406/199881272-66bf54d4-b158-4c72-9d24-d8e20dc1bc66.png)


.

