import React from "react";
import { configureWeb3Modal } from "./connection";
import { ToastContainer } from "react-toastify";
import "./output.css";
import Header from "./components/Header";
import RegisterENS from "./components/RegisterENS";
import Chat from "./components/Chat";

configureWeb3Modal();

function App() {
  return (
    <>
      <Header />
      <RegisterENS />
      <Chat />
      <ToastContainer theme="light" hideProgressBar={true} />
    </>
  );
}

export default App;
