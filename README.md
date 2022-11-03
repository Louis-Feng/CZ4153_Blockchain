# CZ4153_Blockchain


## 1. Deployment
### 1.1Requirements
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
### 2.1 Cental Bank
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

### 4.2 Limit Order (Buy and Sell)

### 4.3 Order Cancellation 
