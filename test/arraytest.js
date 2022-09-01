const Test = artifacts.require("Test");
contract('certificate',(accounts)=>{
    it('test insert hash',async ()=>{
        const instance = await Test.deployed();
        await instance.test();

    })
})