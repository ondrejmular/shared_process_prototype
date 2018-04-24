// requires defined packageDeliveryAbi and packageDeliveryCode variables

var acc1 = "0x92f4f00f2f5355f5ec1c55512118f1fa537b1864";
var acc2 = "0xf27292834a6b7129e5ad00e264062c978c48d705";
var acc3 = "0x830de593b42d3a007e19553c68f0f4c95e0e6e8f";

function new_pkg_delivery_contract(carrier_addr, recipient_addr) {
  return web3.eth.contract(packageDeliveryAbi).new(
    carrier_addr,
    recipient_addr,
    {
      from: web3.eth.accounts[0],
      data: packageDeliveryCode,
      gas: '4700000'
    },
    function (e, contract){
      console.log(e, contract);
      if (typeof contract.address !== 'undefined') {
        console.log(
          'Contract mined! address: ' + contract.address + ' transactionHash: ' + contract.transactionHash
        );
      }
    }
  )
}

function get_existing_pkg_delivery_contract(addr) {
  return web3.eth.contract(packageDeliveryAbi).at(addr);
}

function send_tx(arg) {
  return arg.sendTransaction({from: eth.accounts[0]})
}

function show_status(obj) {
  console.log("Process status: " + obj.get_process_state());
  console.log("Package delivery status: " + obj.get_status());
}
