import React from "react";
import AllGlobalOffers from "./AllGlobalOffers";
import TabPage from "./components/tabpage";
// import {
//   updateDeposit,
//   newDeposit,
//   BankContractAddress,
//   Testnet,
// } from "./bank.js";

// import Web3 from "web3";
import BankJS from "./contracts/Bank.json";
import detectEthereumProvider from "@metamask/detect-provider";
// import TabPage from "./components/tabpage";

// example from doc: https://reactjs.org/docs/forms.html#controlled-components
class TradeToken extends React.Component {
  constructor(props) {
    super(props);
    this.state = {
      tokenType: "A",
      isBuy: true,
      isMarket: true,
      amountInput: 0,
      priceInput: "0.2",
      address: "0x0",
      is_loading: false,
    };

    // this.handleAmountChange = this.handleAmountChange.bind(this);
    // this.handleIsBuyChange = this.handleIsBuyChange.bind(this);
    // this.handlePriceChange = this.handlePriceChange.bind(this);
    // this.handleTokenTypeChange = this.handleTokenTypeChange.bind(this);
  }

  // handleTokenTypeChange = (e) => {
  //   this.setState({ tokenType: e.target.value });
  // };
  // handleAmountChange = (e) => {
  //   this.setState({ amountInput: e.target.value });
  // };
  // handlePriceChange = (e) => {
  //   this.setState({ priceInput: e.target.value });
  // };
  // handleIsBuyChange = (e) => {
  //   this.setState({ isBuy: e.target.value === "buy" ? true : false });
  // };
  executeMarket = async (amountInput,tokenName, isBuy) => {
    this.setState({ is_loading: true });
    const web3 = this.props.web3;
    var tokenToTrade;
    console.log(tokenName.toUpperCase())
    switch (tokenName.toUpperCase()) {
      case "TOKENA" : {tokenToTrade = this.props.tokensToTrade.tokenA; break;}
      case "TOKENB" : {tokenToTrade = this.props.tokensToTrade.tokenB; break}
      case "TOKENC" : {tokenToTrade = this.props.tokensToTrade.tokenC; break}
      // default : tokenToTrade = "";
    }
    console.log(tokenToTrade._address);
    if (tokenToTrade) {
      await this.props.dex.methods
      .executeTokenMarket(
        this.props.token._address,
        tokenToTrade._address,
        // this.props.tokensToTrade.tokenA._address,
        amountInput,
        isBuy
        ? web3.utils.asciiToHex("buy")
          : web3.utils.asciiToHex("sell")
      )
      .send({ from: this.props.userAddress })
      .on("transactionHash", (hash) => {})
      .on("error", (error) => {
        if (error.message.includes("User denied transaction signature")) {
          this.setState({ is_loading: false });
        }
      });
    }else {
      console.log("Invalid token")
    }
    

    this.setState({ is_loading: false });
    //this.updateOrders();
  };

  executeLimit = async (priceInput, amountInput,tokenName, isBuy) => {
    this.setState({ is_loading: true });
    const web3 = this.props.web3;
    var tokenToTrade;
    console.log(tokenName.toUpperCase())
    switch (tokenName.toUpperCase()) {
      case "TOKENA" : {tokenToTrade = this.props.tokensToTrade.tokenA; break;}
      case "TOKENB" : {tokenToTrade = this.props.tokensToTrade.tokenB; break}
      case "TOKENC" : {tokenToTrade = this.props.tokensToTrade.tokenC; break}
      // default : tokenToTrade = "";
    }
    console.log(tokenToTrade);
    if (tokenToTrade) {
      await this.props.dex.methods
      .executeLimitOrder(
        this.props.token._address,
        tokenToTrade._address,
        web3.utils.toHex(web3.utils.toWei(priceInput)),
        amountInput,
        isBuy
      )
      .send({ from: this.props.userAddress })
      .on("transactionHash", (hash) => {})
      .on("error", (error) => {
        if (error.message.includes("User denied transaction signature")) {
          this.setState({ is_loading: false });
        }
      });
    }else {
      console.log("Invalid token")
    }
    

    this.setState({ is_loading: false });
    //this.updateOrders();
  };

  // executeLimit = async () => {
  //   this.setState({ is_loading: true });
  //   console.log("Token type: " + this.state.tokenType);
  //   await this.props.dex.methods
  //     .executeLimitOrder(
  //       this.props.token._address,
  //       this.state.tokenType === "A"
  //         ? this.props.tokensToTrade.tokenA._address
  //         : this.state.tokenType === "B"
  //         ? this.props.tokensToTrade.tokenB._address
  //         : this.props.tokensToTrade.tokenC._address,
  //       web3.utils.toHex(web3.utils.toWei(this.state.priceInput)),
  //       this.state.amountInput,
  //       this.state.isBuy
  //     )
  //     .send({ from: this.props.userAddress })
  //     .on("transactionHash", (hash) => {})
  //     .on("error", (error) => {
  //       if (error.message.includes("User denied transaction signature")) {
  //         this.setState({ is_loading: false });
  //       }
  //     });

  //   this.setState({ is_loading: false });
  //   //this.updateOrders();
  // };



  render() {
          var content
          if (this.state.is_loading) {
            content = (
              <p id="loader" className="text-center">
                Loading...
              </p>
            );
          } else {
            content = (
              <AllGlobalOffers
                userAddress={this.props.userAddress}
                token={this.props.token}
                tokensToTrade={this.props.tokensToTrade}
                dex={this.props.dex}
                web3={this.props.web3}
          />
            );}
    return (

      <div className="TradeToken">
        <div>
        <TabPage executeLimit = {this.executeLimit} executeMarket = {this.executeMarket}/>
          </div>

        {content}
      </div>
    );
  }
}

export default TradeToken;
