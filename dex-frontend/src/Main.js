import logo from './logo.svg';
import './App.css';
import React, {Component} from "react";


class Main extends Component{

  constructor(props) {
    super(props);
    this.state = {
      userWallet: {
        token_balance: 0,
        tokenA_balance: 0,
        eth_balance: 0
      }
    }
  }

  componentDidMount() {
    this.getBalances();
    // this.loadUserAddress();
  }
  async getBalances() {
    if (this.props.token) {
        let token_balance = await this.props.token.methods
          .balanceOf(this.props.userAddress)
          .call();
        this.setState((prevState) => ({
          userWallet: {
            ...prevState.userWallet,
            token_balance: token_balance,
          },
        }));
        console.log("token balence")
        console.log(this.state.userWallet.token_balance)
      } else {
        window.alert("BasicToken contract not deployed to detected network");
      }

      if (this.props.tokenA) {
        let tokenA_balance = await this.props.tokenA.methods
          .balanceOf(this.props.userAddress)
          .call();
        this.setState((prevState) => ({
          userWallet: {
            ...prevState.userWallet,
            tokenA_balance: tokenA_balance,
          },
        }));
        console.log("tokenA balence")
        console.log(this.state.userWallet.tokenA_balance)
      } else {
        window.alert("TokenA contract not deployed to detected network");
      }

      if (this.props.dex) {
        let web3 = this.props.web3;
        let eth_balance = await web3.eth.getBalance(this.props.userAddress);
        this.setState((prevState) => ({
          userWallet: {
            ...prevState.userWallet,
            eth_balance: eth_balance,
          },
        }));
        console.log("eth balence")
        console.log(this.state.userWallet.eth_balance)
      } else {
        window.alert("dex contract not deployed to detected network");
      }
  }

//   componentDidUpdate(prevProps, prevState) {
//     if (prevState.web3Provider !== this.state.web3Provider ){
//       this.loadUserAddress();
//     }
//     if (prevState.userAddress !== this.state.userAddress ){
//       this.loadContracts();
//     }
      
//   }




  render() {
    return (
      <div className="Main">
      
        <img src={logo} className="App-logo" alt="logo" />
        <p>
          Edit <code>src/App.js</code> and save to reload. {this.props.userAddress}
        </p>
        <a
          className="App-link"
          href="https://reactjs.org"
          target="_blank"
          rel="noopener noreferrer"
        >
          Learn React
        </a>

    </div>
    );
  }
}

export default Main;