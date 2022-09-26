const KYCContract = artifacts.require("AdminApp");

module.exports = function (deployer) {
  deployer.deploy(KYCContract);
};
