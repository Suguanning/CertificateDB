//const CertificateDB = artifacts.require("CertificateDB");
const Certificate = artifacts.require("Certificate");
const Test = artifacts.require("Test");

module.exports = function (deployer) {
  deployer.deploy(Certificate);
  deployer.deploy(Test);
};