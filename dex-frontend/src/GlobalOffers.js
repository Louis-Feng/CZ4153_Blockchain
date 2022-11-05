import "./App.css";
import React, { Component } from "react";
import { Button, Table } from "react-bootstrap";
import Badge from "react-bootstrap/Badge";
import Card from "react-bootstrap/Card";
import Alert from "react-bootstrap/Alert";
// import Web3 from 'web3';
// import {Col} from "react-bootstrap";
// import {Row} from "react-bootstrap";
// import Table from "react-bootstrap/Table";

class GlobalOffers extends Component {
  constructor(props) {
    super(props);
    this.state = {
      ordersPrices: [],
      ordersVolumes: [],

      is_loading: true,
    };
  }

  componentDidMount() {
    console.log(this.props.tokenToTrade._address);
    console.log(this.props.userAddress);
    this.props.dex.methods
      .getOrders(this.props.tokenToTrade._address, this.props.is_sell)
      .call({ from: this.props.userAddress })
      .then((result) => {
        result = this.removeElementsWithZeroValue(result);
        console.log(result);
        this.setState({
          ordersPrices: result[0],
          ordersVolumes: result[1],
        });
        this.setState({ is_loading: false });
      });
  }

  removeElementsWithZeroValue(arr) {
    var array = [];
    for (var i = 0; i < Object.keys(arr).length; i++) {
      array[i] = arr[i].filter(function (value, index, arr) {
        return value !== "0";
      });
    }
    return array;
  }

  updateOrders = () => {
    this.setState({ is_loading: true });
    this.props.dex.methods
      .getUserOrders(this.props.tokenToTrade._address, this.props.is_sell)
      .call({ from: this.props.userAddress })
      .then((result) => {
        result = this.removeElementsWithZeroValue(result);
        console.log(result);
        this.setState({
          ordersPrices: result[0],
          ordersVolumes: result[1],
        });
        this.setState({ is_loading: false });
      });
  };

  renderOrder() {
    return this.state.ordersPrices.map((p, index) => {
      const price = this.props.web3.utils.fromWei(p, "Ether");
      // const price = Web3.utils.fromWei(p, "Ether");
      //   const amount = web3.utils.fromWei(orderBookAmount[index], "Ether");
      return (
        <>
          <tr>
            <td>
              <Badge bg="dark">{this.props.tokenName.toUpperCase()}</Badge>
            </td>
            <td>
              <Badge bg="info">{price}</Badge>
            </td>
            <td>
              <Badge bg="info">{this.state.ordersVolumes[index]}</Badge>
            </td>
          </tr>
        </>
      );
    });
  }

  render() {
    let content;
    if (this.state.is_loading) {
      content = (
        <Alert className="text-black" key="warning" variant="warning">
          <b>LOADING...</b>
        </Alert>
      );
    } else if (this.state.ordersPrices.length === 0) {
      content = (
        <Alert className="text-black" key="dark" variant="dark">
          <b>The current order book is empty.</b>
        </Alert>
      );
    } else {
      content = (
        <>
          <Table striped bordered hover size="sm">
            <thead>
              <tr>
                <th>Token Name</th>
                <th>Price</th>
                <th>Amount</th>
              </tr>
            </thead>
            <tbody>{this.renderOrder()}</tbody>
          </Table>
        </>
      );
    }
    const cardStyle = {
      width: "50vh",
    };
    return <div className="GlobalOffers">{content}</div>;
  }
}

export default GlobalOffers;
