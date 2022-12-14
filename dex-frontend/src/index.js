import React from "react";
import ReactDOM from "react-dom/client";
import { BrowserRouter, Router, Routes, Route, Link } from "react-router-dom";
import "./index.css";
import App from "./App";
// import Swap from './SwapBasicToken';
import reportWebVitals from "./reportWebVitals";
// import TradeToken from "./TradeToken";
// import AllUserOffers from "./AllUserOffers"
import "react-router-dom";
import TabPage from "./components/tabpage";
import AllUserOffers from "./AllUserOffers";

const root = ReactDOM.createRoot(document.getElementById("root"));
root.render(
  <React.StrictMode>
    <App />
    {/* <BrowserRouter>
      <Routes>
        <Route path="/" element={<App/>} />
        <Route path="/swapBasicToken" component={<Swap/>} />
         <Route path="/service" component={Service} />
       </Routes>
    </BrowserRouter> */}
  </React.StrictMode>
);

// If you want to start measuring performance in your app, pass a function
// to log results (for example: reportWebVitals(console.log))
// or send to an analytics endpoint. Learn more: https://bit.ly/CRA-vitals
reportWebVitals();
