import React from "react";
// import {
//   updateDeposit,
//   newDeposit,
//   BankContractAddress,
//   Testnet,
// } from "./bank.js";

import Web3 from "web3";
import BankJS from "./contracts/Bank.json";
import detectEthereumProvider from "@metamask/detect-provider";


// example from doc: https://reactjs.org/docs/forms.html#controlled-components
class SwapBasicToken extends React.Component {
  constructor(props) {
    super(props);
    this.state = {
      depositInput: 0,
      is_loading: true,
    };

    
    this.handleDepositChange = this.handleDepositChange.bind(this);
    this.handleNewDeposit = this.handleNewDeposit.bind(this);
  }

//   componentDidMount() {
//     this.initiateWeb3();
//     // this.loadUserAddress();
//   }

//   componentDidUpdate(prevProps, prevState) {
//     if (prevState.web3Provider !== this.state.web3Provider) {
//       this.loadUserAddress();
//     }
//     if (prevState.userAddress !== this.state.userAddress) {
//       this.loadContracts();
//     }
//   }

  updateDeposit = async (addr) => {
    // doc here: https://web3js.readthedocs.io/en/v1.2.11/web3-eth-contract.html#methods-mymethod-call
    const newBalance = await this.props.contract.methods.balance().call({ from: addr });
    console.log("newBalance")
    return { address: addr, deposit: newBalance };
  };
  
  newDeposit = async (amount) => {
    // Using MetaMask API to send transaction
    //
    // please read: https://docs.metamask.io/guide/ethereum-provider.html#ethereum-provider-api
    const provider = await detectEthereumProvider();
    const web3 = this.props.web3;
    if (provider) {
      //From now on, this should always be true:
      //provider === window.ethereum

      // window.ethereum.request({
      //   method: "eth_sendTransaction",
      //   params: [
      //     {
      //       from: window.ethereum.selectedAddress,
      //       to: this.props.contract._address,
      //       value: web3.utils.toHex(web3.utils.toWei(amount)), // have to convert to hexdemical for big number
      //       data: web3.eth.abi.encodeFunctionCall(
      //         {
      //           name: "deposit",
      //           type: "function",
      //           inputs: [],
      //         },
      //         []
      //       ), // https://web3js.readthedocs.io/en/v1.2.11/web3-eth-abi.html#encodefunctioncall
      //       chainId: 1337, // ganache
      //     },
      //   ],
      // });
      await this.props.dex.methods
      .swapBasicToken(
        this.props.contract._address,
        this.props.token._address
      )
      .send({ from: this.props.userAddress, value: web3.utils.toHex(web3.utils.toWei(amount))})
      .on("transactionHash", (hash) => {})
      .on("error", (error) => {
        if (error.message.includes("User denied transaction signature")) {
          this.setState({ is_loading: false });
        }
      });

    } else {
      console.log("Please install MetaMask!");
    }
  };

  handleDepositChange = (e) => {
    this.setState({ depositInput: e.target.value });
  };
  handleNewDeposit = async () => {
    await this.newDeposit(this.state.depositInput)
    // const web3 = this.props.web3;
    // await this.props.token.methods
    //   .mint(
    //     this.props.userAddress,
    //     web3.utils.toHex(web3.utils.toWei(this.state.depositInput))
    //   )
    //   .send({ from: this.props.userAddress })
    //   .on("transactionHash", (hash) => {})
    //   .on("error", (error) => {
    //     if (error.message.includes("User denied transaction signature")) {
    //       this.setState({ is_loading: false });
    //     }
    //   });
  };

  render() {
    return (
      <div>
        <h1>Swap ETH to BasicToken</h1>
        <p>User Address: {this.props.userAddress}</p>
        <p>ether balance: </p>
        <input
          type="text"
          placeholder="Enter amount (in Ether) to swap"
          value={this.state.value}
          onChange={this.handleDepositChange}
        />{" "}
        <input
          type="submit"
          value="New Deposit"
          onClick={this.handleNewDeposit}
        />
      </div>
    );
  }
}

export default SwapBasicToken;