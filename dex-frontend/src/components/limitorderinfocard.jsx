import React, { Component } from "react";
import Card from "react-bootstrap/Card";
import Button from "react-bootstrap/Button";
import Form from "react-bootstrap/Form";
import Badge from "react-bootstrap/Badge";
import { Row, Col } from "react-bootstrap";

class LimitOrderInfoCard extends Component {
  constructor(props) {
    super(props);
    this.state = {
      orderType: this.props.orderType,
      price: 0,
      amount: 0,
      tokenToTrade: this.props.tokenToTrade,
    };
    this.onSubmit = this.onSubmit.bind(this);
    // this.handelInputAmountChange = this.handelInputAmountChange.bind(this);
    // this.handelOrderTypeChange = this.handelOrderTypeChange.bind(this);
  }
  componentDidUpdate(prevProps, preState) {
    if (preState.tokenToTrade !== this.props.tokenToTrade) {
      this.setState({ tokenToTrade: this.props.tokenToTrade });
    }
  }

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
        this.props.executeLimit(
          this.state.price,
          this.state.amount,
          this.state.tokenToTrade,
          true
        );
      } else if (this.props.orderType === "Sell") {
        this.props.executeLimit(
          this.state.price,
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
      //height: "45vh",
    };
    const formClasses = "mb-1";
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
                controlId="formMarketOrderPrice"
              >
                <Form.Label>Price</Form.Label>
                <Form.Control
                  type="number"
                  min="0.00"
                  step="0.001"
                  //onKeyDown={(evt) => evt.key === "e" && evt.preventDefault()}
                  placeholder="Enter Price"
                  value={this.state.price}
                  onChange={(e) => this.setState({ price: e.target.value })}
                />
                <Form.Text className="text-muted">
                  Please enter the price you want to trade.
                </Form.Text>
              </Form.Group>
              <Form.Group
                className={formClasses}
                controlId="formBuyMarketOrderAmount"
              >
                <Form.Label>Amount</Form.Label>
                <Form.Control
                  type="number"
                  min="0.00"
                  step="0.001"
                  //onKeyDown={(evt) => evt.key === "e" && evt.preventDefault()}
                  placeholder="Enter Amount"
                  value={this.state.amount}
                  onChange={(e) => this.setState({ amount: e.target.value })}
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

export default LimitOrderInfoCard;
