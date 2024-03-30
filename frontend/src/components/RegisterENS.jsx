import { useState } from "react";
import { ethers } from "ethers";
import { getProposalsContract } from "../constants/contracts";
import { toast } from "react-toastify";
import { getProvider } from "../constants/providers";
import { useWeb3ModalProvider } from "@web3modal/ethers/react";

export default function RegisterENS() {
  const [selectedFile, setSelectedFile] = useState();
  const [ensName, setEnsName] = useState("");
  const { walletProvider } = useWeb3ModalProvider();

  const handleSubmit = async (e) => {
    e.preventDefault();

    const formData = new FormData();

    if (!selectedFile && !ensName) {
      return toast.error("Please select an image or enter an ensName");
    } else {
      formData.append("file", selectedFile);

      const res = await fetch(
        "https://api.pinata.cloud/pinning/pinFileToIPFS",
        {
          method: "POST",
          headers: {
            Authorization: `Bearer ${import.meta.env.VITE_PINATA_JWT}`,
          },
          body: formData,
        }
      );

      const fileUrl = await res.json();

      const readWriteProvider = getProvider(walletProvider);
      const signer = await readWriteProvider.getSigner();

      const contract = getProposalsContract(signer);

      try {
        const tx = await contract.registerNameService(
          ensName,
          fileUrl.IpfsHash
        );
        const receipt = await tx.wait();

        console.log("receipt: ", receipt);

        let notification;

        if (receipt.status) {
          notification = "Account created successfully";
        } else {
          return toast.error("Account creation failed");
        }

        toast.success(notification);
      } catch (error) {
        console.log(error);

        let errorMessage;

        if (error.reason === "rejected") {
          errorMessage = "Transaction rejected";
        } else {
          console.log("Error", error);
        }

        return toast.error(errorMessage);
      }
    }

    setEnsName("");
    setSelectedFile();
  };

  return (
    <div className="flex items-center justify-center w-full text-white">
      <div className="w-full max-w-sm flex flex-col gap-10 items-center bg-[#201D29] rounded-md p-10">
        <input
          type="file"
          accept="image/*"
          hidden
          className="hidden"
          id="selectFile"
          onChange={(e) => setSelectedFile(e.target.files[0])}
        />
        <label
          htmlFor="selectFile"
          className="rounded-lg w-32 h-32 bg-secondary flex items-center justify-center cursor-pointer border border-dashed"
        >
          {selectedFile ? (
            <img
              src={URL.createObjectURL(selectedFile)}
              className="w-full h-full object-cover rounded-lg"
              alt="Selected File"
            />
          ) : (
            <img src="./upload_icon.png" alt="cloud" />
          )}
        </label>

        <form
          onSubmit={handleSubmit}
          className="flex flex-col my-4 w-full gap-4 items-center"
        >
          <div className="space-y-2 flex flex-col w-full">
            <label className="text-sm">ENS Name</label>
            <input
              className="mt-1 bg-transparent border border-gray-700 px-2 py-2 shadow-sm focus:outline-none hover:bg-[#292631] w-full rounded-md sm:text-sm placeholder:text-gray-500"
              placeholder="ojukwu.eth"
              value={ensName}
              onChange={(e) => setEnsName(e.target.value)}
            />
          </div>

          <button className="w-full bg-[#6D6FF3] text-white focus:outline-none">
            Register
          </button>
        </form>
      </div>
    </div>
  );
}
