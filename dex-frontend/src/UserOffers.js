// import logo from './logo.svg';
import "./App.css";
import React, { Component } from "react";
import { Button, Table } from "react-bootstrap";
// import {Col} from "react-bootstrap";
// import {Row} from "react-bootstrap";
// import Table from "react-bootstrap/Table";
import "bootstrap/dist/css/bootstrap.css";
import Badge from "react-bootstrap/Badge";
import Alert from "react-bootstrap/Alert";

class UserOffers extends Component {
  constructor(props) {
    super(props);
    this.state = {
      ordersPrices: [],
      ordersVolumes: [],
      ordersPriorities: [],

      is_loading: true,
    };
  }

  componentDidMount() {
    console.log(this.props.tokenToTrade._address);
    console.log(this.props.userAddress);
    this.props.dex.methods
      .getUserOrders(this.props.tokenToTrade._address, this.props.is_sell)
      .call({ from: this.props.userAddress })
      .then((result) => {
        result = this.removeElementsWithZeroValue(result);
        console.log(result);
        this.setState({
          ordersPrices: result[0],
          ordersVolumes: result[1],
          ordersPriorities: result[2],
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
  cancelOrder = async (price, priority) => {
    this.setState({ is_loading: true });
    await this.props.dex.methods
      .removeOrder(
        this.props.token._address,
        this.props.tokenToTrade._address,
        this.props.is_sell,
        price,
        priority
      )
      .send({ from: this.props.userAddress })
      .on("transactionHash", (hash) => {})
      .on("error", (error) => {
        if (error.message.includes("User denied transaction signature")) {
          this.setState({ is_loading: false });
        }
      });

    this.setState({ is_loading: false });
    this.updateOrders();
  };

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
          ordersPriorities: result[2],
        });
        this.setState({ is_loading: false });
      });
  };

  renderOrder() {
    return this.state.ordersPrices.map((p, index) => {
      const price = this.props.web3.utils.fromWei(p, "Ether");
      // const amount = web3.utils.fromWei(this.state.ordersVolumes[index], "Ether");
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
            <td>
              <Button
                variant="outline-dark"
                size="sm"
                onClick={() => {
                  this.cancelOrder(p, this.state.ordersPriorities[index]);
                }}
              >
                Cancel
              </Button>
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
        <p id="loader" className="text-center">
          Loading...
        </p>
      );
    } else if (this.state.ordersPrices.length === 0) {
      content = (
        <Alert className="text-black" key="dark" variant="dark">
          <h6>
            <b>No order submitted.</b>
          </h6>
        </Alert>
      );
    } else {
      content = (
        <>
          <Table striped bordered hover size="sm">
            <thead>
              <tr>
                <th scope="col">Token Type</th>
                <th scope="col">Price</th>
                <th scope="col">Amount</th>
                <th scope="col">Cancel?</th>
              </tr>
            </thead>
            <tbody>{this.renderOrder()}</tbody>
          </Table>
        </>

        // <>
        //     <tr>
        //       <td>price: {this.state.ordersPrices}</td>
        //       <td>amount: {this.state.ordersVolumes}</td>
        //       <td>
        //         <Button
        //           size="sm"
        //           onClick={() => {
        //             this.cancelOrder(price);
        //           }}
        //         >
        //           Cancel
        //         </Button>
        //       </td>
        //     </tr>
        //   </>
      );
    }
    return <div className="UserOffers">{content}</div>;
  }
}

export default UserOffers;
