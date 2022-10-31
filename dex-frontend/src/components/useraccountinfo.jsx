import React, { Component } from "react";
import "bootstrap/dist/css/bootstrap.css";
import Badge from "./tokenbadge";

class UserAccountInfo extends Component {
  render() {
    const containerStyle = {
      display: "flex",
      justifyContent: "center",
      alignItems: "center",
      height: "90vh",
    };
    const cardStyle = {
      display: "flex",
      justifyContent: "center",
      alignItems: "center",
      width: "100vh",
      height: "60vh",
    };
    const cardBodyStyle = {
      width: "100vh",
      height: "60vh",
    };

    const balanceTableContainerStyle = {
      width: "90vh",
      height: "50vh",
    };

    const balanceTableStyle = {
      width: "40vh",
      height: "40vh",
    };

    return (
      <React.Fragment>
        <div className="d-flex flex-column" style={containerStyle}>
          <div className="card text-bg-light mx-auto my-auto" style={cardStyle}>
            <div className="card-body" style={cardBodyStyle}>
              <h3 className="pt-3 card-title" style={{ paddingLeft: 10 }}>
                <span style={{ fontWeight: "bold" }}>User Profile</span>
              </h3>
              <div
                className="d-flex flex-row"
                style={balanceTableContainerStyle}
              >
                <table
                  className="mx-auto my-auto table"
                  style={balanceTableStyle}
                >
                  <thead>
                    <tr>
                      <th scope="col">Token Type</th>
                      <th scope="col">Current Balance</th>
                    </tr>
                  </thead>
                  <tbody>
                    <tr>
                      <th scope="row">
                        <Badge color="dark" badgeName="BasicToken"></Badge>
                      </th>
                      <td>
                        <Badge color="info" badgeName={100}></Badge>
                      </td>
                    </tr>
                    <tr>
                      <th scope="row">
                        <Badge color="dark" badgeName="TokenA"></Badge>
                      </th>
                      <td>
                        <Badge color="info" badgeName={100}></Badge>
                      </td>
                    </tr>
                    <tr>
                      <th scope="row">
                        <Badge color="dark" badgeName="TokenB"></Badge>
                      </th>
                      <td>
                        <Badge color="info" badgeName={100}></Badge>
                      </td>
                    </tr>
                    <tr>
                      <th scope="row">
                        <Badge color="dark" badgeName="TokenC"></Badge>
                      </th>
                      <td>
                        <Badge color="info" badgeName={100}></Badge>
                      </td>
                    </tr>
                  </tbody>
                </table>
                <div
                  className="btn-group-vertical mx-auto my-auto"
                  role="group"
                  aria-label="Vertical radio toggle button group"
                >
                  <button className="btn btn-outline-dark btn-lg">
                    <span style={{ fontWeight: "bold" }}>Swap Token</span>
                  </button>
                  <button className="btn btn-outline-dark btn-lg">
                    <span style={{ fontWeight: "bold" }}>Withdraw Token</span>
                  </button>
                  <button className="btn btn-outline-dark btn-lg">
                    <span style={{ fontWeight: "bold" }}>Trade Token</span>
                  </button>
                </div>
              </div>
            </div>
          </div>
        </div>
      </React.Fragment>
    );
  }
}

export default UserAccountInfo;
