import React, { Component } from "react";
import LimitOrderInfoCard from "./limitorderinfocard";

class LimitOrderInfoCardContainer extends Component {
  state = {
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
          <LimitOrderInfoCard
            tokenToTrade={this.state.tokenToTrade}
            orderType="Buy"
          ></LimitOrderInfoCard>
          <LimitOrderInfoCard
            tokenToTrade={this.state.tokenToTrade}
            orderType="Sell"
          ></LimitOrderInfoCard>
        </div>
      </React.Fragment>
    );
  }
}

export default LimitOrderInfoCardContainer;
