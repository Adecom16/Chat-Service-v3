import { Flex } from "@radix-ui/themes";

export default function Header() {
  return (
    <div className="flex items-center justify-between p-4 text-white pb-28">
      <div className="font-mono font-extrabold text-2xl">
        <span className="text-[#6D6FF3]">ENS</span>Chat
      </div>
      <w3m-button />
    </div>
  );
}
