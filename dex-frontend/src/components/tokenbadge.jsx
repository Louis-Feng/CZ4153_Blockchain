import React, { Component } from "react";
import "bootstrap/dist/css/bootstrap.css";

class Badge extends Component {
  state = {
    color: "dark",
    badgeName: "null",
  };

  constructor(props) {
    super(props);
    this.state = {
      color: this.props.color,
      badgeName: this.props.badgeName,
    };
  }

  render() {
    const classes = "badge bg-" + this.state.color;
    return (
      <h5>
        <span className={classes}>{this.state.badgeName}</span>
      </h5>
    );
  }
}

export default Badge;
