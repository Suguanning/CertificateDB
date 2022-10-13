//const CertificateDB = artifacts.require("CertificateDB");
const pdfStorageAndRetrieval = artifacts.require("pdfStorageAndRetrieval");
const Test = artifacts.require("Test");

module.exports = function (deployer) {
  deployer.deploy(pdfStorageAndRetrieval);
  deployer.deploy(Test);
};