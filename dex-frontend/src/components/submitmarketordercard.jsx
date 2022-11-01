import React, { Component } from "react";
import Card from "react-bootstrap/Card";
import Button from "react-bootstrap/Button";
import Form from "react-bootstrap/Form";
import Badge from "react-bootstrap/Badge";
import MarketOrderInfoCard from "./marketorderinfocard";

class SubmitMarketOrderCard extends Component {
  state = {
    price: 0,
    amount: 0,
    tokenToTrade: this.props.tokenToTrade,
  };
  componentDidUpdate(prevProps) {
    if (prevProps.tokenToTrade !== this.props.tokenToTrade) {
      this.setState({ tokenToTrade: this.props.tokenToTrade });
    }
  }

  render() {
    const containerStyle = {
      display: "flex",
      justifyContent: "center",
      alignItems: "center",
      height: "75vh",
    };

    return (
      <React.Fragment>
        <div className="d-flex flex-row mx-4" style={containerStyle}>
          <MarketOrderInfoCard
            tokenToTrade={this.state.tokenToTrade}
            orderType="Buy"
            executeLimit = {this.props.executeLimit}
            executeMarket = {this.props.executeMarket}
          ></MarketOrderInfoCard>
          <MarketOrderInfoCard
            tokenToTrade={this.state.tokenToTrade}
            orderType="Sell"
            executeLimit = {this.props.executeLimit}
            executeMarket = {this.props.executeMarket}
          ></MarketOrderInfoCard>
        </div>
      </React.Fragment>
    );
  }
}

export default SubmitMarketOrderCard;
