import React, { Component } from "react";
import Card from "react-bootstrap/Card";
import Button from "react-bootstrap/Button";
import Form from "react-bootstrap/Form";
import Badge from "react-bootstrap/Badge";

class MarketOrderInfoCard extends Component {
  constructor(props) {
    super(props);
    this.state = {
      orderType: this.props.orderType,
      amount: 0,
      tokenToTrade: this.props.tokenToTrade,
    };
    this.onSubmit = this.onSubmit.bind(this);
    this.handelInputAmountChange = this.handelInputAmountChange.bind(this);
    this.handelOrderTypeChange = this.handelOrderTypeChange.bind(this);
  }
  componentDidUpdate(prevProps, preState) {
    if (preState.tokenToTrade !== this.props.tokenToTrade) {
      this.setState({ tokenToTrade: this.props.tokenToTrade });
    }
  }
  handelInputPriceChange = (e) => {
    this.setState({ price: e.target.value });
  };
  handelInputAmountChange = (e) => {
    this.setState({ amount: e.target.value });
  };
  handelOrderTypeChange = (e) => {
    this.setState({ orderType: e.target.value });
  };

  onSubmit = (e) => {
    e.preventDefault();
    console.log("refresh prevented");
    console.log("token to trade: ", this.state.tokenToTrade);
    console.log("hello from ", this.state.orderType);
    console.log(this.state.price);
    console.log(this.state.amount);
    if (parseFloat(this.state.amount) <= 0) {
      alert("Please input positive values");
    } else {
      if (this.props.orderType === "Buy") {
        this.props.executeMarket(
          this.state.amount,
          this.state.tokenToTrade,
          true
        );
      } else if (this.props.orderType === "Sell") {
        this.props.executeMarket(
          this.state.amount,
          this.state.tokenToTrade,
          false
        );
      }
    }
  };

  render() {
    const cardStyle = {
      width: "50vh",
      height: "30vh",
    };
    const formClasses = "mb-6";
    const submitButtonStyles = {
      float: "right",
    };
    return (
      <React.Fragment>
        <Card className="mx-5" style={cardStyle}>
          <Card.Body>
            <Card.Title className="p-1">
              <h3>
                <Badge pill bg="warning">
                  {this.state.orderType}
                </Badge>
              </h3>
            </Card.Title>
            <Form>
              <Form.Group
                className={formClasses}
                controlId="formBuyMarketOrderAmount"
              >
                <Form.Label>Amount</Form.Label>
                <Form.Control
                  type="number"
                  //onKeyDown={(evt) => evt.key === "e" && evt.preventDefault()}
                  placeholder="Enter Amount"
                  value={this.state.amount}
                  onChange={this.handelInputAmountChange}
                />
                <Form.Text className="text-muted">
                  Please enter the amount you want to trade.
                </Form.Text>
              </Form.Group>
              <Button
                className="text-white"
                style={submitButtonStyles}
                variant="info"
                type="submit"
                onClick={this.onSubmit}
              >
                <b>Submit</b>
              </Button>
            </Form>
          </Card.Body>
        </Card>
      </React.Fragment>
    );
  }
}

export default MarketOrderInfoCard;
