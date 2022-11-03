// import logo from './logo.svg';
import './App.css';
import React, {Component} from "react";
import UserOffers from "./UserOffers";
import GlobalOffers from './GlobalOffers';
import {Col} from "react-bootstrap";
import {Row} from "react-bootstrap";


class AllGlobalOffers extends Component{

  constructor(props) {
    super(props);
  }

  renderGlobalOrders() {
    // const web3 = window.web3;
    // let orderBookPrices = this.state.order[0];
    // let orderBookAmount = this.state.order[1];
    console.log("user order")
    if (Object.keys(this.props.tokensToTrade).length === 0) {
      console.log("no token")
      return (<p>There is no token in the system besides Basic Token </p>);
    } else {
      return Object.keys(this.props.tokensToTrade).map((key) => {
        // const price = web3.utils.fromWei(s, "Ether");
        // const amount = web3.utils.fromWei(orderBookAmount[index], "Ether");
        return (
          <div>
            <h1>{key}</h1>
            <div style={{ display: "flex", flexDirection: "row"}}>
            {/* <div className="card mb-4"> */}
          
            <div className="card-body">
            <Row className="mb-4">
              <Col>
                <b>Buy Book</b>
              </Col>
              <Col>
                <b>Sell Book</b>
              </Col>
            </Row>
            <Row>
              <Col>
                <div className="card mb-4">
                  <div className="card-body">
                  <GlobalOffers web3 = {this.props.web3}
                  userAddress={this.props.userAddress} 
                  token={this.props.token} 
                  tokenToTrade={this.props.tokensToTrade[key]} 
                  dex={this.props.dex} 
                  tokenName = {key} 
                  is_sell = {false}/>
                  </div>
                </div>
              </Col>
              <Col>
                <div className="card mb-4">
                  <div className="card-body">
                  <GlobalOffers web3 = {this.props.web3}
                  userAddress={this.props.userAddress} 
                  token={this.props.token} 
                  tokenToTrade={this.props.tokensToTrade[key]} 
                  dex={this.props.dex} 
                  tokenName = {key} 
                  is_sell = {true}/>
                  </div>
                </div>
              </Col>
            </Row>
          </div>
              
              
            </div>
            </div>
        // <div>
        //     <p>{key}</p>
        //   <GlobalOffers userAddress={this.props.userAddress} token={this.props.token} tokenToTrade={this.props.tokensToTrade[key]} dex={this.props.dex} tokenName = {key} is_sell = {true}/>
        //   <GlobalOffers userAddress={this.props.userAddress} token={this.props.token} tokenToTrade={this.props.tokensToTrade[key]} dex={this.props.dex} tokenName = {key} is_sell = {false}/>
        // </div>
        );
      });
    }
  }

  render() {
    // let content;
    // if (this.state.is_loading) {
    //   content = (
    //     <p id="loader" className="text-center">
    //       Loading...
    //     </p>
    //   );
    // } else {
    //   content = (
    //     <div>
    //         {this.renderUserOrders()}
    //     </div>
    //   );
    // }
    return (
    <div className="AllGlobalOffers">
            {this.renderGlobalOrders()}
    </div>
    );
  }
}

export default AllGlobalOffers;