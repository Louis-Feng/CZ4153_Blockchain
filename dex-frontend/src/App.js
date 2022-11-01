// import logo from './logo.svg';
import "./App.css";
import React, { Component } from "react";
// import React from "react"
import Web3 from "web3";
import BasicTokenJS from "./contracts/BasicToken.json";
import TokenAJS from "./contracts/TokenA.json";
import TokenBJS from "./contracts/TokenB.json";
import TokenCJS from "./contracts/TokenC.json";
import DexJS from "./contracts/DEX.json";
import UserAccountInfo from "./UserAccountInfo";
import BankJS from "./contracts/Bank.json";
import detectEthereumProvider from "@metamask/detect-provider";
import { BrowserRouter, Router, Routes, Route, Link } from "react-router-dom";
import AllUserOffers from "./AllUserOffers";
import AllGlobalOffers from "./AllGlobalOffers";
import SwapBasicToken from "./SwapBasicToken";
import UserPage from "./UserPage";
import WithDrawETH from "./WithdrawETH";
import TradeToken from "./TradeToken";
// import {Link} from "react-router-dom";

// import BasicTokenJS from "../../build/contracts/BasicToken.json";
// import { ethers } from 'ethers';
// import { parseEther, formatEther } from '@ethersproject/units';

class App extends Component {
  constructor(props) {
    super(props);
    this.state = {
      web3Provider: null,
      userAddress: "0x0",
      bank: {},
      token: {},
      tokensToTrade: {
        tokenA: {},
      },
      dex: {},
      is_loading: true,
    };
  }

  componentDidMount() {
    this.initiateWeb3();
    // this.loadUserAddress();
  }

  componentDidUpdate(prevProps, prevState) {
    if (prevState.web3Provider !== this.state.web3Provider) {
      this.loadUserAddress();
    }
    if (prevState.userAddress !== this.state.userAddress) {
      this.loadContracts();
    }
  }

  async initiateWeb3() {
    // const provider = new ethers.providers.Web3Provider(window.ethereum);
    // const signer = provider.getSigner();
    var web3 = null;
    console.log("web3");
    console.log(this.state.web3Provider);

    if (window.ethereum) {
      if (window.ethereum) {
        // this.setState({web3Provider: window.ethereum})
        web3 = new Web3(window.ethereum);
        // Request account access
        try {
          await window.ethereum.request({ method: "eth_requestAccounts" });
          window.ethereum.on("accountsChanged", function () {
            window.ethereum.request(
              { method: "eth_requestAccounts" },
              function (error, accounts) {
                window.location.reload();
              }
            );
          });
        } catch (error) {
          // User denied account access...
          console.error("User denied account access");
        }
        // Legacy dapp browsers...
      } else if (window.web3) {
        web3 = new Web3(window.web3.currentProvider);
        // this.setState({web3Provider: window.web3.currentProvider});
      } else {
        window.alert(
          "Non-Ethereum browser detected. You should consider trying MetaMask!"
        );
        // If no injected web3 instance is detected, fall back to Ganache
        // window.web3 = new Web3.providers.HttpProvider('http://localhost:7545');
        let provider = new Web3.providers.HttpProvider("http://localhost:7545");
        web3 = new Web3(provider);
      }
    }
    // const web3 = new Web3(this.state.web3Provider);
    this.setState({ web3Provider: web3 });
  }

  async loadUserAddress() {
    console.log("Address");

    const accounts = await window.ethereum.request({
      method: "eth_requestAccounts",
    });
    // const accounts = await web3.eth.getAccounts();
    this.setState({ userAddress: accounts[0] });
  }

  async loadContracts() {
    console.log("contract");

    // const accounts = await web3.eth.getAccounts();
    // this.setState({ userAddress: accounts[0] });
    // setTimeout(() => {
    //   console.log(this.state.userAddress);
    // }, 1
    // );
    console.log(this.state.web3Provider);
    const web3 = this.state.web3Provider;
    const networkId = await web3.eth.net.getId();
    const BasicTokenAddress = BasicTokenJS.networks[networkId].address;
    const TokenAAddress = TokenAJS.networks[networkId].address;
    const TokenBAddress = TokenBJS.networks[networkId].address;
    const TokenCAddress = TokenCJS.networks[networkId].address;
    const DexAddress = DexJS.networks[networkId].address;
    const token = new web3.eth.Contract(BasicTokenJS.abi, BasicTokenAddress);
    const tokenA = new web3.eth.Contract(TokenAJS.abi, TokenAAddress);
    const tokenB = new web3.eth.Contract(TokenBJS.abi, TokenBAddress);
    const tokenC = new web3.eth.Contract(TokenCJS.abi, TokenCAddress);
    const dex = new web3.eth.Contract(DexJS.abi, DexAddress);
    const BankAddress = BankJS.networks[networkId].address;
    const bank = new web3.eth.Contract(BankJS.abi, BankAddress);

    this.setState({ token, dex, bank });
    this.setState({
      tokensToTrade: {
        tokenA,
        tokenB,
        tokenC,
      },
    });
    this.setState({ is_loading: false });

    // const tokenBalance = await token.methods.balanceOf(this.state.userAddress).call()
    // const tokenABalance = await tokenA.methods.balanceOf(this.state.userAddress).call()
    // console.log(tokenBalance)
    // console.log(tokenABalance)
    // await this.getBalance()
  }

  render() {
    let content;
    if (this.state.is_loading) {
      content = (
        <p id="loader" className="text-center">
          Loading...
        </p>
      );
    } else {
      content = (
        <div>
          <BrowserRouter>
            <Routes>
              <Route
                path="/"
                element={
                  <UserPage
                    userAddress={this.state.userAddress}
                    token={this.state.token}
                    tokensToTrade={this.state.tokensToTrade}
                    dex={this.state.dex}
                    web3={this.state.web3Provider}
                  />
                }
              />
              <Route
                path="/TradeToken"
                element={
                  <TradeToken
                    userAddress={this.state.userAddress}
                    dex={this.state.dex}
                    token={this.state.token}
                    tokensToTrade={this.state.tokensToTrade}
                  />
                }
              />
              <Route
                path="/swapBasicToken"
                element={
                  <SwapBasicToken
                    userAddress={this.state.userAddress}
                    contract={this.state.bank}
                    token={this.state.token}
                    web3={this.state.web3Provider}
                  />
                }
              />
              {/* <Route path="/service" component={Service} /> */}
              <Route
                path="/withdrawETH"
                element={
                  <WithDrawETH
                    userAddress={this.state.userAddress}
                    contract={this.state.bank}
                    token={this.state.token}
                    web3={this.state.web3Provider}
                  />
                }
              />
            </Routes>

            {/* <Route path="/service" component={Service} /> */}
          </BrowserRouter>
          {/* <UserPage userAddress={this.state.userAddress}
            token={this.state.token}
            tokensToTrade={this.state.tokensToTrade}
            dex={this.state.dex}
            web3={this.state.web3Provider}
          /> */}
          {/* <UserAccountInfo
            userAddress={this.state.userAddress}
            token={this.state.token}
            tokensToTrade={this.state.tokensToTrade}
            dex={this.state.dex}
            web3={this.state.web3Provider}
          />
          <AllUserOffers
            userAddress={this.state.userAddress}
            token={this.state.token}
            tokensToTrade={this.state.tokensToTrade}
            dex={this.state.dex}
            web3={this.state.web3Provider}
          /> */}

          {/* <UserOffers userAddress={this.state.userAddress} token={this.state.token} tokenToTrade={this.state.tokensToTrade.tokenA} dex={this.state.dex} is_sell = {true}/>
         <UserOffers userAddress={this.state.userAddress} token={this.state.token} tokenToTrade={this.state.tokensToTrade.tokenA} dex={this.state.dex} is_sell = {false}/> */}
        </div>
      );
    }
    return (
      <div className="App">
        <header className="App-header">
          {/* <h1>This is the home page</h1> */}

          {content}
        </header>
      </div>
    );
  }
}

export default App;
