import logo from './logo.svg';
import './App.css';
import React, {Component} from "react";


class UserAccountInfo extends Component{

  constructor(props) {
    super(props);
    this.state = {
      userWallet: {
        token_balance: 0,
        eth_balance: 0
      },
      is_loading: true
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
      for (const [key, tradingToken] of Object.entries(this.props.tokensToTrade)){
        // var tokenName = key ;
        if (tradingToken) {
          let tradingToken_balance = await tradingToken.methods
            .balanceOf(this.props.userAddress)
            .call();
          // var tradingTokenBalance = {}
          // tradingTokenBalance[key] = tradingToken_balance
          this.setState((prevState) => ({
            userWallet: {
              ...prevState.userWallet,
              [key]: tradingToken_balance
              // ${tokenName}: tradingToken_balance,
            },
          }));
          console.log("tokenA balence")
          console.log(this.state.userWallet)
        } else {
          window.alert("TokenA contract not deployed to detected network");
        }
        
      }

      // if (this.props.tokenA) {
      //   let tokenA_balance = await this.props.tokenA.methods
      //     .balanceOf(this.props.userAddress)
      //     .call();
      //   this.setState((prevState) => ({
      //     userWallet: {
      //       ...prevState.userWallet,
      //       tokenA_balance: tokenA_balance,
      //     },
      //   }));
      //   console.log("tokenA balence")
      //   console.log(this.state.userWallet.tokenA_balance)
      // } else {
      //   window.alert("TokenA contract not deployed to detected network");
      // }

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
      this.setState({is_loading: false})
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
      
        <img src={logo} className="App-logo" alt="logo" />
        <p>
          Edit <code>src/App.js</code> and save to reload. {this.state.userWallet.eth_balance}
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
    return (
    <div className="UserAccountInfo">
      {content}
    </div>
    );
  }
}

export default UserAccountInfo;