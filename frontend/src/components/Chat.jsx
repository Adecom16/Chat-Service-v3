import { useEffect, useState } from "react";
import { ethers } from "ethers";
import { chatContract, getProposalsContract } from "../constants/contracts";
import { toast } from "react-toastify";
import { readOnlyProvider, getProvider } from "../constants/providers";
import {
  useWeb3ModalProvider,
  useWeb3ModalAccount,
} from "@web3modal/ethers/react";

export default function Chat() {
  const [senderEnsName, setSenderEnsName] = useState("");
  const [receiverEnsName, setReceiverEnsName] = useState("");
  const [messageContent, setMessageContent] = useState("");
  const [{ data: messages }, setMessages] = useState({ data: [] });
  const [{ data: registeredUsers }, setRegisteredUsers] = useState({
    data: [],
  });
  const { walletProvider } = useWeb3ModalProvider();
  const { address } = useWeb3ModalAccount();

  console.log(messages);

  useEffect(() => {
    const contract = chatContract(readOnlyProvider);

    contract
      .getRegisteredUsers()
      .then((res) => {
        const converted = res.map((item) => ({
          ensName: item.ensName,
          DisplayPictureURI: item.DisplayPictureURI,
        }));

        setRegisteredUsers({
          data: converted,
        });
      })
      .catch((err) => {
        console.error("error fetching proposals: ", err);
      });
  }, []);

  const selectReceiver = (selectedUser) => {
    setReceiverEnsName(selectedUser);
  };

  const sendMessage = async () => {
    const readWriteProvider = getProvider(walletProvider);
    const signer = await readWriteProvider.getSigner();

    const contract = chatContract(signer);
    try {
      const tx = await contract.sendMessage(receiverEnsName, messageContent);
      const txReceipt = await tx.wait();
      console.log("Receipt: ", txReceipt);
      setMessageContent("");
    } catch (error) {
      console.error("Error sending message:", error);
    }
  };

  useEffect(() => {
    const chat = chatContract(readOnlyProvider);
    const nameService = getProposalsContract(readOnlyProvider);

    async () => {
      const senderName = await nameService.domains(address);
      setSenderEnsName(senderName[0]);

      const history = await chat
        .getMessages(senderEnsName, receiverEnsName)
        .then((res) => {
          const response = res.map((item) => ({
            sender: item.sender,
            receiver: item.receiver,
            content: item.content,
          }));

          setRegisteredUsers({
            data: response,
          });
        })
        .catch((err) => {
          console.error("error fetching proposals: ", err);
        });

      setMessages(history);
    };
  }, []);

  return (
    <div className="min-h-screen bg-gray-100 flex flex-col justify-center items-center">
      <h1 className="text-3xl font-bold mt-8 mb-4 text-primary">Chat DApp</h1>
      <div className="w-full max-w-xl bg-white shadow-md rounded-lg p-6">
        <div className="mb-4">
          <h3 className="text-lg font-semibold mb-2">
            Select a user to chat with:
          </h3>
          <ul className="space-y-2">
            {registeredUsers.map((user, index) => (
              <li
                key={index}
                className="cursor-pointer hover:bg-gray-100 p-2 rounded-md flex items-center gap-4"
                onClick={() => selectReceiver(user.ensName)}
              >
                <img
                  src={`https://ipfs.io/ipfs/${user.DisplayPictureURI}`}
                  alt=""
                  className="w-10 h-10 rounded-md"
                />
                {user.ensName}
              </li>
            ))}
          </ul>
        </div>
        <div className="mb-4">
          <label
            htmlFor="receiverEnsName"
            className="block text-sm font-medium text-gray-700"
          >
            Receiver ENS Name:
          </label>
          <input
            id="receiverEnsName"
            type="text"
            value={receiverEnsName}
            onChange={(e) => setReceiverEnsName(e.target.value)}
            className="mt-1 focus:ring-primary focus:border-primary block w-full shadow-sm sm:text-sm border-gray-300 rounded-md"
            disabled
          />
        </div>
        <div className="mb-4">
          <label
            htmlFor="messageContent"
            className="block text-sm font-medium text-gray-700"
          >
            Message:
          </label>
          <input
            id="messageContent"
            type="text"
            value={messageContent}
            onChange={(e) => setMessageContent(e.target.value)}
            className="mt-1 focus:ring-primary focus:border-primary block w-full shadow-sm sm:text-sm border-gray-300 rounded-md"
          />
        </div>
        <button
          onClick={sendMessage}
          className="bg-primary hover:bg-blue-700 text-white font-bold py-2 px-4 rounded"
        >
          Send Message
        </button>
      </div>

      <div className="mt-8 w-full max-w-xl bg-white shadow-md rounded-lg p-6">
        <h2 className="text-lg font-semibold mb-4">Messages</h2>
        <ul className="space-y-4">
          {messages.map((msg, index) => (
            <li key={index} className="border p-4 rounded-lg">
              <strong className="text-primary">From:</strong> {msg.sender}
              <br />
              <strong className="text-primary">To:</strong> {msg.receiver}
              <br />
              <strong className="text-primary">Content:</strong> {msg.content}
              <br />
            </li>
          ))}
        </ul>
      </div>
    </div>
  );
}
