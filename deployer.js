require('dotenv').config();
var Web3 = require("web3")

var provider = new Web3.providers.HttpProvider(process.env.RPCENDPOINT)

 var web3 = new Web3(provider)
 // Super Admin details
 const account = process.env.ADMIN
 const account_pass = process.env.ADMIN_PASS

web3.eth.personal.unlockAccount(account, account_pass, 300)
  .then(function(res){
    console.log('unlock succeeded: ' + res);
    // Smartcontract Bytecode
    var code = ''
     web3.eth.sendTransaction({
      from: account,
      gas: 6000000,
      data: code
    })
    .then(function(receipt){
      //console.info(receipt);  // for debug
      console.log('Contract Address : ' + receipt.contractAddress);
    });
  });